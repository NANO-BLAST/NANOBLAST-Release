"""Established native macOS Yosys/nextpnr flow for SMS/Game Gear. No board access."""
from pathlib import Path
import os,subprocess,json,sys
P=Path(__file__).resolve().parent;B=P/'build-oss';B.mkdir(exist_ok=True);T=Path('/private/tmp/nanoblast-native-oss');SDK=Path('work/oss-cad-suite')
env={**os.environ,'DYLD_LIBRARY_PATH':str(T/'lib'),'YOSYS_DATDIR':str(SDK/'share/yosys'),'PYTHONHOME':str(SDK),'PYTHONNOUSERSITE':'1','PATH':str(T/'libexec')+':'+os.environ['PATH']}
files=[*sorted((P/'engine').rglob('*.v')),*sorted((P/'engine').rglob('*.sv')),*sorted((P/'rtl').glob('*.v')),*sorted((P/'rtl').glob('*.sv')),*sorted((P/'shared').rglob('*.v')),*sorted((P/'shared').rglob('*.sv'))]
excluded=['sms_nano_pll.v','gowin_pll_hdmi.v','gowin_dpb_menu.v'];files=[f for f in files if f.name not in excluded]
(B/'sources.f').write_text('\n'.join(map(str,files))+'\n')
script=f'''read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v;
read_verilog {P}/opll.v {P}/rtl/sms_nano_pll.v {P}/shared/nano20k/gowin_pll_hdmi.v {P}/shared/iosys/gowin_dpb_menu.v;
read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV --top sms_nano_top -v {P}/gowin-slang-primitives.v -f {B}/sources.f;
synth_gowin -family gw2a -top sms_nano_top -run begin:begin; blackbox ELVDS_OBUF;
synth_gowin -family gw2a -top sms_nano_top -run coarse:map_luts; sort;
read_verilog -icells -lib -specify +/abc9_model.v; abc9 -exe {T}/libexec/yosys-abc -maxlut 4 -W 500; clean;
synth_gowin -family gw2a -top sms_nano_top -run map_cells: -json {B}/sms-gg.json; check -assert;
'''
(B/'synthesis.ys').write_text(script)
if '--route-only' not in sys.argv:
 with (B/'synthesis.log').open('w') as log:subprocess.run([str(T/'libexec/yosys'),'-Q','-m',str(T/'share/yosys/plugins/slang.so'),'-s',str(B/'synthesis.ys')],cwd=P,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
print('Native SMS/GG synthesis passed',flush=True)
clocks=B/'clocks.py';clocks.write_text("ctx.addClock('sys_clk',27.0)\nctx.addClock('backdrop.clk',64.8)\nctx.addClock('main_pll.clkoutp',64.8)\nctx.addClock('backdrop.hclk',74.25)\nctx.addClock('hclk5',371.25)\n")
with (B/'route.log').open('w') as log:subprocess.run([str(T/'libexec/nextpnr-himbaechel'),'--seed','2','--device','GW2AR-LV18QN88C8/I7','--vopt','family=GW2A-18C','--vopt','cst='+str(P/'constraints/board.cst'),'--json',str(B/'sms-gg.json'),'--pre-pack',str(clocks),'--write',str(B/'routed.json'),'--report',str(B/'timing.json')],cwd=P,env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
fmax=json.loads((B/'timing.json').read_text())['fmax'];assert fmax and all(v['achieved']>=v['constraint'] for v in fmax.values()),fmax
print('Native SMS/GG placement/routing timing passed',json.dumps(fmax),flush=True)
