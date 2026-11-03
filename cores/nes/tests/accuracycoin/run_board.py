#!/usr/bin/env python3
"""AccuracyCoin with the real shared SDRAM controller and an ideal CL2/BL1 chip.

Unlike the fast standalone fixture, CPU and PPU requests contend for the same
production controller. Models 64.8/21.6 MHz clocks and the forwarded 10/16 phase.
The chip model checks digital scheduling, not routed or analog I/O timing.
"""
import argparse, json, subprocess, os
from board_build import build
from pathlib import Path

HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('rom',type=Path)
p.add_argument('--rtl',type=Path,default=HERE.parents[1]/'src')
p.add_argument('--out',type=Path,required=True)
p.add_argument('--verilator',default='verilator')
p.add_argument('--frames',type=int,default=5500)
p.add_argument('--region-reloads',action='store_true',help='Four menu-paused NTSC/PAL ROM reloads before testing')
p.add_argument('--render-only',action='store_true',help='Check initial rendered menu without starting the tests')
a=p.parse_args();a.out=a.out.resolve();a.rtl=a.rtl.resolve();a.rom=a.rom.resolve()
if a.frames<1:p.error('--frames must be positive')
a.out.mkdir(parents=True,exist_ok=True)
rom=a.rom.read_bytes()
if len(rom)!=40976 or rom[:6]!=b'NES\x1a\x02\x01':p.error('Expected the 147-test AccuracyCoin NROM-256 ROM')
simulator, manifest = build(a.rom, a.rtl, a.out, a.verilator)
with (a.out/'run.log').open('w') as log:
    subprocess.run([str(simulator),str(a.rom),str(min(a.frames,410 if a.region_reloads else 90) if a.render_only else a.frames)],env=dict(os.environ, **({'REGION_RELOAD_TEST':'1'} if a.region_reloads else {})),cwd=a.out,stdout=log,stderr=subprocess.STDOUT,check=True)
rendering=json.loads((a.out/'rendering.json').read_text())
ram=(a.out/'ram.bin').read_bytes();prg=rom[16:32784]
start=prg.index(b'ROM is not writable');end=prg.index(b'Misaligned OAM2 Address')+len(b'Misaligned OAM2 Address')+5
addresses=sorted({0x400+prg[i+1] for i in range(start,end-4) if prg[i]==255 and prg[i+2]==4 and prg[i+4]>=128})
assert len(addresses)==147
results={f'${n:04X}':ram[n] for n in addresses}
passed=sum(v&3==1 for v in results.values())
summary=dict(**manifest,rendering=rendering,scope='initial rendering' if a.render_only else 'full ROM with production shared SDRAM controller',physical_board_pass=False,region_reloads=a.region_reloads,passed=passed,total=147,rom_tally=ram[0x37],rom_pass_tally=ram[0x38],results=results)
(a.out/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
print(f"Shared SDRAM: {passed}/147; ROM {ram[0x38]}/{ram[0x37]}; initial rendering {rendering}")
assert rendering['samples']>0 and rendering['stale_bytes']==0,'Rendering consumed stale SDRAM data'
if not a.render_only:assert passed==147 and ram[0x37]==ram[0x38]==147,'AccuracyCoin did not fully pass'
