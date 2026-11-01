#!/usr/bin/env python3
"""Build the live NES source without modifying the archived release inputs."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
OLD_WORK = '/Users/ryan/Documents/Codex/2026-10-14/is-x20/work'
OLD_SETUP = '/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--yosys', default='yosys')
p.add_argument('--nextpnr', default='nextpnr-himbaechel')
p.add_argument('--pack-python', help='Python with the matching apycula package; also packs the FS image')
p.add_argument('--seed', type=int, default=2)
p.add_argument('--placement-timeout', type=int, default=1000,
               help='Bound legalization search attempts; does not relax timing')
p.add_argument('--synth-only', action='store_true')
a = p.parse_args()
a.out = a.out.resolve()
a.out.mkdir(parents=True, exist_ok=True)
archive = ROOT / 'build-inputs/setup-workspace/hardware-tests/solid-loading/nes'
replacements = {
    OLD_WORK + '/nanoblast/src': str(ROOT / 'cores/nes/src'),
    OLD_WORK + '/native-cart': str(ROOT / 'cores/nes/native-cart'),
    OLD_WORK + '/gowin-slang-primitives.v': str(ROOT / 'build-inputs/original-workspace/work/gowin-slang-primitives.v'),
    OLD_SETUP + '/fpga/solid-loading': str(ROOT / 'fpga/solid-loading'),
    OLD_SETUP + '/hardware-tests/solid-loading/nes': str(a.out),
}
def relocate(text):
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text
sources = relocate((archive / 'sources.f').read_text())
for source in sources.splitlines():
    if not Path(source).is_file():
        raise SystemExit('Missing build input: ' + source)
(a.out / 'sources.f').write_text(sources)
(a.out / 'synthesis.ys').write_text(relocate((archive / 'synthesis.ys').read_text()))
manifest = {'seed': a.seed, 'placement_timeout': a.placement_timeout, 'source_sha256': {
    source: hashlib.sha256(Path(source).read_bytes()).hexdigest()
    for source in sources.splitlines()}}
(a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
def run(command, name, cwd=None):
    print('Running', name, flush=True)
    with (a.out / (name + '.log')).open('w') as log:
        result = subprocess.run(command, cwd=cwd, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print((a.out / (name + '.log')).read_text()[-5000:], file=sys.stderr)
        raise SystemExit(result.returncode)
run([a.yosys, '-m', 'slang', '-s', str(a.out / 'synthesis.ys')], 'synthesis')
if a.synth_only:
    raise SystemExit(0)
run([a.nextpnr, '--json', str(a.out / 'nes.json'), '--write', str(a.out / 'nes-routed.json'),
     '--device', 'GW2AR-LV18QN88C8/I7', '--vopt', 'family=GW2A-18C',
     '--vopt', 'cst=' + str(ROOT / 'tools/legacy/nanoblast-native.cst'),
     '--freq', '27', '--seed', str(a.seed),
     '--placer-heap-cell-placement-timeout', str(a.placement_timeout), '--report', str(a.out / 'timing.json'),
     '--sdf', str(a.out / 'nes.sdf')], 'route')
# Packing is reached only after the timing-checked route succeeds.
if a.pack_python:
    work = a.out / 'work'
    work.mkdir(exist_ok=True)
    shutil.copy2(ROOT / 'cores/sms-gamegear/vendor-hdmi-io-fuses.json', work / 'vendor-hdmi-io-fuses.json')
    run([a.pack_python, str(ROOT / 'build-inputs/original-workspace/work/pack-nanoblast.py'),
         '-d', 'GW2A-18C', '-o', str(a.out / 'nes-accuracycoin.fs'),
         str(a.out / 'nes-routed.json')], 'pack', a.out)
print('Build outputs:', a.out)
