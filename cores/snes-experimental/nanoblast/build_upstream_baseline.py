"""Measure upstream Nano20K with the same native compiler, without NANOBLAST logic.
Creates an isolated copy and applies compiler-compatibility changes only.
"""
from pathlib import Path
import shutil,re,subprocess,json
base=Path(__file__).resolve().parents[3];work=base/'work';ref=work/'snestang-switch-reference'
out=base/'outputs/snes-upstream-baseline';root=out/'source';out.mkdir(parents=True,exist_ok=True)
shutil.copytree(ref/'src',root/'src',dirs_exist_ok=True)
config='`define MCU_BL616\n'+(ref/'src/boards/nano20k.v').read_text();(out/'config.v').write_text(config)
# Same parser compatibility edits as the integration; no emulation changes.
p=root/'src/chip/DSP/DSPn.v';s=re.sub(r'always @\(OP_ALU,\s*P,\s*Q,\s*ALU_R,\s*FLAGS,\s*OP_A\)', 'always @*',p.read_text()).replace('"dsp11b23410_','"src/chip/DSP/dsp11b23410_');p.write_text(s)
for name in ['dsp.v','smp.v','spc700/spc700.v']:
 p=root/'src'/name;s=p.read_text();s=re.sub(r'^(\s*)(\$fdisplay\([^\n]*;)',r'\1`ifdef VERILATOR\n\1\2\n\1`else\n\1;\n\1`endif',s,flags=re.M);p.write_text(s)
p=root/'src/iosys/iosys_bl616.v';s=re.sub(r'input reg\s+\[7:0\] kbd_data', 'output reg [7:0] kbd_data',p.read_text());p.write_text(s)
p=root/'src/hdmi2/hdmi.sv';p.write_text(p.read_text().replace("                control_data = 6'd0","                control_data <= 6'd0"))
p=root/'src/hdmi2/packet_picker.sv';p.write_text(p.read_text().replace("frame_counter <= 8'd0","frame_counter = 8'd0"))
p=root/'src/snestang_top.v';s=re.sub(r'reg\s+PAL;',"wire PAL=1'b0;",p.read_text()).replace('.rv_addr(), .rv_din(),',".rv_addr(22'd0), .rv_din(16'd0),").replace('.rv_ds(), .rv_dout(), .rv_req(), .rv_req_ack(), .rv_we()',".rv_ds(2'd0), .rv_dout(), .rv_req(1'b0), .rv_req_ack(), .rv_we(1'b0)");p.write_text(s)
files=re.findall(r'^add_file -type verilog "([^"]+)"',(ref/'build.tcl').read_text(),re.M)
files=files[files.index('src/iosys/iosys_bl616.v'):]
exclude={'gowin_dpb_menu.v','gowin_dpb_cgram.v','gowin_dpb_hoam.v','gowin_dpb_oam.v','dsp_data_ram.v'}
sources=[out/'config.v']+[root/f for f in files if Path(f).name not in exclude]+[root/'src/sdram_nano.v',root/'src/snes2hdmi_nano.v']
(out/'sources.f').write_text('\n'.join(map(str,sources))+'\n')
wrappers=[root/'src'/f for f in ['pllr/gowin_pll_snes.v','pllr/gowin_pll_hdmi.v','iosys/gowin_dpb_menu.v','gowin_dpb_cgram.v','gowin_dpb_hoam.v','gowin_dpb_oam.v','chip/dsp/dsp_data_ram.v']]
cmd=f'''read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v;
read_verilog {' '.join(map(str,wrappers))};
read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV -I{root}/src -I{root}/src/spc700 --top snestang_top -v {work}/gowin-slang-primitives.v -f {out}/sources.f;
synth_gowin -family gw2a -top snestang_top -run begin:begin; blackbox ELVDS_OBUF;
synth_gowin -family gw2a -top snestang_top -run coarse:map_luts; sort;
read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut 6 -W 500; clean;
synth_gowin -family gw2a -top snestang_top -run map_cells: -json {out}/snes-nano.json; check -assert
'''
(out/'synthesis.ys').write_text(cmd)
with (out/'synthesis.log').open('w')as log:
 subprocess.run([str(work/'oss-cad-suite/bin/yosys'),'-Q','-m','slang','-s',str(out/'synthesis.ys')],cwd=root,stdout=log,stderr=subprocess.STDOUT,check=True)
net=json.loads((out/'snes-nano.json').read_text())['modules']['snestang_top'];counts={}
for c in net['cells'].values():counts[c['type']]=counts.get(c['type'],0)+1
(out/'resources.json').write_text(json.dumps(counts,indent=2)+'\n');print('Upstream baseline synthesis PASS',counts)
