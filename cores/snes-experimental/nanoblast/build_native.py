from pathlib import Path
import argparse,re,subprocess,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--noce',action='store_true');p.add_argument('--coarse-only',action='store_true');p.add_argument('--effort',action='store_true');p.add_argument('--small-alu-luts',action='store_true');p.add_argument('--share',action='store_true');p.add_argument('--share-arithmetic',action='store_true');p.add_argument('--hierarchical',action='store_true');p.add_argument('--noalu',action='store_true');p.add_argument('--area',action='store_true');p.add_argument('--classic',action='store_true');p.add_argument('--no-dsp',action='store_true');p.add_argument('--maxlut',type=int,choices=[4,5,6,7,8],default=6);p.add_argument('--out',default='outputs/snes-nano-integration');a=p.parse_args()
root=Path(__file__).resolve().parents[1];work=root.parent;out=(work.parent/a.out).resolve();out.mkdir(parents=True,exist_ok=True)
config=(root/'nanoblast/config.v').read_text()
if a.no_dsp:config=config.replace('`define CHIP_DSPn','// DSP cartridge expansion omitted in this build')
(out/'config.v').write_text(config)
sources=[out/'config.v']
files=re.findall(r'^add_file -type verilog "([^"]+)"',(root/'build.tcl').read_text(),re.M)
# Take only common sources, following the board-specific branches.
files=files[files.index('src/iosys/iosys_bl616.v'):]
exclude={'iosys_bl616.v','uart_fractional.v','textdisp.v','uart_fixed.v','crc16.v','gowin_dpb_menu.v','gowin_dpb_cgram.v','gowin_dpb_hoam.v','gowin_dpb_oam.v','dsp_data_ram.v'}
sources += [root/f for f in files if Path(f).name not in exclude and not f.startswith('src/hdmi2/')]
sources += [root/'nanoblast/hdmi/packet_picker.sv' if f.name=='packet_picker.sv' else f for f in sorted((work/'nanoblast/src/hdmi2').glob('*.sv'))]
sources += [root/'src/sdram_nano.v',root/'src/snes2hdmi_nano.v']
sources += [work/'nanoblast/src'/f for f in ['menu_background.sv','cdc_mailbox.sv','reset_release.sv','hw_uart.v','iosys/mcu_uart.v','iosys/textdisp.v','iosys/nanoblast_iosys.sv','iosys/nanoblast_menu_link.sv','iosys/nanoblast_sd_spi.sv']]
assert all(f.is_file() for f in sources),[f for f in sources if not f.is_file()]
(out/'sources.f').write_text('\n'.join(map(str,sources))+'\n')
wrappers=[root/'src/pllr/gowin_pll_snes.v',root/'src/pllr/gowin_pll_hdmi.v',work/'nanoblast/src/iosys/gowin_dpb_menu.v',*[root/'src'/f for f in ['gowin_dpb_cgram.v','gowin_dpb_hoam.v','gowin_dpb_oam.v','chip/dsp/dsp_data_ram.v']]]
cmd=f'''read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v;
read_verilog {' '.join(map(str,wrappers))};
read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV -I{root}/src -I{root}/src/spc700 --top snestang_top -v {work}/gowin-slang-primitives.v -f {out}/sources.f;
synth_gowin -family gw2a -top snestang_top -run begin:begin; blackbox ELVDS_OBUF;
synth_gowin -family gw2a -top snestang_top -run coarse:map_luts; sort;
read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut {a.maxlut} -W 500; clean;
synth_gowin -family gw2a -top snestang_top -run map_cells: -json {out}/snes-nano.json; check -assert
'''
if a.small_alu_luts:
 cmd=cmd.replace('synth_gowin -family gw2a -top snestang_top -run coarse:map_luts;', 'synth_gowin -family gw2a -top snestang_top -run coarse:map_gates; techmap -map +/gowin/arith_map.v t:$alu r:Y_WIDTH>=16 %i; synth_gowin -noalu -family gw2a -top snestang_top -run map_gates:map_luts;')
if a.share:
 cmd=cmd.replace('synth_gowin -family gw2a -top snestang_top -run coarse:map_luts;', 'synth_gowin -family gw2a -top snestang_top -run coarse:map_ram; share -aggressive; opt; synth_gowin -family gw2a -top snestang_top -run map_ram:map_luts;')
if a.share_arithmetic:
 cmd=cmd.replace('synth_gowin -family gw2a -top snestang_top -run coarse:map_luts;', 'synth_gowin -family gw2a -top snestang_top -run coarse:map_ram; share -aggressive -pattern-limit 32 -limit 500 t:$add t:$sub; opt -full; synth_gowin -family gw2a -top snestang_top -run map_ram:map_luts;')
if a.hierarchical:
 cmd=cmd.replace('read_slang --single-unit','read_slang --keep-hierarchy --single-unit')
 cmd=cmd.replace('synth_gowin -family gw2a','synth_gowin -noflatten -family gw2a')
 cmd=cmd.replace(f'-run map_cells: -json {out}/snes-nano.json;',f'-run map_cells:check; flatten; opt_clean; blackbox =A:whitebox; write_json {out}/snes-nano.json;')
if a.noalu:cmd=cmd.replace('synth_gowin -family gw2a','synth_gowin -noalu -family gw2a')
if a.area:cmd=cmd.replace(f'abc9 -maxlut {a.maxlut} -W 500;',f'abc9 -maxlut {a.maxlut} -script +&scorr;&sweep;&dc2;&dch,-f,-r;&if,-a,-W,500,-D,40000;&mfs;')
if a.noce:cmd=cmd.replace('synth_gowin ','synth_gowin -nodffe ')
if a.effort:cmd=cmd.replace('&mfs;','&mfs,-a,-e,-L,2,-W,8;')
if a.classic:cmd=cmd.replace(f'read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut {a.maxlut} -W 500;',f'abc -lut {a.maxlut};')
if a.coarse_only:
 start=re.search(r'^synth_gowin[^\n]*-run coarse:',cmd,re.M).start()
 cmd=cmd[:start]+f'synth_gowin -family gw2a -top snestang_top -run coarse:map_ram; select snestang_top; write_json -selected {out}/coarse.json;\n'
(out/'synthesis.ys').write_text(cmd)
inputs=set(sources+wrappers+[Path(__file__).resolve()])
inputs.update(root.rglob('*.vh'));inputs.update((root/'src/chip/DSP').glob('*.hex'))
(out/'source-manifest.json').write_text(json.dumps({'options':vars(a),'inputs':{str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(inputs)}},indent=2)+'\n')
with (out/'synthesis.log').open('w') as log:
 subprocess.run([str(work/'oss-cad-suite/bin/yosys'),'-Q','-m','slang','-s',str(out/'synthesis.ys')],cwd=root,stdout=log,stderr=subprocess.STDOUT,check=True)
if a.coarse_only:
 print('Native SNES coarse synthesis PASS');raise SystemExit(0)
net=json.loads((out/'snes-nano.json').read_text())['modules']['snestang_top'];counts={}
for c in net['cells'].values():counts[c['type']]=counts.get(c['type'],0)+1
(out/'resources.json').write_text(json.dumps(counts,indent=2)+'\n');print('Native SNES board synthesis PASS',counts)
