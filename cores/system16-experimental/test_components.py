#!/usr/bin/env python3
"""Simulate the word adapter/controller against the independent x32 SDR model."""
import argparse
from pathlib import Path
import subprocess
import tempfile
p=argparse.ArgumentParser()
p.add_argument('--iverilog',default='iverilog')
p.add_argument('--iverilog-base')
p.add_argument('--vvp',default='vvp')
p.add_argument('--fir-coeff',type=Path,help='Generated 512-word FIR hex, to compare the optimized filter with upstream')
p.add_argument('--upstream',type=Path,help='Pinned JT checkout, to test against its actual caches')
a=p.parse_args()
r=Path(__file__).resolve().parent
tests = [
    ('burst_tb', ['rtl/s16_sdram32_burst.sv','tests/burst_tb.sv']),
    ('video_dma_tb', ['rtl/s16_frame_swap.sv','rtl/s16_video_dma.sv','tests/video_dma_tb.sv']),
    ('memory_tb', ['rtl/s16_word_arbiter.sv','rtl/s16_sdram32.sv','tests/memory_tb.sv']),
    ('frame_swap_tb', ['rtl/s16_frame_swap.sv','tests/frame_swap_tb.sv']),
]
tests = [(top,[r/f for f in files]) for top,files in tests]
if a.upstream:
    upstream=a.upstream.resolve()
    commit=subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True).strip()
    if commit!='7637835e6b3656c5897bff7c4c421902c27fe7fb':
        raise SystemExit('The upstream cache test needs the pinned JT revision')
    cache=upstream/'modules/jtframe/hdl/sdram'
    tests.append(('jtframe_bank_tb', [r/'rtl/s16_jtframe_bank_bridge.sv',r/'tests/jtframe_bank_tb.sv']+
                  [cache/f for f in ['jtframe_rom_3slots.v','jtframe_romrq.v','jtframe_romrq_bcache.v','jtframe_romrq_lcache.v','jtframe_romrq_xscache.v','jtframe_ramslot_ctrl.v']]))
    tests[-1][1].extend(upstream/'modules/jtframe/hdl/ram'/f for f in ['jtframe_rpwp_ram.v','jtframe_dual_ram.v','jtframe_ram.v'])
for top,files in tests:
    with tempfile.TemporaryDirectory(prefix='nanoblast-s16-') as d:
        exe=Path(d)/(top+'.vvp')
        command=[a.iverilog]
        if a.iverilog_base: command+=['-B',a.iverilog_base]
        command+=['-g2012','-s',top,'-o',str(exe)]+[str(f) for f in files]
        subprocess.run(command,check=True)
        subprocess.run([a.vvp,str(exe)],check=True)
        if top=='jtframe_bank_tb':
            subprocess.run(command[:1]+['-Pjtframe_bank_tb.TAG_RAM=1']+command[1:],check=True)
            subprocess.run([a.vvp,str(exe)],check=True)

if a.fir_coeff:
    if not a.upstream:
        raise SystemExit('--fir-coeff also needs --upstream')
    import shutil
    words=a.fir_coeff.read_text().split()
    if len(words)!=512: raise SystemExit('Expected 512-word FIR initialization')
    with tempfile.TemporaryDirectory(prefix='nanoblast-s16-fir-') as d:
        work=Path(d)
        shutil.copyfile(a.fir_coeff,work/'fir_192k_4k.hex')
        for suffix,start in [('coeff',0),('left',128),('right',256)]:
            (work/('fir_192k_4k.hex.'+suffix)).write_text('\n'.join(words[start:start+128])+'\n')
        reference=(a.upstream/'modules/jtframe/hdl/sound/jtframe_fir.v').read_text()
        reference=reference.replace('module jtframe_fir(', 'module jtframe_fir_reference(')
        (work/'reference.v').write_text(reference)
        command=[a.iverilog]
        if a.iverilog_base: command+=['-B',a.iverilog_base]
        command+=['-g2012','-s','fir_equivalence_tb','-o',str(work/'fir.vvp'),str(r/'rtl/jtframe_fir_gowin.v'),str(r/'tests/fir_equivalence_tb.sv'),str(work/'reference.v')]
        subprocess.run(command,check=True,cwd=work)
        subprocess.run([a.vvp,str(work/'fir.vvp')],check=True,cwd=work)
