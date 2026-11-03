#!/usr/bin/env python3
"""Build the fixed Golden Axe World set 3 Nano 20K candidate; no hardware writes."""
import argparse,hashlib,json,os,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
for name in ['upstream','jtframe','tools','out']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--route-only',action='store_true');p.add_argument('--pack-only',action='store_true')
p.add_argument('--seed',type=int,default=3);p.add_argument('--placement-timeout',type=int,default=100000)
a=p.parse_args();r=Path(__file__).resolve().parent;repo=r.parents[1];out=a.out.resolve();out.mkdir(parents=True,exist_ok=True)
sms=repo/'cores/sms-gamegear';cad=a.tools.resolve();rtl=r/'rtl'
env=dict(os.environ,XDG_CONFIG_HOME=str(out/'config'),XDG_DATA_HOME=str(out/'data'))
def run(command,log):
 with (out/log).open('w') as f:subprocess.run(list(map(str,command)),cwd=out,env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
if not(a.route_only or a.pack_only):
 run([sys.executable,r/'prepare_probe.py','--upstream',a.upstream.resolve(),'--jtframe',a.jtframe.resolve(),'--out',out,'--goldenaxe','--with-memory-wrapper','--gowin-fir','--tag-ram'],'prepare.log')
 s=(out/'synthesis.ys').read_text().splitlines()[0].replace('--top jts16b_game_sdram','--top s16_nano_top --allow-use-before-declare --blackboxed-module ELVDS_OBUF --blackboxed-module OSER10 --blackboxed-module DPB --blackboxed-module CLKDIV').replace('read_slang --single-unit','read_slang -U SYNTHESIS --single-unit')
 extra=[*rtl.glob('*.sv'),sms/'rtl/sms_nano_startup.sv',*[f for f in (sms/'shared').rglob('*.v') if f.name not in ('gowin_pll_hdmi.v','gowin_dpb_menu.v')],*(sms/'shared').rglob('*.sv')]
 extra=[f for f in extra if f.name not in ('menu_background.sv','s16_fx68k_rf.sv','s16_sdram32.sv','s16_word_arbiter.sv')]
 s+=' -v '+str(sms/'gowin-slang-primitives.v')+' '+' '.join(map(str,extra))
 prefix=f'read_verilog -lib +/gowin/cells_sim.v +/gowin/cells_xtra_gw2a.v\nread_verilog {rtl}/s16_nano_pll.v {sms}/shared/nano20k/gowin_pll_hdmi.v {sms}/shared/iosys/gowin_dpb_menu.v\n'
 # Keep dedicated carry chains for long arithmetic while mapping small
 # counters and comparisons together with surrounding logic into LUT4s.
 arith=(cad/'share/yosys/gowin/arith_map.v').read_text()
 assert arith.count('Y_WIDTH <= 2')==1
 (out/'long-arithmetic.v').write_text(arith.replace('Y_WIDTH <= 2','Y_WIDTH <= 12'))
 synthesis='synth_gowin -family gw2a -top s16_nano_top -nowidelut -noalu'
 (out/'board.ys').write_text(prefix+s+'\n'+synthesis+' -run begin:map_gates\n'
  +'techmap -map long-arithmetic.v\n'+synthesis+' -json board.json -run map_gates:\n'
  +'tee -o board-statistics.json stat -json\ncheck -assert\n')
 run([cad/'bin/yosys','-Q','-m','slang','-s','board.ys'],'board-synthesis.log')
if not a.pack_only:
 # Discover the actual merged pixel clock alias, instead of silently missing it.
 m=json.loads((out/'board.json').read_text())['modules']['s16_nano_top']
 bits=m['cells']['video_div']['connections']['CLKOUT']
 names=[n for n,v in m['netnames'].items() if v['bits']==bits];assert names
 clocks="ctx.addClock('sys_clk',27.0)\nctx.addClock('clk',50.625)\nctx.addClock("+repr(names[0])+",74.25)\nctx.addClock('hclk5',371.25)\n"
 (out/'clocks.py').write_text(clocks)
 run([cad/'bin/nextpnr-himbaechel','--seed',a.seed,'--device','GW2AR-LV18QN88C8/I7','--vopt','family=GW2A-18C','--vopt','cst='+str(sms/'constraints/board.cst'),'--json','board.json','--pre-pack','clocks.py','--write','routed.json','--report','timing.json','--placer-heap-cell-placement-timeout',a.placement_timeout,'--placer-heap-beta','1.0'],'route.log')
 timing=json.loads((out/'timing.json').read_text())['fmax'];assert timing and all(x['achieved']>=x['constraint'] for x in timing.values()),timing
# Pin verification is required before packing SDRAM/SPI/SD board connections.
m=next(iter(json.loads((out/'routed.json').read_text())['modules'].values()))
pins=json.loads((repo/'cores/nes/constraints/storage-pins.json').read_text())['pins']
by_bit = {}
for cell in m['cells'].values():
 pad = {'IBUF':'I','OBUF':'O','IOBUF':'IO'}.get(cell['type'])
 if pad:
  for bit in cell['connections'][pad]:
   by_bit[bit] = cell['attributes']['NEXTPNR_BEL']
actual = {f'{name}[{i}]': by_bit.get(bit) for name,port in m['ports'].items()
          for i,bit in enumerate(port['bits'])}
assert len(pins)==61
for name,bel in pins.items():
 assert actual.get(name)==bel,(name,actual.get(name),bel)
(out/'work').mkdir(exist_ok=True)
# This fuse map is versioned with the existing SMS core packer inputs.
fuse=sms/'vendor-hdmi-io-fuses.json'
if not fuse.is_file():fuse=repo.parent/'artifacts/menu-audio-fix/packed/work/vendor-hdmi-io-fuses.json'
shutil.copyfile(fuse,out/'work/vendor-hdmi-io-fuses.json')
env.update(PYTHONHOME=str(cad),DYLD_LIBRARY_PATH=str(cad/'lib'),SSL_CERT_FILE='/etc/ssl/cert.pem')
run([cad/'libexec/python3.11',repo/'build-inputs/original-workspace/work/pack-nanoblast.py','-d','GW2A-18C','-o','s16.fs','routed.json'],'pack.log')
raw=bytes(int(line[i:i+8],2) for line in (out/'s16.fs').read_text().splitlines() if line and set(line)<={'0','1'} for i in range(0,len(line),8))
assert len(raw)==907418,len(raw)
assert raw[-30:-24]==bytes.fromhex('0a0000000000') and raw[-14:-10]==bytes.fromhex('08000000')
(out/'s16tang.bin').write_bytes(raw)
(out/'build-result.json').write_text(json.dumps({'profile':'goldnaxe3 World set 3 FD1094','hardware_tested':False,'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw),'fmax':json.loads((out/'timing.json').read_text())['fmax'],'verified_storage_pins':len(pins)},indent=2)+'\n')
print('Built',out/'s16tang.bin',flush=True)
