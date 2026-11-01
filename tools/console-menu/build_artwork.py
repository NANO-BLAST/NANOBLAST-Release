"""Compile the supplied Horizon art and UI palette into the existing FPGA format."""
from pathlib import Path
from collections import defaultdict,deque
import argparse,struct,zlib,hashlib,re,json
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--image',type=Path,default=ROOT/'src/assets/nanoblast-horizon.png');p.add_argument('--output',type=Path,default=ROOT/'artifacts/horizon-menu');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
# Firmware asset conversion, not a new illustration. Nearest-neighbour preserves
# the pixel-art edges; reserve palette entries for fast, atomic row highlights.
im=Image.open(a.image).convert('RGB').resize((640,360),Image.Resampling.NEAREST).resize((1280,720),Image.Resampling.NEAREST).quantize(colors=224,method=Image.Quantize.FASTOCTREE,dither=Image.Dither.NONE)
assert max(im.getdata())<224, 'Artwork entered reserved UI palette'
original_pixels=im.tobytes()
pal=(im.getpalette() or [])[:672]+[0]*96
colors={**{224+i:(0x175d9f if i==0 else 0x0b2145) for i in range(12)},236:0x06152e,237:0x32669f,238:0x020917,239:0x0b2145}
colors.update({240+i:c for i,c in enumerate([0xe53935,0xf4c942,0xffffff,0x172139,0x10213c,0xff8371,0xffed92])})
for i,c in colors.items():pal[3*i:3*i+3]=[c>>16,(c>>8)&255,c&255]
im.putpalette(pal);d=ImageDraw.Draw(im)
d.rectangle((272,380,1024,655),fill=238);d.rectangle((264,372,1016,647),fill=237);d.rectangle((268,376,1012,643),fill=236)
for row in range(15,26):d.rectangle((269,24+24*row,1011,24+24*row+23),fill=224+row-15)
# European SNES-style red A / yellow B buttons, with the actual FPGA font.
font=[int(x,16) for x in re.findall(r"8'h([0-9a-fA-F]{2})",(ROOT/'tools/console-menu/font.vh').read_text())];assert len(font)==1024
base=im.copy()
for left,letter,fill,ink,glint in [(448,'A',240,242,245),(688,'B',241,243,246)]:
 d.ellipse((left,670,left+32,702),fill=244)
 d.ellipse((left+2,672,left+30,700),fill=fill)
 d.arc((left+4,674,left+28,698),195,295,fill=glint,width=2)
 for y in range(8):
  for x in range(8):
   if font[ord(letter)*8+y]&(1<<x):d.rectangle((left+4+x*3,674+y*3,left+6+x*3,676+y*3),fill=ink)
# Keep helper graphics separate, so USB transfer can restore the exact art
# beneath the buttons rather than covering it with a solid colour.
helper_visible=im
helper_arrays=[]
for index,left in enumerate((448,688)):
 for name,source in [('plain',base),('visible',helper_visible)]:
  data=source.crop((left,670,left+33,703)).tobytes()
  helper_arrays.append((f'helper_{index}_{name}',data))
im=base
rawpixels=im.tobytes()
# Only the central menu panel may obscure the artwork. Keep every outer edge
# and the entire area below its shadow identical to the full-screen source.
for y in range(720):
 for left,right in ([(0,264),(1025,1280)] if 372<=y<=655 else [(0,1280)]):
  start=y*1280+left;end=y*1280+right
  assert rawpixels[start:end]==original_pixels[start:end], 'Artwork outside menu panel was overwritten'
payload=bytes(pal)+rawpixels
header=b'NBBG0001'+struct.pack('<6I',(720<<16)|1280,(1<<16)|256,len(payload),zlib.crc32(payload),0,0);raw=header+payload
assert len(raw)==922400
(a.output/'horizon.nbbg').write_bytes(raw);im.save(a.output/'horizon.png')
# Same bounded 4 KiB-window LZ format the shipped cores already consume.
out=bytearray(b'NBLZ0001'+struct.pack('<II',len(raw),0));positions=defaultdict(deque);pos=0
while pos<len(raw):
 flag=len(out);out.append(0)
 for bit in range(8):
  if pos==len(raw):break
  candidates=positions[raw[pos:pos+3]]
  while candidates and pos-candidates[0]>4096:candidates.popleft()
  best=0;distance=0
  for previous in reversed(candidates):
   n=0
   while n<18 and pos+n<len(raw) and raw[previous+n]==raw[pos+n]:n+=1
   if n>best:best=n;distance=pos-previous
   if best==18:break
  n=best if best>=3 else 1
  if n>=3:out[flag]|=1<<bit;out.extend(struct.pack('<H',((distance-1)<<4)|(n-3)))
  else:out.append(raw[pos])
  for i in range(pos,pos+n):
   bucket=positions[raw[i:i+3]];bucket.append(i)
   while bucket and i-bucket[0]>4096:bucket.popleft()
   while len(bucket)>64:bucket.popleft()
  pos+=n
(a.output/'horizon.nblz').write_bytes(out)
def array(name,data):return 'static const uint8_t '+name+'[]={\n'+'\n'.join(','.join(f'0x{x:02x}' for x in data[i:i+24])+',' for i in range(0,len(data),24))+'\n};\n'
(ROOT/'firmware/ui/background_helpers.inc').write_text('// Generated helper tiles; restore the exact artwork when hidden.\n'+''.join(array(name,data) for name,data in helper_arrays))
(a.output/'helpers.json').write_text(json.dumps([dict(x=left,y=670,width=33,height=33,visible=list(helper_visible.crop((left,670,left+33,703)).tobytes())) for left in (448,688)]))
(ROOT/'firmware/ui/background_seed.inc').write_text('// Horizon artwork compiled by tools/console-menu/build_artwork.py; SHA256 '+hashlib.sha256(out).hexdigest()+'\n'+array('background_seed_header',header)+array('background_seed',out))
font=[int(x,16) for x in re.findall(r"8'h([0-9a-fA-F]{2})",(ROOT/'tools/console-menu/font.vh').read_text())];assert len(font)==1024
(a.output/'font.json').write_text(json.dumps(font))
(a.output/'artwork.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256(a.image.read_bytes()).hexdigest(),compressed_bytes=len(out),compressed_sha256=hashlib.sha256(out).hexdigest(),row_palette=[224,234],size=[1280,720]),indent=2)+'\n')
print('Horizon artwork:',len(raw),'->',len(out),'bytes')
