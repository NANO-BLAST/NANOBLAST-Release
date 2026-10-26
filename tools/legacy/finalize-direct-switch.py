"""Verify routed timing/pins, pack native direct-SPI images, pin recovery source."""
from pathlib import Path
import argparse,json,subprocess,zlib,hashlib
p=argparse.ArgumentParser();p.add_argument('--core',choices=['nes','sms']);p.add_argument('--metadata',action='store_true');p.add_argument('--out',default='outputs/direct-flash-switch');a=p.parse_args()
w=Path('work');out=Path(a.out)
def module(path):return next(iter(json.loads(path.read_text())['modules'].values()))
def pins(m):
 cells={}
 for c in m['cells'].values():
  pin={'OBUF':'O','IBUF':'I','IOBUF':'IO'}.get(c['type'])
  if pin:
   for bit in c['connections'].get(pin,[]):cells[bit]=c['attributes']['NEXTPNR_BEL']
 return {f'{name}[{i}]':cells[bit] for name,port in m['ports'].items() for i,bit in enumerate(port['bits']) if bit in cells}
reference=pins(module(w/'nanoblast-menu-unified-pnr.json'))
for core,name in [('nes','nanoblast-nes'),('sms','smstang-nano20k')]:
 if a.metadata:break
 if a.core and core!=a.core:continue
 routed=out/core/(core+'-pnr.json');timing=json.loads((out/core/'timing.json').read_text())['fmax']
 assert timing and all(v['achieved']>=v['constraint'] for v in timing.values()),timing
 current=pins(module(routed));checked={k:v for k,v in reference.items() if 'sdram' in k.lower() or k.startswith('flash_spi_')}
 assert len([k for k in checked if 'sdram' in k.lower()])==55
 for key,value in checked.items():assert current.get(key)==value,(core,key,current.get(key),value)
 (out/core/'pin-timing-check.json').write_text(json.dumps({'result':'PASS','fmax':timing,'checked_pins':checked},indent=2)+'\n')
 with (out/core/'pack.log').open('w') as log:
  subprocess.run([str(w/'oss-cad-suite/bin/tabbypy3'),str(w/'pack-nanoblast.py'),'-d','GW2A-18C','-o',str(out/(name+'.fs')),str(routed)],stdout=log,stderr=subprocess.STDOUT,check=True)
 raw=bytearray()
 for line in (out/(name+'.fs')).read_text().splitlines():
  line=line.strip()
  if not line or line.startswith('//'):continue
  assert set(line)<=set('01') and len(line)%8==0
  raw.extend(int(line[i:i+8],2) for i in range(0,len(line),8))
 assert len(raw)==907418,len(raw)
 (out/(name+'.bin')).write_bytes(raw)
 print(core,len(raw),f'CRC {zlib.crc32(raw):08x}',hashlib.sha256(raw).hexdigest(),flush=True)
if a.core:raise SystemExit(0)
nes=(out/'nanoblast-nes.bin').read_bytes();legacy=Path('outputs/menu-unified/nanoblast-menu-unified.bin').read_bytes()
values=[zlib.crc32(legacy[off:off+256]) for off in (0,0x10000,0x80000)]
header='#pragma once\n// Generated from the complete direct-SPI NES image and verified legacy boot samples.\nconstexpr uint32_t NanoRecoveryCRC=0x%08x;\nconstexpr uint32_t NanoLegacySampleCRC[3]={%s};\n'%(zlib.crc32(nes),','.join('0x%08x'%v for v in values))
(w/'firmware-bl616/fpga/nano_core_images.h').write_text(header);(out/'nano_core_images.h').write_text(header)
subprocess.run(['python3',str(w/'make-sms-core-assets.py'),'--nes',str(out/'nanoblast-nes.bin'),'--sms',str(out/'smstang-nano20k.bin'),'--out',str(out)],check=True)
