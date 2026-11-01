#!/usr/bin/env python3
"""AccuracyCoin with the real shared SDRAM controller and an ideal CL2/BL1 chip.

Unlike the fast standalone fixture, CPU and PPU requests contend for the same
production controller. Models 64.8/21.6 MHz clocks and the forwarded 10/16 phase.
The chip model checks digital scheduling, not routed or analog I/O timing.
"""
import argparse, hashlib, json, subprocess
from pathlib import Path

HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('rom',type=Path)
p.add_argument('--rtl',type=Path,default=HERE.parents[1]/'src')
p.add_argument('--out',type=Path,required=True)
p.add_argument('--verilator',default='verilator')
p.add_argument('--frames',type=int,default=30)
p.add_argument('--render-only',action='store_true',help='Check initial rendered menu without starting the tests')
a=p.parse_args();a.out=a.out.resolve();a.rtl=a.rtl.resolve();a.rom=a.rom.resolve()
if not 1<=a.frames<=100:p.error('This regression covers initial rendering only: use 1 to 100 frames')
a.out.mkdir(parents=True,exist_ok=True)
rom=a.rom.read_bytes()
if len(rom)!=40976 or rom[:6]!=b'NES\x1a\x02\x01':p.error('Expected the 147-test AccuracyCoin NROM-256 ROM')
# Use production Nano SDRAM geometry and NANO lane selection. OAM uses its
# behavioral synchronous RAM implementation; this test changes no OAM logic.
config=a.out/'config.v'
config.write_text((a.rtl/'nano20k/config.v').read_text().replace('`define GW_IDE','// Behavioral OAM in this scheduling fixture'))
sources=[config,HERE/'board_memory.sv',a.rtl/'nes.v',a.rtl/'sdram_nes.v']
sources += [a.rtl/n for n in ['apu.v','ppu.v','dpram.v']]
sources += [a.rtl/'t65'/('T65'+n+'.v') for n in ['_Pack','_ALU','_MCode','']]
sources += [HERE/'nrom_fixture.sv',HERE/'board_main.cpp']
manifest=dict(source_sha256={str(s):hashlib.sha256(s.read_bytes()).hexdigest() for s in sources},rom_sha256=hashlib.sha256(rom).hexdigest())
(a.out/'inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
with (a.out/'build.log').open('w') as log:
    subprocess.run([a.verilator,'--cc','--exe','--build','-j','4','-CFLAGS','-O3','-Wno-fatal','--top-module','NESBoard','--Mdir',str(a.out/'obj'),*map(str,sources)],stdout=log,stderr=subprocess.STDOUT,check=True)
with (a.out/'run.log').open('w') as log:
    subprocess.run([str(a.out/'obj/VNESBoard'),str(a.rom),str(a.frames)],cwd=a.out,stdout=log,stderr=subprocess.STDOUT,check=True)
rendering=json.loads((a.out/'rendering.json').read_text())
summary=dict(**manifest,rendering=rendering,scope='initial menu rendering only',physical_board_pass=False)
(a.out/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
print(f"Shared SDRAM initial rendering: {rendering}")
assert rendering['samples']>0 and rendering['stale_bytes']==0,'Rendering consumed stale SDRAM data'
