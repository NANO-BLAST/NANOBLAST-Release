#!/usr/bin/env python3
"""Run an unmodified AccuracyCoin NROM through the production NES RTL.

Only external NROM/RAM and controller pins are simulated. No core state is
forced, no ROM is patched, and no test result is substituted.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
NES = HERE.parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('rom', type=Path)
p.add_argument('--rtl', type=Path, default=NES / 'src')
p.add_argument('--verilator', default='verilator')
p.add_argument('--out', type=Path, required=True)
p.add_argument('--frames', type=int, default=5500)
p.add_argument('--page', type=int, choices=range(1, 23))
p.add_argument('--row', type=int, help='One-based test row; omit to run the page')
p.add_argument('--latency', type=int, choices=[1, 2, 3], default=1,
               help='External-memory response latency in master clocks')
p.add_argument('--baseline', type=Path, help='Previous full-run ram.bin')
a = p.parse_args()
if a.row is not None and (not a.page or a.row < 1):
    p.error('--row requires --page and a positive row number')
a.out = a.out.resolve()
a.out.mkdir(parents=True, exist_ok=True)
a.rom, a.rtl = a.rom.resolve(), a.rtl.resolve()
rom = a.rom.read_bytes()
if len(rom) != 40976 or rom[:6] != b'NES\x1a\x02\x01':
    p.error('Expected AccuracyCoin NROM-256 with 8K CHR ROM')
prg = rom[16:32784]
# Inspect only the ROM's menu table; pointers include names with compressed
# addressing-mode strings that cannot be decoded as plain ASCII.
start = prg.index(b'ROM is not writable')
end = prg.index(b'Misaligned OAM2 Address') + len(b'Misaligned OAM2 Address') + 5
addresses = sorted({0x400 + prg[i + 1] for i in range(start, end - 4)
                    if prg[i] == 255 and prg[i + 2] == 4 and prg[i + 4] >= 128})
if len(addresses) != 147:
    p.error('Unsupported menu layout: this fixture is pinned to the 147-test ROM')
names = {0x400 + m[2][0]: m[1].decode('ascii') for m in re.finditer(
    rb'([ -~]{3,80})\xff([\x00-\xff])\x04([\x00-\xff])([\x80-\xff])', prg[start:end])}
sources = [a.rtl / f for f in ['nes.v', 'apu.v', 'ppu.v', 'dpram.v']]
sources += [a.rtl / 't65' / f'T65{s}.v' for s in ['_Pack', '_ALU', '_MCode', '']]
sources += [HERE / 'nrom_fixture.sv', HERE / 'main.cpp']
hashes = {str(s): hashlib.sha256(s.read_bytes()).hexdigest() for s in sources}
version = subprocess.check_output([a.verilator, '--version'], text=True).strip()
manifest = {'sources': hashes, 'verilator': version}
obj = a.out / 'obj'
exe = obj / 'VNES'
build_record = a.out / 'build.json'
if not exe.exists() or not build_record.exists() or json.loads(build_record.read_text()) != manifest:
    if obj.exists():
        shutil.rmtree(obj)
    command = [a.verilator, '--cc', '--exe', '--build', '-j', '4', '-CFLAGS', '-O3',
               '-Wno-fatal', '--top-module', 'NES', '--Mdir', str(obj), *map(str, sources)]
    with (a.out / 'build.log').open('w') as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print((a.out / 'build.log').read_text()[-6000:], file=sys.stderr)
        raise SystemExit(result.returncode)
    build_record.write_text(json.dumps(manifest, indent=2) + '\n')
command = [str(exe), str(a.rom), str(a.frames)]
if a.page:
    command.append(str(a.page))
    if a.row:
        command.append(str(a.row))
env = dict(os.environ, MEMORY_LATENCY=str(a.latency))
with (a.out / 'run.log').open('w') as log:
    result = subprocess.run(command, cwd=a.out, env=env, stdout=log, stderr=subprocess.STDOUT)
if result.returncode:
    raise SystemExit(result.returncode)
ram = (a.out / 'ram.bin').read_bytes()
results = []
for address in addresses:
    value = ram[address]
    state = 'not_run' if value == 0 else {1: 'pass', 2: 'fail', 3: 'incomplete'}.get(value & 3, 'unknown')
    results.append({'address': f'${address:04X}', 'name': names.get(address, f'Result ${address:04X}'),
                    'state': state, 'raw': value, 'code': value >> 2})
failures = [r for r in results if r['state'] not in ['pass', 'not_run']]
passed = sum(r['state'] == 'pass' for r in results)
regressions = []
if a.baseline:
    baseline = a.baseline.read_bytes()
    regressions = [f'${address:04X}' for address in addresses
                   if baseline[address] & 3 == 1 and ram[address] & 3 != 1]
summary = {'rom_sha256': hashlib.sha256(rom).hexdigest(), 'rtl_sha256': hashes,
           'verilator': version, 'memory_latency': a.latency, 'page': a.page, 'row': a.row,
           'passed': passed, 'total': len(addresses), 'full_run': not a.page,
           'rom_tally': ram[0x37], 'rom_pass_tally': ram[0x38], 'regressions': regressions,
           'results': results}
(a.out / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
print(f'{passed}/{len(addresses)} result slots pass; ROM table {ram[0x38]}/{ram[0x37]}')
for r in failures:
    print(f"{r['address']} {r['name']}: {r['state']} code {r['code']}")
if regressions:
    print('Regressions:', ', '.join(regressions))
full_complete = passed == len(addresses) and ram[0x37] == 147 and ram[0x38] == 147
raise SystemExit(0 if not failures and not regressions and (passed > 0 if a.page else full_complete) else 1)
