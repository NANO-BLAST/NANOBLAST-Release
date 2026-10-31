"""Package verified FPGA images into the shared BL616 compressed-core bank."""
import argparse,hashlib,json,lzma,struct,zlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--build',type=Path,default=ROOT/'hardware-tests/solid-loading');p.add_argument('--output',type=Path,default=ROOT/'artifacts/solid-loading');a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=True)
images=[(1,'nes',a.build/'nes/image.bin'),(5,'sms-gamegear',a.build/'sms/image.bin'),(7,'gb-colour',a.build/'gb/build/gb-mister-nano20k.bin'),(2,'snes-experimental',a.build/'snes/image.bin')]
assets=[];base=0x201000
for core,name,path in images:
    raw=path.read_bytes();assert len(raw)==907418
    verification=json.loads((path.parent/'image-check.json').read_text())
    assert verification['raw_sha256']==hashlib.sha256(raw).hexdigest()
    assert verification.get('timing_pass',verification.get('setup_violations')==verification.get('hold_violations')==0)
    assert verification.get('storage_pin_checks',verification.get('checked_storage_pin_count',0))==61
    count=(len(raw)+65535)//65536;head=bytearray(4096);data=bytearray()
    struct.pack_into('<8sIIIIIIII',head,0,b'NBCRXZ01',core,len(raw),zlib.crc32(raw),0x4b30324e,0,count,65536,0)
    for i in range(count):
        block=raw[i*65536:(i+1)*65536]
        enc=lzma.compress(block,format=lzma.FORMAT_XZ,check=lzma.CHECK_CRC32,filters=[{'id':lzma.FILTER_LZMA2,'dict_size':16384,'preset':9|lzma.PRESET_EXTREME}])
        assert lzma.decompress(enc)==block
        stored=len(enc)>=len(block)
        if stored:enc=block
        struct.pack_into('<II',head,64+i*8,4096+len(data),len(enc)|(0x80000000 if stored else 0));data+=enc
    struct.pack_into('<I',head,24,len(data));meta=zlib.crc32(head[:36]+head[40:64]+head[64:64+count*8]);struct.pack_into('<I',head,36,meta)
    packed=bytes(head+data);file=name+'.core';(a.output/file).write_bytes(packed)
    assets.append(dict(core_id=core,offset=base,bytes=len(packed),meta=meta,file=file,sha256=hashlib.sha256(packed).hexdigest(),image_sha256=hashlib.sha256(raw).hexdigest()))
    base+=(len(packed)+4095)&~4095
assert base<=0x3ff000
slots=b''.join(struct.pack('<IIII',d['core_id'],d['offset'],d['bytes'],d['meta']) for d in assets)
revision=zlib.crc32(slots)
header='// Generated opaque-loading core asset locations. GPL-3.0.\n#pragma once\nnamespace nanoblast {\nstruct CoreSlot {unsigned id;uint32_t base,bytes,meta;};\nstatic constexpr CoreSlot CoreSlots[]={\n'
header+=''.join(' {%d,0x%x,%d,0x%08x},\n'%(d['core_id'],d['offset'],d['bytes'],d['meta']) for d in assets)
header+='};\nstatic constexpr uint32_t CoreLayoutRevision=0x%08x;\n}\n'%revision
(a.output/'compressed_core_slots.h').write_text(header)
(a.output/'core-manifest.json').write_text(json.dumps(dict(version='solid-loading-development',assets=assets,layout_revision=revision,bank_end=base,hardware_tested=False),indent=2)+'\n')
print(json.dumps(assets,indent=2))
