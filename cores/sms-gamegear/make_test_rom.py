"""Generate an original Game Gear RGB444/controller test ROM; no commercial code."""
from pathlib import Path
import zlib,json,hashlib
P=Path(__file__).resolve().parent;code=bytearray([0xf3,0x31,0xf0,0xdf])
def out(port,value):code.extend([0x3e,value,0xd3,port])
def address(value):out(0xbf,value&255);out(0xbf,value>>8)
def register(index,value):out(0xbf,value);out(0xbf,0x80|index)
register(1,0);register(0,4);register(2,0x0e);register(5,0x7e);register(8,0);register(9,0);register(7,0)
# Solid-colour 4bpp tiles, one per palette index.
address(0x4000)
for tile in range(16):
 for y in range(8):
  for plane in range(4):out(0xbe,255 if tile&(1<<plane) else 0)
address(0x7800)
for y in range(28):
 for x in range(32):out(0xbe,1+x%15);out(0xbe,0)
# Stop sprites before displaying the test image.
address(0x7f00);out(0xbe,0xd0)
palette=[0,0x00f,0x0f0,0xf00,0xfff,0x888,0x159,0x357,0x753,0xace,0xeca,0x123,0x456,0x789,0xabc,0xdef]
address(0xc000)
for value in palette*2:out(0xbe,value&255);out(0xbe,value>>8)
# Enable tone1 on left only; Start and pad state are mirrored in work RAM.
out(0x06,0x10);out(0x7f,0x84);out(0x7f,0x10);out(0x7f,0x90)
register(1,0x40)
loop=len(code);code.extend([0xdb,0,0x32,0,0xc0,0xdb,0xdc,0x32,1,0xc0,0xc3,loop&255,loop>>8])
assert len(code)<0x7ff0
rom=bytearray(32768);rom[:len(code)]=code;rom[0x7ff0:0x7ff8]=b'TMR SEGA';rom[0x7fff]=0x6c
crc=zlib.crc32(rom);(P/'NANOBLAST Game Gear Test.gg').write_bytes(rom)
(P/'tests/gamegear-palette.json').write_text(json.dumps(palette)+'\n');print('Original GG test ROM',len(rom),'bytes, CRC',f'{crc:08X}','code',len(code))
