"""Native offline regressions. Set NANOBLAST_CAD_ROOT to an OSS CAD Suite tree."""
from pathlib import Path
import os,subprocess,sys,argparse
P=Path(__file__).resolve().parent;B=P/'build';B.mkdir(exist_ok=True)
A=argparse.ArgumentParser();A.add_argument('--rom',type=Path);args=A.parse_args()
T=Path(os.environ['NANOBLAST_CAD_ROOT']).resolve();env={**os.environ,'VERILATOR_ROOT':str(T/'share/verilator'),'GHDL_PREFIX':'work/oss-cad-suite/lib/ghdl','DYLD_LIBRARY_PATH':str(T/'lib')}
def run(cmd,log=None):
 if log:
  with (B/log).open('w') as f:subprocess.run(list(map(str,cmd)),cwd=B,env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
 else:subprocess.run(list(map(str,cmd)),cwd=B,env=env,check=True)
R=P/'rtl';E=P/'engine';S=P/'shared/work/nanoblast/src'
(B/'boot.hex').write_bytes((P/'assets/boot.hex').read_bytes())
controller=(S/'controller_snes.v').read_text().replace('{0, 0, 0, 0, buttons_buf[7:0]}',"{4'd0, buttons_buf[7:0]}")
(B/'controller-sim.v').write_text(controller)
for name,src in [('mapper_bus',[R/'disabled_features.v',R/'gb_rams.sv',E/'cart.v',*sorted((E/'mappers').glob('*.v')),*sorted((E/'mappers').glob('*.sv'))]),('save',[R/'nanoblast_gb_save.sv']),('rtc',[R/'nanoblast_gbc_rtc_tick.sv',E/'mappers/mbc3.v']),('ram',[R/'gb_rams.sv']),('clock',[R/'nanoblast_gbc_ce.sv']),('controller',[B/'controller-sim.v']),('scaler',[R/'nanoblast_gbc_hdmi.sv',S/'cdc_mailbox.sv',P/'tests/hdmi_stub.sv'])]:
 run([T/'iverilog','-B'+str(T/'ivl'),'-g2012','-gno-strict-declaration','-s',name+'_tb','-o',B/(name+'.vvp'),*src,P/'tests'/(name+'_tb.sv')]);run([T/'vvp',B/(name+'.vvp')],name+'-simulation.log')
if not args.rom:
 print('RAM/clock/controller/scaler checks passed. Use --rom with a boot-compatible homebrew ROM for engine/pipeline checks.');sys.exit()
rom=args.rom.resolve();assert rom.is_file()
vhdl=[E/n for n in ['bus_savestates.vhd','reg_savestates.vhd','T80/T80_Pack.vhd','T80/T80_ALU.vhd','T80/T80_MCode.vhd','T80/T80_Reg.vhd','T80/T80.vhd','T80/GBse.vhd']]
for entity,files in [('GBse',vhdl),('gbc_snd',[E/'bus_savestates.vhd',E/'reg_savestates.vhd',E/'gbc_snd.vhd'])]:
 with (B/(entity+'.v')).open('w') as out, (B/(entity+'-ghdl.log')).open('w') as err:
  subprocess.run(list(map(str,[T/'ghdl','--synth','--std=08','-fsynopsys','--out=verilog',*files,'-e',entity])),cwd=B,env=env,stdout=out,stderr=err,check=True)
p=B/'GBse.v';p.write_text(p.read_text().replace('module gbse\n','module GBse\n'))
extra=(E/'sprites_extra.v').read_text();extra=extra[:extra.index(');')+2]
for n in ['oam_eval_extra','oam_extra_addr','spr_fetch_attr','tile_fetch','tile_addr','spr_found','spr_tile0','spr_tile1','spr_cgb_pal','spr_index','spr_pal','spr_prio']:extra+='\nassign '+n+"='0;"
(B/'extra-sim.v').write_text(extra+'\nendmodule\n')
engine=[R/'disabled_features.v',R/'gb_rams.sv',R/'nanoblast_gbc_engine.sv',R/'nanoblast_gbc_ce.sv']+[E/n for n in ['gb.v','video.v','sprites.v','timer.v','hdma.v','link.v','cart.v']]+sorted((E/'mappers').glob('*.v'))+sorted((E/'mappers').glob('*.sv'))+[B/'GBse.v',B/'gbc_snd.v',B/'extra-sim.v']
body=(R/'nanoblast_gbc_top.sv').read_text().split('wire running,load_fault,host_fault,fault;')[1].rsplit('endmodule',1)[0]
(B/'pipeline_tb.sv').write_text((P/'tests/pipeline_template.sv').read_text().replace('// @BOARD_BODY@',body))
pads=B/'sim_pads.v';pads.write_text('module ELVDS_OBUF(input I,output O,OB);assign O=I;assign OB=~I;endmodule\n')
board=[p for p in list(R.glob('*.sv'))+list(R.glob('*.v')) if p.name not in ['nanoblast_gbc_top.sv','nanoblast_mister_pll.v']]
video=[S/'cdc_mailbox.sv',S/'menu_background.sv']+[p for p in (S/'hdmi2').glob('*.sv') if p.name!='audio_clock_regeneration_packet.sv']
for name,src in [('engine',engine+[P/'tests/engine_tb.sv']),('pipeline',list(dict.fromkeys(board+engine+video+[P/'tests/hdmi_audio_stub.sv',P/'tests/sdram_model.v',pads,B/'pipeline_tb.sv'])))]:
 run([T/'verilator_bin','--binary','--timing','-j','4','-Wno-fatal','--top-module',name+'_tb','--Mdir',B/(name+'_obj'),*src],name+'-build.log');run([B/(name+'_obj')/('V'+name+'_tb'),'+ROM='+str(rom)],name+'-test.log')
print('Engine and SDRAM/HDMI pipeline checks passed; physical board validation still required.')
