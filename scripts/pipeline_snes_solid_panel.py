"""Equivalent SNES pixel implementation: latch solid-panel opacity with its hit."""
import argparse
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('output',type=Path);a=p.parse_args()
s=(Path(__file__).resolve().parents[1]/'fpga/solid-loading/textdisp.v').read_text()
old="debug_hit <= layout_pixel[23] && py[7:3]>=1 && py[7:3]<=13;"
new="""// Latch solid opacity alongside the rectangle's pixel coordinates.
        debug_hit <= (layout_pixel[23] && py[7:3]>=1 && py[7:3]<=13) ||
            (panel_pixel[21] && panel_pixel[20] &&
             px[7:3]>=panel_pixel[4:0] && px[7:3]<=panel_pixel[9:5] &&
             py[7:3]>=panel_pixel[14:10] && py[7:3]<=panel_pixel[19:15]);"""
assert s.count(old)==1;s=s.replace(old,new)
s=s.replace('(debug_hit || (panel_hit && panel_pixel[21])) ?','debug_hit ?')
a.output.write_text(s)
