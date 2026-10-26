"""Conditional SDRAM budgets from routed SDF, including forwarded clock.

Not device signoff: actual SiP timing/load/skew and PLL phase need confirmation.
Use consistent SDF best/nom/worst corners, not a zero-latency virtual clock.
Register arcs are excluded from combinational propagation. CLK->Q and setup/
hold are applied explicitly at launch/capture boundaries. No false paths.
"""
import argparse, collections, functools, hashlib, json, math, re
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--sdf',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--tac',type=float,default=6.5)
a=p.parse_args()
s=a.sdf.read_text()
if '(TIMESCALE 1 ns)' not in s: raise RuntimeError('Expected nanosecond SDF')
triple=r'\(([0-9.]+):([0-9.]+):([0-9.]+)\)'
def vector(m): return tuple(map(float,m))
def clean(x): return x.replace('\\','')
cells={}; arcs=[]
for block in s.split('\n  (CELL\n')[1:]:
    kind=re.search(r'\(CELLTYPE "([^"]+)"\)',block)
    inst=re.search(r'\(INSTANCE ([^)]*)\)',block)
    if not kind or not inst: continue
    name=clean(inst[1]);kind=kind[1]
    paths=[(clean(x),clean(y),vector(z)) for x,y,*z in
           re.findall(r'\(IOPATH (\S+) (\S+) '+triple,block)]
    setup=re.findall(r'\(SETUPHOLD \((?:posedge|negedge) D\) \(posedge CLK\) '+triple+r' '+triple,block)
    cells[name]={'type':kind,'paths':paths,'setup':setup}
    if not kind.startswith(('DFF','DPB','SDP','SP','ROM')):
        for x,y,v in paths: arcs.append((name+'/'+x,name+'/'+y,v))
for x,y,*v in re.findall(r'\(INTERCONNECT (\S+) (\S+) '+triple,s):
    arcs.append((clean(x),clean(y),vector(v)))
parents=collections.defaultdict(list)
for x,y,v in arcs: parents[y].append((x,v))

def propagate(roots,corner,maximum=True):
    visiting=set()
    @functools.lru_cache(None)
    def delay(node):
        if node in roots: return roots[node]
        if node in visiting: raise RuntimeError('Combinational cycle '+node)
        visiting.add(node)
        values=[]
        for previous,v in parents[node]:
            d=delay(previous)
            if d is not None: values.append(d+v[corner])
        visiting.remove(node)
        return (max(values) if maximum else min(values)) if values else None
    return delay

receive=[n for n,c in cells.items() if c['type'].startswith('DFF') and
         re.match(r'sdram/(dout[AB]|rv_dout|bg_data)_',n)]
send=[n for n,c in cells.items() if c['type'].startswith('DFF') and
      re.match(r'sdram/(cmd|a|SDRAM_BA|SDRAM_DQM|dq_out|dq_oen)_',n)]
inputs={n+'/IO':0.0 for n,c in cells.items() if n.startswith('IO_sdram_dq_') and c['type']=='IOBUF'}
outputs=[n+('/IO' if c['type']=='IOBUF' else '/O') for n,c in cells.items()
         if (n.startswith('IO_sdram_dq_') or n.startswith(('O_sdram_addr_','O_sdram_ba_','O_sdram_dqm_'))
             or n in ['O_sdram_cs_n_obuf','O_sdram_wen_n_obuf','O_sdram_ras_n_obuf','O_sdram_cas_n_obuf'])
         and c['type'] in ['IOBUF','OBUF']]
if len(inputs)!=32 or len(receive)!=64: raise RuntimeError(f'Unexpected read coverage: {len(inputs)}/{len(receive)}')
period=1000/64.8;phase=period*10/16
results=[]
for corner,label in enumerate(['best','nominal','worst']):
    clock=propagate({'sys_clk_ibuf/I':0.0},corner)
    forwarded=clock('O_sdram_clk_obuf/O')
    if forwarded is None: raise RuntimeError('Forwarded clock output is not reachable')
    incoming_max=propagate(inputs,corner)
    incoming_min=propagate(inputs,corner,False)
    read_setup=[];read_hold=[]
    for n in receive:
        c=cells[n]; timing=c['setup']
        if not timing: raise RuntimeError('Missing capture timing '+n)
        setup=max(float(t[corner]) for t in timing)
        hold=max(float(t[corner+3]) for t in timing)
        capture=clock(n+'/CLK'); maximum=incoming_max(n+'/D');minimum=incoming_min(n+'/D')
        if None in [capture,maximum,minimum]: raise RuntimeError('Missing receive path '+n)
        # Every CL2 read capture is three FCLKs after the READ register:
        # one FCLK after the RAM output edge, less the forwarded phase.
        read_setup.append((period-phase+capture-forwarded-a.tac-maximum-setup,n))
        # BL1 high-Z entry has no specified minimum tHZ: use zero, rather
        # than assuming the data-to-data tOH guarantee also covers high-Z.
        read_hold.append((phase+forwarded+minimum-capture-hold,n))
    roots={}
    for n in send:
        cq=[v[corner] for x,y,v in cells[n]['paths'] if x=='CLK' and y=='Q']
        if not cq or clock(n+'/CLK') is None: raise RuntimeError('Missing launch path '+n)
        roots[n+'/Q']=clock(n+'/CLK')+max(cq)
    outgoing_max=propagate(roots,corner);outgoing_min=propagate(roots,corner,False)
    write_setup=[];write_hold=[]
    for n in outputs:
        maximum=outgoing_max(n);minimum=outgoing_min(n)
        if maximum is None: raise RuntimeError('Missing output path '+n)
        write_setup.append((phase+forwarded-1.5-maximum,n))
        write_hold.append((period+minimum-phase-forwarded-1.0,n))
    def worst(rows):
        slack,node=min(rows)
        return {'slack_ns':round(slack,6),'endpoint':node,'endpoints_checked':len(rows)}
    results.append({'corner':label,'forwarded_clock_latency_ns':round(forwarded,6),
        'read_setup':worst(read_setup),'read_hold':worst(read_hold),
        'write_setup':worst(write_setup),'write_hold':worst(write_hold)})
report={'conditional_only':True,'sdf_sha256':hashlib.sha256(a.sdf.read_bytes()).hexdigest(),
        'fclk_mhz':64.8,'forwarded_phase_ns':phase,'reference_tac_ns':a.tac,
        'assumptions':['Etron -7 reference, actual SiP unverified','SDF I/O loading model, no additional inter-die skew',
                       'Consistent SDF corners; no extra OCV or PLL jitter allowance',
                       'CL2/BL1 capture schedule; conservative zero minimum high-Z-entry delay'],
        'results':results}
a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(results,indent=2))
