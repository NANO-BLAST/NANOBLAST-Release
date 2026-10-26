"""Build the direct MiSTer source port with native macOS Gowin."""
from pathlib import Path
import subprocess,sys,os
P=Path(__file__).resolve().parent;O=P/'build';E=P/'engine';S=P/'shared'
O.mkdir(exist_ok=True)
(O/'boot.hex').write_bytes((P/'assets/boot.hex').read_bytes())
(O/'gb-mister.sdc').write_bytes((P/'constraints/gb-mister.sdc').read_bytes())
# Gowin's synthesis child resolves readmemh relative to its project folder,
# even after Tcl cd. Generate a native-only source with an absolute init path.
boot_source=O/'native-gb_rams.sv'
boot_source.write_text((P/'rtl/gb_rams.sv').read_text().replace('"boot.hex"','"'+str((P/'assets/boot.hex').resolve())+'"'))
sv=[boot_source if p.name=='gb_rams.sv' else p for p in sorted((P/'rtl').glob('*')) if p.suffix in ('.v','.sv')]
sv += [E/n for n in ['gb.v','video.v','sprites.v','sprites_extra.v','sprites_extra_store.v','timer.v','hdma.v','link.v','cart.v']]
sv += sorted((E/'mappers').glob('*.v'))+sorted((E/'mappers').glob('*.sv'))
vhdl=[E/n for n in ['bus_savestates.vhd','reg_savestates.vhd','T80/T80_Pack.vhd','T80/T80_ALU.vhd','T80/T80_MCode.vhd','T80/T80_Reg.vhd','T80/T80.vhd','T80/GBse.vhd','gbc_snd.vhd']]
shared=S/'work/nanoblast/src'
sv += [S/'work/smstang/nanoblast/rtl/sms_nano_startup.sv']
sv += [shared/n for n in ['cdc_mailbox.sv','reset_release.sv','menu_background.sv','controller_snes.v','controller_ds2.sv','dualshock_controller.v','hw_uart.v','iosys/mcu_uart.v','iosys/nanoblast_iosys.sv','iosys/nanoblast_menu_link.sv','iosys/nanoblast_sd_spi.sv']]
sv += [S/'work/mister-menu-test/textdisp.v']
sv += sorted((shared/'hdmi2').glob('*.sv'))
sv += [S/'work/smstang/nanoblast/rtl/sms_nano_pll.v',shared/'nano20k/gowin_pll_hdmi.v',shared/'iosys/gowin_dpb_menu.v']
lines=[f'create_project -force -name gb_mister -dir {{{O}/project}} -pn GW2AR-LV18QN88C8/I7 -device_version C',f'cd {{{O}}}','set_device GW2AR-LV18QN88C8/I7 -device_version C']
lines += [f'add_file -type vhdl {{{p}}}' for p in vhdl]
lines += [f'add_file -type verilog {{{p}}}' for p in sv]
base=P/'constraints'
lines += [f'add_file -type cst {{{base}/gb.cst}}',f'add_file -type sdc {{{O}/gb-mister.sdc}}','set_option -synthesis_tool gowinsynthesis','set_option -top_module nanoblast_gb_mister_top','set_option -verilog_std sysv2017','set_option -vhdl_std vhd2008','set_option -output_base_name nanoblast_gb_mister','set_option -rw_check_on_ram 1','set_option -place_option 2','set_option -route_option 1']
lines += [f'set_option -use_{x}_as_gpio 1' for x in ['mspi','sspi','ready','done','i2c','cpu']]
lines += ['set_option -multi_boot 1','set_option -bit_compress 1','run '+('all' if '--all' in sys.argv else 'syn')]
(O/'build-input-sha256.json').write_text(__import__('json').dumps({str(p.relative_to(P)):__import__('hashlib').sha256(p.read_bytes()).hexdigest() for p in sv+vhdl+[base/'gb.cst',O/'gb-mister.sdc',O/'boot.hex']},indent=2)+'\n')
tcl=O/'build.tcl';tcl.write_text('\n'.join(lines)+'\n')
with (O/'gowin-build.log').open('w') as log:
 env=dict(os.environ, DYLD_LIBRARY_PATH='/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/lib', DYLD_FRAMEWORK_PATH='/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/lib')
 r=subprocess.run(['/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/bin/gw_sh',str(tcl)],cwd=O,env=env,stdout=log,stderr=subprocess.STDOUT)
log_text=(O/'gowin-build.log').read_text()
if r.returncode == 0:
 for line in log_text.splitlines():
  if ('EX1998' in line and any(n in line for n in ['/engine/cart.v','nanoblast_gb_save.sv','nanoblast_gbc_top.sv','nanoblast_gbc_host.sv','nanoblast_gbc_engine.sv'])) or 'ERROR ' in line or 'Cannot open file' in line:
   raise RuntimeError('Native cartridge build error: '+line)
if r.returncode == 0:
 import re,html
 resources=html.unescape(re.sub('<[^>]+>',' ',(O/'impl/gwsynthesis/nanoblast_gb_mister_syn_resource.html').read_text()))
 for required in ['map_mbc1','map_mbc2','map_mbc3','map_mbc5','rtc_clock','boot_rom']:
  assert required in resources, 'Missing native cartridge logic: '+required
 raw_resources=(O/'impl/gwsynthesis/nanoblast_gb_mister_syn_resource.html').read_text()
 boot_row=raw_resources.split('|--boot_rom',1)[1].split('</tr>',1)[0]
 cells=re.findall(r'<td align\s*=\s*"center">([^<]+)</td>',boot_row)
 assert len(cells)==7 and cells[4]=='2', 'Replacement boot ROM must occupy two BSRAM blocks'
if r.returncode == 0:
 save_row=raw_resources.split('|--saves',1)[1].split('</tr>',1)[0]
 cells=re.findall(r'<td align\s*=\s*"center">([^<]+)</td>',save_row)
 assert len(cells)==7 and int(cells[0])<1000 and cells[4]=='1', 'Save page must use one BSRAM and bounded registers'
print('Gowin exit'  ,r.returncode,'log',O/'gowin-build.log');sys.exit(r.returncode)
