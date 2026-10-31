"""Check routed timing/storage pins and pack isolated opaque-panel FPGA builds."""
import argparse,hashlib,html,json,re,subprocess,os
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('source_workspace',type=Path);p.add_argument('core',choices=['nes','sms','snes']);p.add_argument('--build',type=Path);a=p.parse_args()
ROOT=Path(__file__).resolve().parents[1];R=a.source_workspace.resolve();O=a.build.resolve() if a.build else ROOT/'hardware-tests/solid-loading'/a.core;W=R/'work'
def module(path):return next(iter(json.loads(path.read_text())['modules'].values()))
def pins(m):
    cells={}
    for c in m['cells'].values():
        pin={'OBUF':'O','IBUF':'I','IOBUF':'IO'}.get(c['type'])
        if pin:
            for b in c['connections'].get(pin,[]):cells[b]=c['attributes']['NEXTPNR_BEL']
    return {f'{n}[{i}]':cells[b] for n,p in m['ports'].items() for i,b in enumerate(p['bits']) if b in cells}
reference=pins(module(W/'nanoblast-menu-unified-pnr.json'))
expected={n:v for n,v in reference.items() if 'sdram' in n.lower() or n.startswith('flash_spi_')};assert len(expected)==61
if a.core in ('nes','sms'):
    timing=json.loads((O/'timing.json').read_text())['fmax'];assert timing and all(v['achieved']>=v['constraint'] for v in timing.values()),timing
    actual=pins(module(O/'routed.json'))
    for n,v in expected.items():assert actual.get(n)==v,(n,actual.get(n),v)
    env=dict(os.environ)
    with (O/'pack.log').open('w') as log:
        subprocess.run([str(W/'oss-cad-suite/bin/tabbypy3'),str(W/'pack-nanoblast.py'),'-d','GW2A-18C','-o',str(O/'image.fs'),str(O/'routed.json')],cwd=R,stdout=log,stderr=subprocess.STDOUT,env=env,check=True)
    fs=O/'image.fs';record=dict(timing_pass=True,checked_storage_pin_count=61,fmax=timing)
else:
    log=(O/'driver.log').read_text();assert 'Bitstream generation completed' in log and 'ERROR ' not in log
    impl=O/'impl/pnr';name='snestang_nano20k'
    text=re.sub(r'\s+',' ',html.unescape(re.sub('<[^>]+>',' ',(impl/(name+'_tr_content.html')).read_text())))
    setup=int(re.search(r'Numbers of Setup Violated Endpoints\s+(\d+)',text)[1]);hold=int(re.search(r'Numbers of Hold Violated Endpoints\s+(\d+)',text)[1]);assert setup==hold==0,(setup,hold)
    timing={}
    section=text.split('Max Frequency Summary:')[1].split('Total Negative Slack Summary:')[0]
    for clock,required in {'mclk':21.6,'fclk':86.4,'hclk':74.25,'hclk5':371.25}.items():
        m=re.search(rf'\b{clock}\s+([\d.]+)\(MHz\)\s+([\d.]+)\(MHz\)',section);assert m and float(m[2])>=required,(clock,m.groups() if m else None)
        timing[clock]=dict(required_MHz=required,actual_MHz=float(m[2]))
    report=(impl/(name+'.rpt.txt')).read_text();sites={}
    for line in report.splitlines():
        fields=[f.strip() for f in line.split('|')]
        if len(fields)>6 and re.fullmatch(r'IO[LRTB]\d+\[[AB]\]',fields[5]):
            side,n,half=re.fullmatch(r'IO([LRTB])(\d+)\[([AB])\]',fields[5]).groups();n=int(n)-1
            sites[fields[0]]={'L':f'X0Y{n}','R':f'X55Y{n}','T':f'X{n}Y0','B':f'X{n}Y54'}[side]+'/IOB'+half
    for n,v in expected.items():
        n=n[:-3] if n.endswith('[0]') and n[:-3] in sites else n
        assert sites[n]==v,(n,sites.get(n),v)
    for n,pair in {'tmds_clk_p':'33,34/5','tmds_d_p[0]':'35,36/4','tmds_d_p[1]':'37,38/4','tmds_d_p[2]':'39,40/4'}.items():
        row=next(line for line in report.splitlines() if line.split('|')[0].strip()==n)
        assert pair in row and 'LVCMOS33D' in row and '3.3' in row
    fs=impl/(name+'.fs');record=dict(timing_pass=True,setup_violations=setup,hold_violations=hold,checked_storage_pin_count=61,fmax=timing)
raw=bytes(int(line[i:i+8],2) for line in fs.read_text().splitlines() if line and not line.startswith('//') for i in range(0,len(line),8))
assert len(raw)==907418 and raw[-30:-24]==b'\x0a'+bytes(5) and raw[-14:-10]==b'\x08'+bytes(3)
if a.core=='snes':assert raw==(fs.with_suffix('.bin')).read_bytes()
(O/'image.bin').write_bytes(raw);record.update(raw_sha256=hashlib.sha256(raw).hexdigest(),raw_bytes=len(raw),board_test='pending')
(O/'image-check.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record,indent=2))
