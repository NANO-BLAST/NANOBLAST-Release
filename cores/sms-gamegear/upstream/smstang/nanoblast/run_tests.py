"""Run focused Nano memory and real-SMS-engine simulations, without USB access."""
from pathlib import Path
import subprocess
work=Path(__file__).resolve().parents[2]
port=work/'smstang/nanoblast';out=work.parent/'outputs/sms-nano-start';out.mkdir(parents=True,exist_ok=True)
iverilog=work/'oss-cad-suite/bin/iverilog';vvp=work/'oss-cad-suite/bin/vvp'
sources=[str((work/'sms-vhdl'/p).resolve()) for p in (work/'sms-core.f').read_text().splitlines() if p.strip()]
core_sources=[work/'sms-vhdl/opll.v',*sources,port/'rtl/sms_nano_raster.v',port/'rtl/sms_nano_core.sv']
for target,files in [('loader',[port/'rtl/sms_nano_memory.sv',port/'tests/loader_tb.sv']),('video',[port/'rtl/sms_nano_hdmi.sv',work/'nanoblast/src/cdc_mailbox.sv',port/'tests/video_tb.sv']),('control',[port/'rtl/sms_nano_ce.sv',work/'smstang/src/dpram.v',port/'tests/control_tb.sv']),('integration',[*core_sources,port/'rtl/sms_nano_memory.sv',port/'rtl/sms_nano_ce.sv',port/'tests/integration_tb.sv']),('sdram',[port/'rtl/sms_nano_sdram.sv',port/'tests/sdram_tb.sv']),('core',[work/'sms-vhdl/opll.v',*sources,port/'rtl/sms_nano_raster.v',port/'rtl/sms_nano_core.sv',port/'tests/core_tb.sv'])]:
 with (out/f'{target}-simulation.log').open('w') as log:
  if target in ['core','integration']:
   command=[str(work/'oss-cad-suite/bin/verilator'),'--binary','--assert','--timing','-Wno-fatal','-j','4','--top-module',target+'_tb','--Mdir',str(out/('verilator-'+target)),'-o',target+'_tb',*map(str,files)]
   executable=out/('verilator-'+target)/(target+'_tb')
  else:
   command=[str(iverilog),'-g2012','-s',target+'_tb','-o',str(out/(target+'_tb')),*map(str,files)]
   executable=None
  subprocess.run(command,cwd=work/'smstang/src',stdout=log,stderr=subprocess.STDOUT,check=True)
  subprocess.run([str(executable)] if executable else [str(vvp),str(out/(target+'_tb'))],cwd=work/'smstang/src',stdout=log,stderr=subprocess.STDOUT,check=True)
 print((out/f'{target}-simulation.log').read_text().splitlines()[-2:])
