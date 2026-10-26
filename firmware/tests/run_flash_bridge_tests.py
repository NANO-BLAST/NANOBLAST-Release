from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1];work=root.parent
with tempfile.TemporaryDirectory(prefix='flash-bridge-rtl-') as tmp:
 p=Path(tmp)/'test.vvp'
 subprocess.run([str(work/'oss-cad-suite/bin/iverilog'),'-g2012','-s','flash_bridge_tb','-o',str(p),str(work/'nanoblast/src/iosys/nanoblast_menu_link.sv'),str(work/'nanoblast/src/iosys/nanoblast_sd_spi.sv'),str(root/'tests/flash_bridge_tb.sv')],check=True)
 subprocess.run([str(work/'oss-cad-suite/bin/vvp'),str(p)],check=True)
