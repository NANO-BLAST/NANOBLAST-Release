"""Experimental mapping of independent SNES additions into ALU54D lanes.

Gowin UG287 defines mode 0 with ACCLOAD=0 and no subtract as A+B.
Each W-bit lane uses W+1 physical bits: {operand,carry_in}. Duplicating
carry_in on the two inputs forces the carry in bit 1, regardless of the
preceding lane. The next guard sum bit exposes this lane's carry out.
One final guard is reserved. No pipeline registers are used.
"""
import argparse, collections, hashlib, json
from pathlib import Path

def transform(net, blocks):
    module=net['modules']['snestang_top'];cells=module['cells']
    users=collections.Counter(bit for cell in cells.values()
        for port,direction in cell.get('port_directions',{}).items()
        if direction=='input' for bit in cell['connections'][port])
    candidates=[]
    for name,cell in cells.items():
        if cell['type']!='$alu':continue
        p=cell['parameters'];w=int(p['Y_WIDTH'],2);ports=cell['connections']
        src=cell.get('attributes',{}).get('src','')
        if not any(s in src for s in ('src/dsp.v','src/cpu.v','src/65C816/','src/ppu.v')):continue
        if not 8<=w<=25 or ports['BI'] not in (['0'],['1']):continue
        if any(users[b] for b in ports['X']):continue
        if any(users[b] for b in ports['CO'][:-1]):continue
        variable=sum(isinstance(b,int) for k in ('A','B') for b in ports[k])
        # Prefer genuine two-variable additions over cheap constant increments.
        if variable<w:continue
        candidates.append((variable/(w+1),w,name))
    candidates.sort(reverse=True)
    drivers={bit:name for name,cell in cells.items()
        for port,direction in cell.get('port_directions',{}).items()
        if direction=='output' for bit in cell['connections'][port] if isinstance(bit,int)}
    candidate_names={name for _,_,name in candidates}
    def ancestors(name):
        todo=[name];seen=set();result=set()
        while todo:
            current=todo.pop()
            if current in seen:continue
            seen.add(current);cell=cells[current];kind=cell['type'].lower()
            if current!=name and current in candidate_names:result.add(current)
            if 'dff' in kind or kind in ('$ff','$dlatch','$adlatch','dpb','dpx9b','spx9'):continue
            for port,direction in cell.get('port_directions',{}).items():
                if direction!='input':continue
                # Memory writes are sequential; asynchronous address reads may
                # depend on an adder and must still be included in the cone.
                if cell['type']=='$mem_v2' and port!='RD_ADDR':continue
                todo.extend(drivers[b] for b in cell['connections'][port] if b in drivers)
        return result
    cones={name:ancestors(name) for name in candidate_names}
    groups=[]
    for score,w,name in candidates:
        # A single physical ALU must never depend on one of its own lanes.
        group=next((g for g in groups if g['used']+w+1<=53 and
            all(other not in cones[name] and name not in cones[other] for other in g['cells'])),None)
        if group is None:
            if len(groups)>=blocks:continue
            group={'used':0,'cells':[]};groups.append(group)
        group['used']+=w+1;group['cells'].append(name)
    nextbit=max(b for c in cells.values() for bs in c['connections'].values()
        for b in bs if isinstance(b,int))+1
    def fresh(width):
        nonlocal nextbit
        result=list(range(nextbit,nextbit+width));nextbit+=width;return result
    changes=[]
    for index,group in enumerate(groups):
        a=[];b=[];dout=fresh(54)
        for name in group['cells']:
            cell=cells.pop(name);p=cell['parameters'];port=cell['connections'];w=int(p['Y_WIDTH'],2)
            signed=bool(int(p['A_SIGNED'],2) and int(p['B_SIGNED'],2))
            def extend(bits):return (bits+[bits[-1] if signed else '0']*w)[:w]
            aa=extend(port['A']);bb=extend(port['B'])
            if port['BI']==['1']:
                inverted=fresh(w)
                cells[name+'.invert_b']={'type':'$not','parameters':{'A_SIGNED':0,'A_WIDTH':w,'Y_WIDTH':w},
                    'port_directions':{'A':'input','Y':'output'},'connections':{'A':bb,'Y':inverted}}
                bb=inverted
            offset=len(a)
            a+=port['CI']+aa;b+=port['CI']+bb
            dout[offset+1:offset+w+1]=port['Y']
            if users[port['CO'][-1]]:dout[offset+w+1]=port['CO'][-1]
            changes.append({'cell':name,'width':w,'block':index,'original':cell})
        a+=['0']*(54-len(a));b+=['0']*(54-len(b))
        cells[f'nanoblast_alu54_{index}']={'type':'ALU54D',
            'parameters':{**{n:'0' for n in ('AREG','BREG','ASIGN_REG','BSIGN_REG','ACCLOAD_REG','OUT_REG','B_ADD_SUB','C_ADD_SUB')},'ALUD_MODE':'0','ALU_RESET_MODE':'SYNC'},
            'port_directions':{**{p:'input' for p in ('A','B','ASIGN','BSIGN','ACCLOAD','CASI','CLK','CE','RESET')},'DOUT':'output','CASO':'output'},
            'connections':{'A':a,'B':b,'ASIGN':['0'],'BSIGN':['0'],'ACCLOAD':['0'],
                'CASI':['0']*55,'CLK':['0'],'CE':['1'],'RESET':['0'],'DOUT':dout,'CASO':[]}}
    return changes

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('target',type=Path);p.add_argument('--blocks',type=int,default=12);a=p.parse_args()
    data=a.source.read_bytes();net=json.loads(data);changes=transform(net,a.blocks)
    a.target.write_text(json.dumps(net)+'\n')
    a.target.with_suffix('.alu54.json').write_text(json.dumps({'source_sha256':hashlib.sha256(data).hexdigest(),'mapped':changes},indent=2)+'\n')
    print(f'Mapped {len(changes)} additions ({sum(c["width"] for c in changes)} result bits) into {len(set(c["block"]for c in changes))} ALU54D blocks')
