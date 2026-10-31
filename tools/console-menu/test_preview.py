"""Check the compiled production menu/browser frame bounds and navigation."""
import json,subprocess
from pathlib import Path
P=Path('/tmp/nanoblast-menu-preview')
def frame(keys=()):
 f=json.loads(subprocess.check_output([str(P),*map(str,keys)]))
 assert len(f['rows'])==28 and all(len(row)==32 for row in f['rows'])
 assert all('  ' not in row.strip() for row in f['rows'][:26]), 'Extra word spacing'
 f['rows']=[' '.join(row.split()).ljust(32) for row in f['rows']]
 return f
def press(*keys):return [v for k in keys for v in (k,0)]
f=frame();assert all(not row.strip() for row in f['rows'][24:26]);assert f['helpers'] and 'Select' in f['rows'][26] and 'Back' in f['rows'][26];assert 'MAIN MENU' in f['rows'][15] and f['selected']==19 and 'PLAY GAMES' in f['rows'][19]
cores=press(32,256);f=frame(cores);assert 'CHOOSE CORE' in f['rows'][15] and 'GAME BOY' in f['rows'][22]
f=frame(cores+press(32,256,256));assert '/sms' in f['rows'][16]
settings=press(32,32,256);f=frame(settings);assert 'SETTINGS' in f['rows'][15]
clock=settings+press(32,32,32,256);f=frame(clock);assert 'SET CLOCK' in f['rows'][15] and 'Year' in f['rows'][17] and 'Set clock' in f['rows'][22]
f=frame(clock+press(256,16));assert '[2027]' in f['rows'][17]
advanced=settings+press(32,32,32,32,256);f=frame(advanced);assert 'ADVANCED' in f['rows'][15] and 'USB ROM' in f['rows'][21]
f=frame(advanced+press(32,32,32,256));assert not f['theme']
f=frame(press(256));assert 'GAME LIBRARY' in f['rows'][15] and '/nes' in f['rows'][16] and 'Adventure Island' in f['rows'][17]
f=frame(press(256,128));assert 'Page 2/2' in f['rows'][25] and 'River Rescue' in f['rows'][17]
f=frame(press(256,256));assert not f['visible'] and 'Adventure Island' in f['game']
f=frame(press(256,256,1028));assert f['visible'] and not f['transfer'] and 'Restart before USB transfer' in f['rows'][25]
f=frame(press(1028));assert f['transfer'] and 'USB ROM TRANSFER' in f['rows'][15] and not f['highlight'] and not f['helpers'] and not f['rows'][26].strip()
print('PASS: home, cores, settings, clock editing, advanced, OLED, game paging, launch/resume guard, USB and bounded 32x28 frames')
