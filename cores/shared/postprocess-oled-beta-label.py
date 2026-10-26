"""Finalize the SDK's unsigned secondary BL616 image on native Python.
Offsets/CRC rules match Bouffalo's bl616 bootheader_cfg_keys and
img_create_update_bootheader. This generates no efuse or primary image.
"""
from pathlib import Path
import struct,hashlib,zlib,json
src=Path('work/mister-menu-test/firmware/build/build_out/tangcore_bl616.bin')
b=bytearray(src.read_bytes());assert b[:4]==b'BFNP'
u32=lambda n:struct.unpack_from('<I',b,n)[0]
put=lambda n,v:struct.pack_into('<I',b,n,v)
assert u32(124)==4096 and u32(120)&15==0
b.extend(b'\xff'*((-len(b))%16))
put(96,zlib.crc32(b[12:96]));put(116,zlib.crc32(b[104:116]))
put(120,u32(120)&~(3<<16));put(132,len(b)-4096)
b[136:168]=hashlib.sha256(b[4096:]).digest()
put(252,zlib.crc32(b[:252]))
assert u32(96)==zlib.crc32(b[12:96]) and u32(116)==zlib.crc32(b[104:116])
assert b[136:168]==hashlib.sha256(b[4096:]).digest() and u32(252)==zlib.crc32(b[:252])
out=Path('outputs/oled-beta-label/nanoblast-bl616-secondary.bin');out.write_bytes(b)
print(json.dumps({'file':str(out),'bytes':len(b),'body_bytes':u32(132),'sha256':hashlib.sha256(b).hexdigest()},indent=2))
