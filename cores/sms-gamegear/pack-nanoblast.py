"""Native GW2A-18C HDMI packing using verified vendor PPLVDS pad fuses.

Apicula currently assumes ELVDS uses LVDS25E and forbids True-LVDS pads.
Gowin's Nano 20K build instead uses PPLVDS on these four fixed pairs.
This adapter regenerates those pad settings from decoded attributes, then
requires exact agreement with the vendor's IOB fuse bits before packing.
It changes neither the routed netlist nor signal polarity.
"""
import json
from pathlib import Path
from apycula import gowin_pack as pack
reference=json.loads((Path(__file__).parent/'vendor-hdmi-io-fuses.json').read_text())
old_check=pack.GW2A_18C.check_io_banks
old_process=pack.GW2A_18C.process_ELVDS_OBUF
checked=set()
def pad_allowed(bel):
 return bel.y==54 and str(bel.x) in reference and bel.idx_str in ('A','B')
def check(self):
 for bank in self.io_banks.values():
  pairs=[b for b in bank.bels if b.cell.typ=='ELVDS_OBUF']
  if pairs:
   if not all(pad_allowed(b) for b in pairs):raise RuntimeError('Unexpected HDMI pin placement')
   bank.has_lvds_outputs=False;bank.has_true_lvds_outputs=False;bank.has_outputs=True
   bank.set_attr('IO_TYPE','LVCMOS33');bank.set_attr('BANK_VCCIO','3.3')
   bank.set_attr_bels['IO_TYPE']=pairs[0];bank.set_attr_bels['BANK_VCCIO']=pairs[0]
 old_check(self)
def process(self,bank,bel):
 if not pad_allowed(bel):return old_process(self,bank,bel)
 r=reference[str(bel.x)][bel.idx_str]
 if r['attrs']['IO_TYPE']!='PPLVDS':raise RuntimeError('Reference is not PPLVDS')
 av=set()
 for k,v in r['attrs'].items():self.chipdb.get_iob_attr_val(pack.AttrVal(k,'LVDS25E' if k=='IO_TYPE' else v),av)
 fuses=self.get_iob_fuses(bel.x,bel.y,bel.idx_str,av)
 generated=set().union(*(f.bits for f in fuses))
 expected={tuple(p) for p in r['fuses']};mask={tuple(p) for p in r['mask']}
 if generated&mask!=expected:raise RuntimeError(f'Vendor IOB fuse mismatch at {bel.x},{bel.y},{bel.idx_str}: extra={generated-expected}, missing={expected-generated}')
 checked.add((bel.x,bel.y,bel.idx_str))
 return fuses
pack.GW2A_18C.check_io_banks=check
pack.GW2A_18C.process_ELVDS_OBUF=process
pack.main()
if len(checked)!=8:raise RuntimeError('Did not verify all eight HDMI pads')
print('Verified all eight HDMI PPLVDS IOB configurations against vendor fuse data')
