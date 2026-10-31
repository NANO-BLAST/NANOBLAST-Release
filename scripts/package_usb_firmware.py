"""Finalize the secondary-menu BFNP image; never programs a device."""
import argparse
import hashlib
import json
import struct
import sys
import zlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts/bl616'))
from updater import firmware,CORES
parser=argparse.ArgumentParser();parser.add_argument('binary',type=Path);parser.add_argument('--core-manifest',type=Path);parser.add_argument('--output',type=Path,default=ROOT/'artifacts/usb-rom-transfer');args=parser.parse_args()
b=bytearray(args.binary.read_bytes());b+=b'\xff'*(-len(b)%16)
if b[:4]!=b'BFNP' or len(b)>0xA8000 or struct.unpack_from('<I',b,124)[0]!=4096:raise SystemExit('Image is invalid or exceeds the secondary menu slot')
flags=struct.unpack_from('<I',b,120)[0]
if flags&15:raise SystemExit('Encrypted/signed image is not supported')
for offset,value in [(96,zlib.crc32(b[12:96])),(116,zlib.crc32(b[104:116])),(120,flags&~(3<<16)),(132,len(b)-4096)]:struct.pack_into('<I',b,offset,value)
b[136:168]=hashlib.sha256(b[4096:]).digest();struct.pack_into('<I',b,252,zlib.crc32(b[:252]));firmware(b)
release=ROOT/'src-tauri/resources/nanoblast-v0.2.0'
manifest_path=args.core_manifest or release/'manifest.json'
manifest=json.loads(manifest_path.read_text())
if args.core_manifest:
    for asset in manifest['assets']:
        source=(manifest_path.parent/asset['file']).resolve()
        if source.parent!=manifest_path.parent.resolve():raise SystemExit('Core asset escapes its directory')
        payload=source.read_bytes()
        if len(payload)!=asset['bytes'] or hashlib.sha256(payload).hexdigest()!=asset['sha256']:raise SystemExit('Core asset checksum mismatch')
slots=b''.join(struct.pack('<IIII',a['core_id'],a['offset'],a['bytes'],struct.unpack_from('<I',(manifest_path.parent/a['file']).read_bytes(),36)[0]) for a in manifest['assets'])
if slots not in b:raise SystemExit('Menu does not reference the audited core bank')
args.output.mkdir(parents=True,exist_ok=True)
(args.output/'nanoblast-usb-menu.bin').write_bytes(b)
record=dict(version='solid-loading-development' if args.core_manifest else 'usb-rom-transfer-development',base='solid-loading-v0.2.0' if args.core_manifest else 'v0.2.0',file='nanoblast-usb-menu.bin',bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),menu_offset=0x40000,menu_limit=0xE8000,headroom=0xA8000-len(b),hardware_tested=False)
(args.output/'development-menu.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record,indent=2))
