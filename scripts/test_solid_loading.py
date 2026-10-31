"""Pixel regression test for the actual opaque-panel FPGA renderer."""
import argparse,subprocess,tempfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--tools',type=Path,default=Path('/opt/homebrew/bin'));p.add_argument('--renderer',type=Path);a=p.parse_args()
root=Path(__file__).resolve().parents[1]/'fpga/solid-loading'
with tempfile.TemporaryDirectory(prefix='nanoblast-solid-pixels-') as tmp:
    binary=Path(tmp)/'pixels.vvp'
    subprocess.run([str(a.tools/'iverilog'),'-g2012','-s','solid_loading_tb','-o',str(binary),*[str(a.renderer if name=='textdisp.v' and a.renderer else root/name) for name in ['pixels_tb.sv','textdisp.v','cdc_mailbox.sv','reset_release.sv']]],check=True)
    subprocess.run([str(a.tools/'vvp'),str(binary)],check=True)
