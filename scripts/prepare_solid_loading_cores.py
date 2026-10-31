"""Prepare NES/SMS/SNES builds from existing local NanoBlast build inputs.
Game Boy uses its pinned self-contained source archive and build_native.py --all.
All original inputs are read-only; build outputs go under hardware-tests/.
"""
from pathlib import Path
import re,shutil,json,hashlib,argparse,zipfile,subprocess,sys
p=argparse.ArgumentParser(description="Prepare isolated builds; never writes source workspace or hardware")
p.add_argument("source_workspace",type=Path);p.add_argument('--output',type=Path);p.add_argument('--no-pipeline-snes',dest='pipeline_snes',action='store_false');p.add_argument('--snes-route',type=int,choices=[0,1,2],default=2);args=p.parse_args()
R=args.source_workspace.resolve();W=R/'work';O=(args.output or Path.cwd()/'hardware-tests/solid-loading').resolve();patch=Path.cwd()/'fpga/solid-loading/textdisp.v'
for core in ['nes','sms','snes','gb']:(O/core).mkdir(parents=True,exist_ok=True)
archive=R/'outputs/gb-mister-save-clock/source.zip'
assert hashlib.sha256(archive.read_bytes()).hexdigest()=='cc2c4b0099d103d43d816ee6e180eeebc3e4198019797b124d807d2d2688e2d6'
with zipfile.ZipFile(archive) as zipped:
 for entry in zipped.infolist():
  dest=(O/'gb'/entry.filename).resolve()
  assert dest.is_relative_to((O/'gb').resolve()) if hasattr(dest,'is_relative_to') else str(dest).startswith(str((O/'gb').resolve())+'/')
 zipped.extractall(O/'gb')
baseline='cb1a2d0e82346e539583aff3c6fe0d6c2f5703c08d07da606b9da39b7d47410c'
gb_renderer=O/'gb/shared/work/mister-menu-test/textdisp.v'
assert hashlib.sha256(gb_renderer.read_bytes()).hexdigest()==baseline
gb_renderer.write_bytes(patch.read_bytes())
assert hashlib.sha256((W/'nanoblast/src/iosys/textdisp.v').read_bytes()).hexdigest()==baseline
# Original input files are read only; build products use isolated directories.
ns=[]
for line in (W/'nanoblast-native-mcu.f').read_text().splitlines():
 if line.strip():
  p=(W/'nanoblast'/line).resolve();ns.append(str(patch if p.name=='textdisp.v' else p))
(O/'nes/sources.f').write_text('\n'.join(ns)+'\n')
s=(R/'outputs/menu-oled/nes-synthesis.ys').read_text();s=s.replace('src/nano20k/',str(W/'nanoblast/src/nano20k')+'/').replace('src/iosys/',str(W/'nanoblast/src/iosys')+'/').replace('../gowin-slang-primitives.v',str(W/'gowin-slang-primitives.v')).replace('../nanoblast-native-mcu.f',str(O/'nes/sources.f'));s=re.sub(r'-json [^;\n]+','-json '+str(O/'nes/nes.json'),s)
(O/'nes/synthesis.ys').write_text(s)
ss=[(W/'sms-vhdl'/line).resolve() for line in (W/'sms-core.f').read_text().splitlines() if line.strip()];ss += [p for p in sorted((W/'smstang/nanoblast/rtl').glob('*')) if p.suffix in ['.v','.sv'] and p.name!='sms_nano_pll.v']
shared=['cdc_mailbox.sv','reset_release.sv','menu_background.sv','controller_snes.v','controller_ds2.sv','dualshock_controller.v','hw_uart.v','iosys/textdisp.v','iosys/mcu_uart.v','iosys/nanoblast_iosys.sv','iosys/nanoblast_menu_link.sv','iosys/nanoblast_sd_spi.sv']
ss += [patch if Path(f).name=='textdisp.v' else W/'nanoblast/src'/f for f in shared];ss += sorted((W/'nanoblast/src/hdmi2').glob('*.sv'))
(O/'sms/sources.f').write_text('\n'.join(map(str,ss))+'\n')
cmd=f'''read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v;
read_verilog {W}/sms-vhdl/opll.v {W}/smstang/nanoblast/rtl/sms_nano_pll.v {W}/nanoblast/src/nano20k/gowin_pll_hdmi.v {W}/nanoblast/src/iosys/gowin_dpb_menu.v;
read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV --top sms_nano_top -v {W}/gowin-slang-primitives.v -f {O}/sms/sources.f;
synth_gowin -family gw2a -top sms_nano_top -run begin:begin; blackbox ELVDS_OBUF;
synth_gowin -family gw2a -top sms_nano_top -run coarse:map_luts; sort;
read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut 4 -W 500; clean;
synth_gowin -family gw2a -top sms_nano_top -run map_cells: -json {O}/sms/sms.json; check -assert'''
(O/'sms/synthesis.ys').write_text(cmd+'\n')
tcl=(R/'outputs/menu-all-cores/snes/build.tcl').read_text();old=str(R/'outputs/menu-all-cores/snes');tcl=tcl.replace(old,str(O/'snes'))
for path in re.findall(r'add_file -type verilog \{([^}]+)\}',tcl):
 if Path(path).name=='textdisp.v':tcl=tcl.replace(path,str(patch))
for p in (R/'outputs/menu-all-cores/snes').glob('*'):
 if p.is_file() and p.suffix in ['.hex','.cst','.sdc','.v','.sv']:
  shutil.copyfile(p,O/'snes'/p.name)
if args.pipeline_snes:
 renderer=O/'snes/solid_textdisp.v'
 subprocess.run([sys.executable,str(Path(__file__).with_name('pipeline_snes_solid_panel.py')),str(renderer)],check=True)
 tcl=tcl.replace(str(patch),str(renderer))
tcl=tcl.replace('set_option -route_option 1','set_option -route_option '+str(args.snes_route))
(O/'snes/build.tcl').write_text(tcl)
inputs={Path(path) for core in ['nes','sms'] for path in (O/core/'sources.f').read_text().splitlines()}
inputs.update(Path(path) for path in re.findall(r'add_file -type \w+ \{([^}]+)\}',tcl))
record={str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(inputs)}
record['gb-source-zip']=hashlib.sha256(archive.read_bytes()).hexdigest()
(O/'input-sha256.json').write_text(json.dumps(record,indent=2)+'\n')
print('Prepared isolated NES, SMS, GB and SNES builds',O)
