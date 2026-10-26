from pathlib import Path
import subprocess,os
P=Path(__file__).resolve().parent;B=P/'tests/build';B.mkdir(exist_ok=True);T=Path('/private/tmp/nanoblast-mister-simtools');env={**os.environ,'DYLD_LIBRARY_PATH':str(T/'lib'),'VERILATOR_ROOT':str(T/'share/verilator')}
engine=[P/'opll.v',*sorted((P/'engine').rglob('*.v')),*sorted((P/'engine').rglob('*.sv')),P/'rtl/sms_nano_core.sv',P/'rtl/sms_nano_raster.v']
for name in ['core','gamegear_core']:
 files=engine+[P/'tests'/(name+'_tb.sv')];out=B/name
 with (B/(name+'-build.log')).open('w') as log:subprocess.run([str(T/'verilator_bin'),'--binary','--assert','--timing','-Wno-fatal','-j','4','--top-module',name+'_tb','--Mdir',str(out),*map(str,files)],cwd=P,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
 with (B/(name+'-test.log')).open('w') as log:subprocess.run([str(out/('V'+name+'_tb')),'+ROM='+str(P/'NANOBLAST Game Gear Test.gg')],cwd=P,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
 print((B/(name+'-test.log')).read_text(),flush=True)
