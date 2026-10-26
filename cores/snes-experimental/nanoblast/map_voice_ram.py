"""Map only the validated two-write, asynchronous SNES voice memories.

Address aliases are accepted only after a conservative combinational SAT proof:
unknown sequential/black-box outputs are unconstrained, never assumed equal.
The mapped memories originally have undefined power-up contents; their RTL
reset-valid masks make those contents unobservable until a whole-word write.
"""
import argparse, copy, hashlib, json, subprocess
from pathlib import Path

def transform(net, proof_dir, yosys):
    cells=net['modules']['snestang_top']['cells'];mapped=[]
    for suffix in ('BRR_ADDR','INTERP_POS'):
        name='main.SNES.dsp.'+suffix;cell=cells[name];p=cell['parameters'];ports=cell['connections']
        get=lambda k:int(p[k],2);width=get('WIDTH');reads=get('RD_PORTS')
        assert cell['type']=='$mem_v2' and get('ABITS')==3 and get('SIZE')==8 and get('OFFSET')==0
        assert width==16 and reads==2 and get('WR_PORTS')==2
        assert get('WR_CLK_ENABLE')==get('WR_CLK_POLARITY')==3 and ports['WR_CLK'][0]==ports['WR_CLK'][1]
        assert get('RD_CLK_ENABLE')==get('RD_WIDE_CONTINUATION')==get('WR_WIDE_CONTINUATION')==0
        assert get('WR_PRIORITY_MASK')==0 and set(p['INIT'])=={'x'}
        en=ports['WR_EN'];assert len(set(en[:width]))==len(set(en[width:]))==1
        cell.update(type='snes_xor_ram',parameters={'WIDTH':width,'READ_PORTS':reads},
            connections={'CLK':ports['WR_CLK'][:1],'WE':[en[0],en[width]],'WR_ADDR':ports['WR_ADDR'],
                'WR_DATA':ports['WR_DATA'],'RD_ADDR':ports['RD_ADDR'],'RD_DATA':ports['RD_DATA']},
            port_directions={**{n:'input'for n in ('CLK','WE','WR_ADDR','WR_DATA','RD_ADDR')},'RD_DATA':'output'})
        mapped.append(name)
    proof=copy.deepcopy(net);module=proof['modules']['snestang_top'];pcells=module['cells']
    bit=max(b for c in pcells.values()for bs in c['connections'].values()for b in bs if isinstance(b,int))+1
    checks=[];aliases=[('BRR_ADDR',1),('INTERP_POS',0),('INTERP_POS',1)]
    for suffix,port in aliases:
        c=pcells['main.SNES.dsp.'+suffix]['connections'];eq,inv,ok=bit,bit+1,bit+2;bit+=3;prefix='alias_'+suffix+str(port)
        pcells[prefix+'_eq']={'type':'$eq','parameters':{'A_WIDTH':3,'B_WIDTH':3,'Y_WIDTH':1,'A_SIGNED':0,'B_SIGNED':0},
            'port_directions':{'A':'input','B':'input','Y':'output'},'connections':{'A':c['WR_ADDR'][port*3:port*3+3],'B':c['RD_ADDR'][port*3:port*3+3],'Y':[eq]}}
        pcells[prefix+'_not']={'type':'$not','parameters':{'A_WIDTH':1,'Y_WIDTH':1,'A_SIGNED':0},'port_directions':{'A':'input','Y':'output'},'connections':{'A':[c['WE'][port]],'Y':[inv]}}
        pcells[prefix+'_or']={'type':'$or','parameters':{'A_WIDTH':1,'B_WIDTH':1,'Y_WIDTH':1,'A_SIGNED':0,'B_SIGNED':0},
            'port_directions':{'A':'input','B':'input','Y':'output'},'connections':{'A':[eq],'B':[inv],'Y':[ok]}}
        checks.append(ok)
    module['netnames']['safe_alias_checks']={'hide_name':0,'bits':checks,'attributes':{}}
    proof_dir.mkdir(parents=True,exist_ok=True);proof_file=proof_dir/'alias-proof.json';proof_file.write_text(json.dumps(proof)+'\n')
    with(proof_dir/'alias-proof.log').open('w')as log:
        subprocess.run([str(yosys),'-Q','-p',f'read_json {proof_file}; sat -verify -ignore_unknown_cells -prove safe_alias_checks 7'],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=60)
    for suffix,port in aliases:
        c=cells['main.SNES.dsp.'+suffix]['connections'];c['WR_ADDR'][port*3:port*3+3]=c['RD_ADDR'][port*3:port*3+3]
    return mapped

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('target',type=Path);a=p.parse_args()
    base=Path(__file__).resolve().parents[3];data=a.source.read_bytes();net=json.loads(data)
    mapped=transform(net,a.target.parent,base/'work/oss-cad-suite/bin/yosys')
    a.target.write_text(json.dumps(net)+'\n')
    a.target.with_suffix('.voice-ram.json').write_text(json.dumps({'source_sha256':hashlib.sha256(data).hexdigest(),'mapped':mapped},indent=2)+'\n')
    print('PASS voice RAM contracts and write-address SAT proofs; mapped '+', '.join(mapped))
