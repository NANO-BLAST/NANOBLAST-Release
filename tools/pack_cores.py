"""Generate four contiguous, independently checked XZ core assets."""
from pathlib import Path
import struct,zlib,lzma,json,hashlib
import argparse
A=argparse.ArgumentParser();A.add_argument('--raw',type=Path,required=True);A.add_argument('--output',type=Path,required=True);a=A.parse_args();R=Path(__file__).resolve().parents[1];O=a.output;O.mkdir(parents=True,exist_ok=True);directory=bytearray(b'\xff'*4096);struct.pack_into('<8sIIIIII',directory,0,b'NBCRDIR1',1,4,1,16,0,0)
base=0x201000;entries=[]
for i,(id,name) in enumerate([(1,'nes'),(5,'sms-gamegear'),(7,'gb-colour'),(2,'snes-experimental')]):
 raw=(a.raw/f'{name}-nano20k.bin').read_bytes();assert len(raw)==907418
 block=65536;count=(len(raw)+block-1)//block;head=bytearray(b'\xff'*4096);data=bytearray();struct.pack_into('<8sIIIIIIII',head,0,b'NBCRXZ01',id,len(raw),zlib.crc32(raw),0x4b30324e,0,count,block,0);head[40:64]=bytes(24)
 for j in range(count):
  p=raw[j*block:(j+1)*block];c=lzma.compress(p,format=lzma.FORMAT_XZ,check=lzma.CHECK_CRC32,filters=[{'id':lzma.FILTER_LZMA2,'dict_size':16384,'preset':9|lzma.PRESET_EXTREME}]);stored=len(c)>=len(p)
  if stored:c=p
  assert (c if stored else lzma.decompress(c))==p
  struct.pack_into('<II',head,64+j*8,4096+len(data),len(c)|(0x80000000 if stored else 0));data+=c
 struct.pack_into('<I',head,24,len(data));meta=zlib.crc32(head[:36]+head[40:64]+head[64:64+count*8]);struct.pack_into('<I',head,36,meta);asset=bytes(head+data);span=(len(asset)+4095)&~4095;assert base+span<=0x3ff000
 struct.pack_into('<IIII',directory,32+i*16,id,base,len(asset),meta)
 (O/(name+'.core')).write_bytes(asset)
 entries.append({'core_id':id,'name':name,'file':name+'.core','offset':base,'bytes':len(asset),'span':span,'sha256':hashlib.sha256(asset).hexdigest(),'raw_sha256':hashlib.sha256(raw).hexdigest(),'raw_crc32':zlib.crc32(raw),'raw_bytes':len(raw)});base+=span
struct.pack_into('<I',directory,24,zlib.crc32(directory[:24]+directory[28:96]))
slots='// Generated immutable asset locations. GPL-3.0.\n#pragma once\nnamespace nanoblast {\nstruct CoreSlot {unsigned id;uint32_t base,bytes,meta;};\nstatic constexpr CoreSlot CoreSlots[]={\n'+''.join(' {%u,0x%x,%u,0x%x},\n'%(v['core_id'],v['offset'],v['bytes'],struct.unpack_from('<I',directory,32+i*16+12)[0]) for i,v in enumerate(entries))+'};\nstatic constexpr uint32_t CoreLayoutRevision=0x%08x;\n}\n'%struct.unpack_from('<I',directory,24)[0];(R/'firmware/storage/compressed_core_slots.h').write_text(slots)
layout={'version':1,'layout_embedded_in_firmware':True,'assets':entries,'asset_bank_bytes':0x3ff000-0x201000,'assets_sector_bytes':base-0x201000,'free_bank_bytes':0x3ff000-base,'staging':{'start':0x100000,'end':0x1df000},'preserved_ranges':[[0,0x40000],[0x1df000,0x201000],[0x3ff000,0x400000]],'FPGA_boot_flash':'unchanged'};(O/'layout.json').write_text(json.dumps(layout,indent=2)+'\n');print(json.dumps(layout,indent=2))
