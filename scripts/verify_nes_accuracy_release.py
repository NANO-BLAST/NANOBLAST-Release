#!/usr/bin/env python3
"""Reject a NES candidate unless its exact RTL passed the full shared-memory ROM.

The standalone independent-memory pass and initial-menu smoke test are not
sufficient release gates: both missed faults in the first two candidates.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--simulation', type=Path, required=True)
p.add_argument('--fpga-manifest', type=Path, required=True)
p.add_argument('--rom', type=Path, required=True)
a = p.parse_args()
simulation = json.loads(a.simulation.read_text())
fpga = json.loads(a.fpga_manifest.read_text())
def require(condition, message):
    if not condition:
        raise SystemExit(message)
require(simulation.get('scope') == 'full ROM with production shared SDRAM controller',
        'A complete production-SDRAM ROM run is required; a rendering smoke test is insufficient')
require(all(simulation.get(k) == 147 for k in ['passed', 'total', 'rom_tally', 'rom_pass_tally']),
        'AccuracyCoin did not complete with 147/147 in the shared controller')
slots = simulation.get('results', {})
require(len(slots) == 147 and all(isinstance(v, int) and v & 3 == 1 for v in slots.values()),
        'All 147 CPU-written result slots must report a pass')
require(simulation.get('rom_sha256') == hashlib.sha256(a.rom.read_bytes()).hexdigest(),
        'Simulation used a different ROM')
rtl_files = ['nes.v', 'apu.v', 'ppu.v', 'dpram.v', 'sdram_nes.v']
rtl_files += ['t65/T65'+n+'.v' for n in ['_Pack', '_ALU', '_MCode', '']]
for name in rtl_files:
    source = ROOT/'cores/nes/src'/name
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    for label, manifest in [('simulation', simulation), ('FPGA build', fpga)]:
        require(manifest.get('source_sha256', {}).get(str(source)) == digest,
                label+' does not match the current production RTL: '+name)
for name in ['board_memory.sv', 'board_main.cpp', 'nrom_fixture.sv']:
    source = ROOT/'cores/nes/tests/accuracycoin'/name
    require(simulation.get('source_sha256', {}).get(str(source)) == hashlib.sha256(source.read_bytes()).hexdigest(),
            'Shared-memory fixture changed after simulation: '+name)
rendering = simulation.get('rendering', {})
require(rendering.get('samples', 0) > 0 and rendering.get('stale_bytes') == 0,
        'Initial rendering consumed stale data or was not exercised')
for clock, target in {'af_a.clk': 21.6, 'fclk': 64.8, 'hclk': 74.25}.items():
    result = fpga.get('fmax', {}).get(clock, {})
    require(abs(result.get('constraint', 0)-target) < 0.001 and
            result.get('achieved', 0) >= result.get('constraint', float('inf')),
            'Required clock timing did not pass: '+clock)
require(fpga.get('checked_storage_pins') == 61, 'Storage pin check missing')
print('PASS exact production RTL: shared SDRAM AccuracyCoin 147/147, rendering, routed clocks and storage pins')
