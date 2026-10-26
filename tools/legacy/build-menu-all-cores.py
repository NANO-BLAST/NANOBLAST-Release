import subprocess,sys
from pathlib import Path
r=Path.cwd();out=r/'outputs/menu-all-cores';core=sys.argv[1];d=out/core;d.mkdir(exist_ok=True)
if core=='nes':
 synth=[str(r/'work/oss-cad-suite/bin/yosys'),'-Q','-m','slang','-s',str(out/'nes-synthesis.ys')];cwd=r/'work/nanoblast';net=d/'nes.json';clocks=r/'work/nanoblast-clocks.py'
else:
 synth=['python3',str(r/'work/smstang/nanoblast/build_board.py'),'--maxlut','4','--out','outputs/menu-all-cores/sms'];cwd=r;net=d/'sms-nano.json';clocks=r/'work/smstang/nanoblast/clocks.py'
with (d/'synthesis-driver.log').open('w') as log:subprocess.run(synth,cwd=cwd,stdout=log,stderr=subprocess.STDOUT,check=True)
cmd=[str(r/'work/oss-cad-suite/bin/nextpnr-himbaechel'),'--seed','2','--device','GW2AR-LV18QN88C8/I7','--vopt','family=GW2A-18C','--vopt',f'cst={r}/work/nanoblast-native.cst','--json',str(net),'--pre-pack',str(clocks),'--write',str(d/(core+'-pnr.json')),'--report',str(d/'timing.json')]
with (d/'pnr.log').open('w') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True)
subprocess.run(['python3','work/finalize-direct-switch.py','--core',core,'--out',str(out)],check=True)
