from pathlib import Path
import subprocess
work=Path(__file__).resolve().parents[2];port=work/'smstang/nanoblast';out=work.parent/'outputs/sms-startup-fix';out.mkdir(exist_ok=True)
source=(port/'rtl/sms_nano_top.sv').read_text()
assert '.async_resetn(startup_ready)' in source and '.async_resetn(main_locked&&hdmi_locked' not in source
files=[port/'rtl/sms_nano_startup.sv',work/'nanoblast/src/reset_release.sv',work/'nanoblast/src/cdc_mailbox.sv',work/'nanoblast/src/hw_uart.v',work/'nanoblast/src/iosys/mcu_uart.v',work/'nanoblast/src/iosys/textdisp.v',work/'nanoblast/src/iosys/nanoblast_sd_spi.sv',work/'nanoblast/src/iosys/nanoblast_menu_link.sv',work/'nanoblast/src/iosys/nanoblast_iosys.sv',port/'tests/startup_tb.sv']
with (out/'startup-test.log').open('w') as log:
 subprocess.run([str(work/'oss-cad-suite/bin/iverilog'),'-g2012','-s','startup_tb','-o',str(out/'startup.vvp'),*map(str,files)],stdout=log,stderr=subprocess.STDOUT,check=True)
 subprocess.run([str(work/'oss-cad-suite/bin/vvp'),str(out/'startup.vvp')],stdout=log,stderr=subprocess.STDOUT,check=True)
print(next(line for line in (out/'startup-test.log').read_text().splitlines() if line.startswith('PASS ')))
