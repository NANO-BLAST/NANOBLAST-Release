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
p.add_argument('--max-lut', type=int, choices=[4, 6], default=6,
               help='ABC mapping width; use 4 with fresh placement for CRT builds')
p.add_argument('--placement-timeout', type=int, default=1000,
               help='Search divisor N: max(10000, cells squared / N) attempts per cell')
p.add_argument('--placement-density', type=float, default=0.9,
               help='Analytical target density (0 < beta <= 1); physical limits still apply')
p.add_argument('--synth-only', action='store_true')
p.add_argument('--no-reference-placement', action='store_true',
               help='Allow all storage placement to change instead of retaining release locations')
a = p.parse_args()
if not 0 < a.placement_density <= 1:
    p.error('--placement-density must be greater than 0 and at most 1')
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
synthesis = relocate((archive / 'synthesis.ys').read_text())
assert synthesis.count('abc9 -maxlut 6') == 1
synthesis = synthesis.replace('abc9 -maxlut 6', 'abc9 -maxlut ' + str(a.max_lut))
(a.out / 'synthesis.ys').write_text(synthesis)
extra_inputs = [ROOT / 'cores/nes/src/nano20k/gowin_pll_hdmi.v',
                ROOT / 'cores/nes/src/nano20k/gowin_pll_nes.v',
                ROOT / 'cores/nes/src/iosys/gowin_dpb_menu.v',
                ROOT / 'build-inputs/original-workspace/work/gowin-slang-primitives.v',
                ROOT / 'tools/legacy/nanoblast-native.cst',
                ROOT / 'cores/nes/constraints/nanoblast-clocks.py',
                ROOT / 'cores/nes/constraints/storage-pins.json',
                ROOT / 'cores/nes/constraints/release-storage-placement.json',
                ROOT / 'cores/sms-gamegear/vendor-hdmi-io-fuses.json',
                ROOT / 'build-inputs/original-workspace/work/pack-nanoblast.py']
manifest = {'reference_placement': not a.no_reference_placement,
            'max_lut': a.max_lut, 'placement_density': a.placement_density, 'seed': a.seed, 'placement_timeout': a.placement_timeout, 'source_sha256': {
    source: hashlib.sha256(Path(source).read_bytes()).hexdigest()
    for source in sources.splitlines()},
    'build_support_sha256': {str(source): hashlib.sha256(source.read_bytes()).hexdigest()
                             for source in extra_inputs}}
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
route_input = a.out / 'nes.json'
if not a.no_reference_placement:
    reference = json.loads((ROOT / 'cores/nes/constraints/release-storage-placement.json').read_text())
    design = json.loads(route_input.read_text())
    reused = 0
    for name, cell in design['modules']['nestang_top']['cells'].items():
        location = reference['cells'].get(name)
        if location and cell['type'] == location['type']:
            cell.setdefault('attributes', {})['BEL'] = location['bel']
            reused += 1
    route_input = a.out / 'nes-placement.json'
    route_input.write_text(json.dumps(design))
    manifest['reused_storage_locations'] = reused
    (a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
run([a.nextpnr, '--json', str(route_input), '--write', str(a.out / 'nes-routed.json'),
     '--device', 'GW2AR-LV18QN88C8/I7', '--vopt', 'family=GW2A-18C',
     '--vopt', 'cst=' + str(ROOT / 'tools/legacy/nanoblast-native.cst'),
     '--pre-pack', str(ROOT / 'cores/nes/constraints/nanoblast-clocks.py'),
     '--freq', '27', '--seed', str(a.seed),
     '--placer-heap-cell-placement-timeout', str(a.placement_timeout),
     '--placer-heap-beta', str(a.placement_density), '--report', str(a.out / 'timing.json'),
     '--sdf', str(a.out / 'nes.sdf')], 'route')
# Check actual clock targets and all storage pads before producing an image.
fmax = json.loads((a.out / 'timing.json').read_text())['fmax']
for clock, target in {'af_a.clk': 21.6, 'fclk': 64.8, 'hclk': 74.25}.items():
    entry = fmax[clock]
    if abs(entry['constraint'] - target) > 0.001 or entry['achieved'] < entry['constraint']:
        raise SystemExit('Clock target/timing check failed: ' + clock)
routed = next(iter(json.loads((a.out / 'nes-routed.json').read_text())['modules'].values()))
by_bit = {}
for cell in routed['cells'].values():
    pin = {'OBUF': 'O', 'IBUF': 'I', 'IOBUF': 'IO'}.get(cell['type'])
    if pin:
        for bit in cell['connections'].get(pin, []):
            by_bit[bit] = cell['attributes']['NEXTPNR_BEL']
pins = {f'{name}[{i}]': by_bit[bit] for name, port in routed['ports'].items()
        for i, bit in enumerate(port['bits']) if bit in by_bit}
expected = json.loads((ROOT / 'cores/nes/constraints/storage-pins.json').read_text())['pins']
assert len(expected) == 61
for pin, location in expected.items():
    if pins.get(pin) != location:
        raise SystemExit('Storage pin moved: ' + pin)
manifest.update(fmax=fmax, checked_storage_pins=61)
(a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
# Packing is reached only after the timing-checked route succeeds.
if a.pack_python:
    work = a.out / 'work'
    work.mkdir(exist_ok=True)
    shutil.copy2(ROOT / 'cores/sms-gamegear/vendor-hdmi-io-fuses.json', work / 'vendor-hdmi-io-fuses.json')
    run([a.pack_python, str(ROOT / 'build-inputs/original-workspace/work/pack-nanoblast.py'),
         '-d', 'GW2A-18C', '-o', str(a.out / 'nes-accuracycoin.fs'),
         str(a.out / 'nes-routed.json')], 'pack', a.out)
    fs = a.out / 'nes-accuracycoin.fs'
    raw = bytes(int(line[i:i + 8], 2) for line in fs.read_text().splitlines()
                if line and not line.startswith('//') for i in range(0, len(line), 8))
    if len(raw) != 907418 or raw[-30:-24] != b'\x0a' + bytes(5) or raw[-14:-10] != b'\x08' + bytes(3):
        raise SystemExit('Unexpected device image size or configuration footer')
    (a.out / 'nes-accuracycoin.bin').write_bytes(raw)
    manifest.update(image_sha256=hashlib.sha256(raw).hexdigest(), image_bytes=len(raw))
    (a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print('Build outputs:', a.out)
