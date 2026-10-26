from pathlib import Path
import re,html,struct,zlib,json,hashlib
P=Path(__file__).resolve().parent;O=P/'build';I=O/'impl/pnr'
log=(O/'gowin-build.log').read_text();assert 'Bitstream generation completed' in log and 'ERROR ' not in log
s=html.unescape(re.sub('<[^>]+>',' ',(I/'nanoblast_gb_mister_tr_content.html').read_text()));s=re.sub(r'\s+',' ',s)
for n in ['Setup','Hold']:assert re.search(r'Numbers of '+n+r' Violated Endpoints\s+0\b',s)
fmax={}
for n,target in [('main',27),('hclk',74.25)]:
 m=re.search(r'\b'+n+r'\s+([\d.]+)\(MHz\)\s+([\d.]+)\(MHz\)',s.split('Max Frequency Summary:')[1]);assert m and float(m[1])>=target and float(m[2])>=target
 fmax[n]={'required_MHz':target,'actual_MHz':float(m[2])}
report=(I/'nanoblast_gb_mister.rpt.txt').read_text();pins={}
for l in report.splitlines():
 f=[a.strip() for a in l.split('|')]
 if len(f)>6 and re.fullmatch(r'IO[LRTB]\d+\[[AB]\]',f[5]):pins[f[0]]=f[2].split('/')[0]
cst=(P/'constraints/gb.cst').read_text();checked={}
for n,pin in re.findall(r'IO_LOC\s+"([^"]+)"\s+([^;]+);',cst):
 if n not in pins:continue # swept unused external reset pins or negative differential ports
 assert pin.replace(' ','')==pins[n],(n,pin,pins[n]);checked[n]=pin
assert len(checked)==33,len(checked)
raw=bytes(int(l[i:i+8],2) for l in (I/'nanoblast_gb_mister.fs').read_text().splitlines() if l and not l.startswith('//') for i in range(0,len(l),8))
assert len(raw)==907418 and raw==(I/'nanoblast_gb_mister.bin').read_bytes()
assert raw[-30:-24]==b'\x0a'+bytes(5) and raw[-14:-10]==b'\x08'+bytes(3)
(O/'gb-mister-nano20k.bin').write_bytes(raw)
reference=json.loads((P/'constraints/storage-pins.json').read_text())['checked_storage_pins']
sites={}
for line in report.splitlines():
 f=[x.strip() for x in line.split('|')]
 if len(f)>6 and re.fullmatch(r'IO[LRTB]\d+\[[AB]\]',f[5]):
  side,n,half=re.fullmatch(r'IO([LRTB])(\d+)\[([AB])\]',f[5]).groups();n=int(n)-1
  sites[f[0]]={'L':f'X0Y{n}','R':f'X55Y{n}','T':f'X{n}Y0','B':f'X{n}Y54'}[side]+'/IOB'+half
for n,pin in reference.items():assert sites[n]==pin,n
r={'setup_violations':0,'hold_violations':0,'fmax':fmax,'storage_pin_checks':len(reference),'external_pin_checks':len(checked),'raw_bytes':len(raw),'raw_sha256':hashlib.sha256(raw).hexdigest(),'board_test':'pending'}
(O/'image-check.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
