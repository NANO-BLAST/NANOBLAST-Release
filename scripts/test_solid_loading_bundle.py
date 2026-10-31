"""Offline regression checks for the real prepared core/menu update bundle."""
import argparse,json,shutil,tempfile
from pathlib import Path
from install_solid_loading import load,development_menu,ROOT
p=argparse.ArgumentParser();p.add_argument('bundle',type=Path);p.add_argument('backup',type=Path);a=p.parse_args()
before=a.backup.read_bytes();changes,plan=load(a.bundle);after=plan(before,changes)
try:development_menu.load(a.bundle/'development-menu.json',ROOT/'src-tauri/resources/nanoblast-v0.2.0')
except ValueError:pass
else:raise AssertionError('Core bundle accepted by menu-only installer')
assert len(after)==len(before)==0x400000
for start,end in [(0,0x40000),(0xe8000,0x201000),(0x3ff000,0x400000)]:assert before[start:end]==after[start:end]
assert plan(after,changes)==after
for offset in [0x40000+4096+100,0x201000+4096+100]:
    bad=bytearray(before);bad[offset]^=1
    try:plan(bytes(bad),changes)
    except ValueError:pass
    else:raise AssertionError('Unknown baseline accepted')
try:plan(before,[(0,b'unsafe')])
except ValueError:pass
else:raise AssertionError('Unrequested write accepted')
with tempfile.TemporaryDirectory(prefix='nanoblast-bundle-') as tmp:
    target=Path(tmp)/'bundle';shutil.copytree(a.bundle,target)
    p=target/'core-manifest.json';m=json.loads(p.read_text());m['assets'][0]['file']='../escape.core';p.write_text(json.dumps(m))
    try:load(target)
    except ValueError:pass
    else:raise AssertionError('Escaping asset accepted')
    shutil.rmtree(target);shutil.copytree(a.bundle,target)
    p=target/'development-menu.json';m=json.loads(p.read_text());m['sha256']='0'*64;p.write_text(json.dumps(m))
    try:load(target)
    except ValueError:pass
    else:raise AssertionError('Bad menu checksum accepted')
print('PASS bundle: full core decode, menu/table match, protected bytes, idempotence, unknown baselines, write bounds, traversal and corruption rejection')
