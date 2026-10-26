"""Native host/RTL checks for the NANOBLAST save/clock candidate; no board access."""
from pathlib import Path
import os,subprocess,tempfile,argparse
P=Path(__file__).resolve().parent
A=argparse.ArgumentParser();A.add_argument('--firmware',type=Path,default=P.parents[1]/'firmware');A.add_argument('--tools',type=Path,default=Path('/private/tmp/nanoblast-mister-simtools'));a=A.parse_args()
F=a.firmware.resolve();T=a.tools.resolve();env={**os.environ,'DYLD_LIBRARY_PATH':str(T/'lib')}
with tempfile.TemporaryDirectory(prefix='save-clock-checks-') as d:
 B=Path(d)
 for name,sources in [('persistence',['tests/persistence_test.cpp']),('clock_menu',['ui/nanoblast_menu.cpp','tests/clock_menu_test.cpp']),('save_transport',['tests/save_transport_test.cpp']),('gb_loader',['tests/gb_loader_test.cpp'])]:
  out=B/name;subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I'+str(F/'storage'),*[str(F/s) for s in sources],'-o',str(out)],check=True);subprocess.run([str(out)],check=True);print('PASS '+name,flush=True)
 for name,sources in [('save',[P/'rtl/nanoblast_gb_save.sv']),('save_rtc',[P/'rtl/nanoblast_gb_save.sv',P/'engine/mappers/mbc3.v']),('save_link',[P/'rtl/nanoblast_gb_save.sv',P/'shared/work/nanoblast/src/iosys/nanoblast_menu_link.sv',P/'shared/work/nanoblast/src/iosys/nanoblast_sd_spi.sv']),('tmds_equivalence',[P/'tests/tmds_reference.sv',P/'shared/work/nanoblast/src/hdmi2/tmds_channel.sv'])]:
  out=B/(name+'.vvp');subprocess.run([str(T/'iverilog'),'-B'+str(T/'ivl'),'-g2012','-gno-strict-declaration','-s',name+'_tb','-o',str(out),*[str(s) for s in sources],str(P/'tests'/(name+'_tb.sv'))],env=env,check=True);subprocess.run([str(T/'vvp'),str(out)],env=env,check=True)
print('PASS all save/clock host and RTL checks; physical board test pending.')
