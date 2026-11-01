"""Build the shared-controller simulation without changing production behavior."""
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent

def build(rom, rtl, out, verilator):
    out.mkdir(parents=True, exist_ok=True)
    # Exact Nano SDRAM geometry/lane selection. Select the PPU's existing
    # behavioral OAM RAM; vendor-DPB behavior is checked by focused tests.
    config = out / 'config.v'
    contents = (rtl / 'nano20k/config.v').read_text().replace(
        '`define GW_IDE', '// Behavioral OAM in this scheduling fixture')
    if not config.exists() or config.read_text() != contents:
        config.write_text(contents)
    sources = [config, HERE/'board_memory.sv', rtl/'nes.v', rtl/'sdram_nes.v']
    sources += [rtl/name for name in ['apu.v', 'ppu.v', 'dpram.v']]
    sources += [rtl/'t65'/('T65'+name+'.v') for name in ['_Pack', '_ALU', '_MCode', '']]
    sources += [HERE/'nrom_fixture.sv', HERE/'board_main.cpp']
    manifest = dict(source_sha256={str(s): hashlib.sha256(s.read_bytes()).hexdigest()
                                  for s in sources},
                    rom_sha256=hashlib.sha256(rom.read_bytes()).hexdigest())
    (out/'inputs.json').write_text(json.dumps(manifest, indent=2)+'\n')
    with (out/'build.log').open('w') as log:
        subprocess.run([verilator, '--cc', '--exe', '--build', '-j', '4',
                        '-CFLAGS', '-O3', '-Wno-fatal', '--top-module', 'NESBoard',
                        '--Mdir', str(out/'obj'), *map(str, sources)],
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    return out/'obj/VNESBoard', manifest
