"""Preserve register behavior while reducing sparsely used Gowin clock enables.

One LUT implements the exact DFFE/DFFRE next-state function for small control
sets. A plain DFF then shares a control set with nearby ordinary registers.
Asynchronous resets, clocks, INIT values and all other cells remain untouched.
"""
from pathlib import Path
import argparse,collections,hashlib,json

def table(reset):
 width=4 if reset else 3
 return ''.join(str(0 if reset and i&8 else (i&1) if i&2 else (i>>2)&1)
                for i in reversed(range(1<<width)))

def transform(net,limit):
 module=net['modules']['snestang_top'];cells=module['cells'];groups=collections.defaultdict(list)
 for name,cell in cells.items():
  if cell['type'] not in ('DFFE','DFFRE'):continue
  ports=cell['connections']
  if ports['CE']==['1']:continue
  key=(cell['type'],tuple(ports['CLK']),tuple(ports['CE']),tuple(ports.get('RESET',[])))
  groups[key].append(name)
 nextbit=max(bit for cell in cells.values() for bits in cell['connections'].values() for bit in bits if isinstance(bit,int))+1
 changed=[]
 for names in groups.values():
  if len(names)>limit:continue
  for name in names:
   cell=cells[name];old=cell['type'];ports=cell['connections'];mux=name+'.enable_mux'
   assert mux not in cells
   connections={'I0':ports['D'],'I1':ports['CE'],'I2':ports['Q'],'F':[nextbit]}
   if old=='DFFRE':connections['I3']=ports['RESET']
   cells[mux]={'hide_name':1,'type':'LUT4' if old=='DFFRE' else 'LUT3',
    'parameters':{'INIT':table(old=='DFFRE')},'attributes':{'nanoblast_enable_mux':'1'},
    'port_directions':{key:'output' if key=='F' else 'input'for key in connections},'connections':connections}
   cell['type']='DFF';cell['connections']={'CLK':ports['CLK'],'D':[nextbit],'Q':ports['Q']}
   cell['port_directions']={'CLK':'input','D':'input','Q':'output'}
   changed.append({'cell':name,'original_type':old,'group_size':len(names)});nextbit+=1
 return changed

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('source',type=Path);p.add_argument('target',type=Path);p.add_argument('--limit',type=int,default=2);a=p.parse_args()
 data=a.source.read_bytes();net=json.loads(data);changed=transform(net,a.limit)
 a.target.write_text(json.dumps(net)+'\n')
 a.target.with_suffix('.control-sets.json').write_text(json.dumps({'source_sha256':hashlib.sha256(data).hexdigest(),'result_sha256':hashlib.sha256(a.target.read_bytes()).hexdigest(),'changed':changed},indent=2)+'\n')
 print(f'Remapped {len(changed)} sparsely enabled registers, preserving their next-state truth tables')
