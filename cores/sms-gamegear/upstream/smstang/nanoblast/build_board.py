"""Build the complete Nano20K SMS board RTL using the native macOS toolchain."""
from pathlib import Path
import subprocess,json,argparse
p=argparse.ArgumentParser();p.add_argument('--maxlut',type=int,choices=[4,5,6],default=6);p.add_argument('--out',default='outputs/sms-nano-integration');args=p.parse_args()
work=Path(__file__).resolve().parents[2];out=work.parent/args.out;out.mkdir(parents=True,exist_ok=True)
port=work/'smstang/nanoblast'
sources=[str((work/'sms-vhdl'/line).resolve()) for line in (work/'sms-core.f').read_text().splitlines() if line.strip()]
sources += [str(p) for p in sorted((port/'rtl').glob('*')) if p.suffix in ['.v','.sv'] and p.name!='sms_nano_pll.v']
shared=['cdc_mailbox.sv','reset_release.sv','menu_background.sv','controller_snes.v','controller_ds2.sv','dualshock_controller.v','hw_uart.v','iosys/textdisp.v','iosys/mcu_uart.v','iosys/nanoblast_iosys.sv','iosys/nanoblast_menu_link.sv','iosys/nanoblast_sd_spi.sv']
sources += [str(work/'nanoblast/src'/f) for f in shared]
sources += [str(p) for p in sorted((work/'nanoblast/src/hdmi2').glob('*.sv'))]
(out/'sources.f').write_text('\n'.join(sources)+'\n')
top='sms_nano_top'
cmd=f'''read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v;
read_verilog {work}/sms-vhdl/opll.v {port}/rtl/sms_nano_pll.v {work}/nanoblast/src/nano20k/gowin_pll_hdmi.v {work}/nanoblast/src/iosys/gowin_dpb_menu.v;
read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV --top {top} -v {work}/gowin-slang-primitives.v -f {out}/sources.f;
synth_gowin -family gw2a -top {top} -run begin:begin; blackbox ELVDS_OBUF;
synth_gowin -family gw2a -top {top} -run coarse:map_luts; sort;
read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut {args.maxlut} -W 500; clean;
synth_gowin -family gw2a -top {top} -run map_cells: -json {out}/sms-nano.json; check -assert'''
(out/'synthesis.ys').write_text(cmd+'\n')
with (out/'synthesis.log').open('w') as log:
 subprocess.run([str(work/'oss-cad-suite/bin/yosys'),'-Q','-m','slang','-s',str(out/'synthesis.ys')],cwd=work/'nanoblast',stdout=log,stderr=subprocess.STDOUT,check=True)
net=json.loads((out/'sms-nano.json').read_text())['modules'][top]
counts={}
for c in net['cells'].values():counts[c['type']]=counts.get(c['type'],0)+1
(out/'resources.json').write_text(json.dumps(counts,indent=2)+'\n')
print('Native full-board synthesis PASS',counts)
