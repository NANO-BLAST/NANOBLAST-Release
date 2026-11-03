"""CRT arithmetic/CDC/compositor and SMS/GG scanout regressions. No hardware writes."""
import argparse, subprocess, tempfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--iverilog',default='iverilog');p.add_argument('--vvp',default='vvp');a=p.parse_args()
r=Path(__file__).resolve().parents[1]
sms=r/'cores/sms-gamegear';nes=r/'cores/nes'
common=[sms/'tests/hdmi_stub.sv',r/'fpga/solid-loading/cdc_mailbox.sv']
with tempfile.TemporaryDirectory(prefix='nanoblast-crt-') as d:
 for top,files in [
  ('tb_crt_presets',[nes/'tests/tb_crt_presets.sv',nes/'src/nes2hdmi.sv',sms/'rtl/sms_nano_hdmi.sv']),
  ('video_tb',[sms/'tests/video_tb.sv',sms/'rtl/sms_nano_hdmi.sv']),
  ('gamegear_video_tb',[sms/'tests/gamegear_video_tb.sv',sms/'rtl/sms_nano_hdmi.sv'])]:
  out=Path(d)/(top+'.vvp')
  subprocess.run([a.iverilog,'-g2012','-DNANOBLAST_BL616','-s',top,'-o',str(out),*map(str,files+(common[1:] if top=='video_tb' else common))],check=True)
  subprocess.run([a.vvp,str(out)],check=True)
