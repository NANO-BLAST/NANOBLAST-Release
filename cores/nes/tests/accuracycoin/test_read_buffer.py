#!/usr/bin/env python3
"""Run an original CPU program that checks 64 buffered CIRAM reads via real SDRAM.

No AccuracyCoin ROM is needed. The CPU writes distinct bytes through $2007,
rewinds PPUADDR, makes a dummy read, then checks the buffered result. The real
CPU's ROM fetches contend for SDRAM during those reads. This fails all 64 cases
on r2 and passes with early blanking prefetch; no PPU state is forced.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
from board_build import build

HERE = Path(__file__).resolve().parent
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--rtl', type=Path, default=HERE.parents[1]/'src')
p.add_argument('--verilator', default='verilator')
p.add_argument('--simulator', type=Path, help='Reuse an already built NESBoard simulator')
a = p.parse_args()
a.out = a.out.resolve()
a.out.mkdir(parents=True, exist_ok=True)

code = bytearray()
labels, branches = {}, []
def emit(*data): code.extend(data)
def label(name): labels[name] = len(code)
def branch(op, name):
    emit(op, 0)
    branches.append((len(code)-1, name))
def absolute(op, address): emit(op, address & 255, address >> 8)

# SEI, CLD, initialize stack, PPUCTRL and PPUMASK; wait two vblanks.
emit(0x78, 0xd8, 0xa2, 0xff, 0x9a, 0xe8)
emit(0x86, 2, 0x86, 3)  # Clear the error counter and completion marker.
absolute(0x8e, 0x2000)
absolute(0x8e, 0x2001)
absolute(0x2c, 0x2002)
for name in ['wait1', 'wait2']:
    label(name)
    absolute(0x2c, 0x2002)
    branch(0x10, name)
emit(0xa2, 0)  # X selects a distinct address and value in every iteration.
label('loop')
emit(0x8a, 0x49, 0xa5, 0x48)  # TXA; EOR #$A5; PHA.
absolute(0x2c, 0x2002)
emit(0xa9, 0x2c)
absolute(0x8d, 0x2006)
emit(0x8a)
absolute(0x8d, 0x2006)
emit(0x68, 0x48)
absolute(0x8d, 0x2007)  # Write the test byte to CIRAM.
absolute(0x2c, 0x2002)
emit(0xa9, 0x2c)
absolute(0x8d, 0x2006)
emit(0x8a)
absolute(0x8d, 0x2006)
absolute(0xad, 0x2007)  # Dummy read must populate the PPU's internal buffer.
emit(0x68, 0x8a, 0x49, 0xa5, 0x85, 5)
absolute(0xad, 0x2007)
absolute(0x9d, 0x0300)  # Retain actual bytes for an independent host check.
emit(0xc5, 5)
branch(0xf0, 'match')
emit(0xe6, 2)  # Count wrong buffered bytes.
label('match')
emit(0xe8, 0xe0, 64)
branch(0xd0, 'loop')
emit(0xa9, 1, 0x85, 3)  # Completion marker.
label('halt')
absolute(0x4c, 0x8000+labels['halt'])
for at, name in branches:
    delta = labels[name]-(at+1)
    assert -128 <= delta < 128
    code[at] = delta & 255
prg = bytearray(b'\xea'*32768)
prg[:len(code)] = code
for offset in [0x7ffa, 0x7ffc, 0x7ffe]:
    prg[offset:offset+2] = b'\x00\x80'
rom = a.out/'read_buffer_probe.nes'
rom.write_bytes(b'NES\x1a\x02\x01'+bytes(10)+prg+bytes(8192))
if a.simulator:
    simulator, manifest = a.simulator.resolve(), dict(
        reused_simulator=str(a.simulator.resolve()),
        rom_sha256=hashlib.sha256(rom.read_bytes()).hexdigest())
else:
    simulator, manifest = build(rom, a.rtl.resolve(), a.out, a.verilator)
with (a.out/'run.log').open('w') as log:
    subprocess.run([str(simulator), str(rom), '5'], cwd=a.out,
                   stdout=log, stderr=subprocess.STDOUT, check=True)
ram = (a.out/'ram.bin').read_bytes()
actual = ram[0x300:0x340]
expected = bytes(x ^ 0xa5 for x in range(64))
summary = dict(**manifest, completed=ram[3] == 1, wrong_bytes=ram[2],
               correct_bytes=sum(x == y for x, y in zip(actual, expected)),
               expected_hex=expected.hex(), actual_hex=actual.hex())
(a.out/'results.json').write_text(json.dumps(summary, indent=2)+'\n')
print(f"Buffered CIRAM reads: {summary['correct_bytes']}/64; CPU error count {ram[2]}")
assert summary['completed'] and ram[2] == 0 and actual == expected
