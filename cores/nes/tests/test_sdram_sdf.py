"""Independent, hand-calculated fixture for the routed-budget parser."""
import json,subprocess,sys,tempfile
from pathlib import Path
def cell(kind,name,arcs,timing=''):
    return f'\n  (CELL\n (CELLTYPE "{kind}") (INSTANCE {name})\n'+''.join(
        f'(IOPATH {i} {o} ({d}:{d}:{d}))\n' for i,o,d in arcs)+timing+'\n )\n'
with tempfile.TemporaryDirectory() as tmp:
    out=Path(tmp);s='(DELAYFILE (TIMESCALE 1 ns)\n'
    s+=cell('IBUF','sys_clk_ibuf',[('I','O',1.0)])
    s+=cell('rPLL','pll_nes/rpll_inst',[('CLKIN','CLKOUT',0.0),('CLKIN','CLKOUTP',0.0)])
    s+=cell('OBUF','O_sdram_clk_obuf',[('I','O',0.3)])
    edges=[('sys_clk_ibuf/O','pll_nes/rpll_inst/CLKIN',0.0),
           ('pll_nes/rpll_inst/CLKOUTP','O_sdram_clk_obuf/I',0.2)]
    timing='(SETUPHOLD (posedge D) (posedge CLK) (0.1:0.1:0.1) (0.05:0.05:0.05))'
    for i in range(32):
        name=f'IO_sdram_dq_{i}_iobuf'
        s+=cell('IOBUF',name,[('I','IO',0.3),('IO','O',0.5)])
        reg=f'sdram/dq_out_{i}_s0';s+=cell('DFF',reg,[('CLK','Q',0.2)],timing)
        edges.extend([('pll_nes/rpll_inst/CLKOUT',reg+'/CLK',0.1),(reg+'/Q',name+'/I',0.4)])
    for i in range(64):
        reg=f'sdram/bg_data_{i}_s0';s+=cell('DFF',reg,[('CLK','Q',0.2)],timing)
        edges.extend([('pll_nes/rpll_inst/CLKOUT',reg+'/CLK',0.1),
                      (f'IO_sdram_dq_{i%32}_iobuf/O',reg+'/D',0.0)])
    s+='\n  (CELL\n (CELLTYPE "fixture") (INSTANCE )\n'
    for i,o,d in edges:s+=f'(INTERCONNECT {i} {o} ({d}:{d}:{d}))\n'
    s+=')\n)\n';(out/'fixture.sdf').write_text(s)
    subprocess.run([sys.executable,str(Path(__file__).with_name('audit_sdram_sdf.py')),
                    '--sdf',str(out/'fixture.sdf'),'--out',str(out/'result.json')],check=True,stdout=subprocess.DEVNULL)
    results=json.loads((out/'result.json').read_text())['results']
    # Clock=1.5ns, FF clock=1.1ns, read path=.5ns, write arrival=2ns.
    # These expectations include the common clock delay canceling correctly.
    period=1000/64.8;phase=period*10/16
    expected={'read_setup':period-phase+1.1-1.5-6.5-.5-.1,
              'read_hold':phase+1.5+.5-1.1-.05,
              'write_setup':phase+1.5-1.5-2.0,
              'write_hold':period+2.0-phase-1.5-1.0}
    for r in results:
        assert abs(r['forwarded_clock_latency_ns']-1.5)<1e-6
        for k,v in expected.items():assert abs(r[k]['slack_ns']-v)<1e-6,(k,r[k],v)
    print('PASS independent SDF fixture: forwarded clock, sequential boundaries, read/write setup/hold and all corners')
