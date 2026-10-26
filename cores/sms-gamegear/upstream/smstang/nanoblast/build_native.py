"""Native macOS synthesis probes for the Nano port; never touches hardware."""
from pathlib import Path
import argparse,subprocess,json
root=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--target',choices=['core','sdram'],default='core');a=p.parse_args()
out=root.parent/'outputs/sms-nano-start';out.mkdir(parents=True,exist_ok=True)
yosys=root/'oss-cad-suite/bin/yosys'
if a.target=='core':
 if not (root/'sms-vhdl/opll.v').exists():subprocess.run(['python3',str(root/'probe-sms-vhdl.py')],check=True)
 top='sms_nano_core'
 read="read_verilog opll.v; read_slang --single-unit -U SYNTHESIS --allow-use-before-declare --allow-merging-ansi-ports --top sms_nano_core -f ../sms-core.f ../smstang/nanoblast/rtl/sms_nano_core.sv ../smstang/nanoblast/rtl/sms_nano_raster.v; "
 cwd=root/'sms-vhdl'
else:
 top='sms_nano_sdram';read='read_verilog -sv smstang/nanoblast/rtl/sms_nano_sdram.sv; ';cwd=root
# Match the working Nano implementation's LUT6 limit.
command='read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v; '+read+f'synth_gowin -family gw2a -top {top} -run begin:begin; synth_gowin -family gw2a -top {top} -run coarse:map_luts; sort; read_verilog -icells -lib -specify +/abc9_model.v; abc9 -maxlut 6 -W 500; clean; synth_gowin -family gw2a -top {top} -run map_cells: -json {out/top}.json'
with (out/f'{a.target}-synthesis.log').open('w') as log:
 subprocess.run([str(yosys),'-Q','-m','slang','-p',command],cwd=cwd,stdout=log,stderr=subprocess.STDOUT,check=True)
net=json.loads((out/f'{top}.json').read_text());counts={}
for cell in net['modules'][top]['cells'].values():counts[cell['type']]=counts.get(cell['type'],0)+1
if a.target=='core':
 assert counts.get('SP',0)==20 and counts.get('DPB',0)==8, 'Expected 8KiB WRAM + 32KiB cartridge RAM + 16KiB VRAM; inspect synthesis before trusting resource count'
 assert 'is used but has no driver' not in (out/'core-synthesis.log').read_text(), 'Undriven core inputs'
(out/f'{a.target}-resources.json').write_text(json.dumps(counts,indent=2)+'\n')
print(f'{top} native synthesis PASS; cell counts: {counts}')
