# AccuracyCoin ROM regression

This fixture runs the unmodified 147-test AccuracyCoin ROM through the actual
NES CPU, APU, DMA, CPU bus, PPU and clock-divider RTL. It models the external
NROM-256 cartridge, synchronous memory and controller pins. It does not force
core state, patch the ROM, recognize a test inside the FPGA, or replace results.
The ROM is not distributed here.

The input used for the November 2026 investigation has SHA256
`86ec57789bd7421108cd76d22290d8a24e91b49f8b8b3ddcf09df7847357c6d8`.
The unchanged release PPU, SHA256
`ba8c3119e6756b80a7821a9dfa25f068f11b20280c1f6eb81cd46d75a7a90e99`,
reproduced the physical report of 137/147, including the same ten failures.

Run from any directory with Verilator and a C++ compiler available:

```sh
python3 cores/nes/tests/accuracycoin/run.py /path/to/AccuracyCoin.nes --out /tmp/nes-accuracy
```

Use `--verilator /absolute/path/to/verilator` when it is not on PATH. The output
contains build/run logs, the source/ROM hashes, a RAM capture and `results.json`.
The full-run exit status requires all 147 result slots **and the ROM's own
completed tally** to report 147 passes. Completed CPU writes supply every result.

`--page 20 --row 6 --frames 400` runs only OAMDATA Stress through controller
input; omit `--row` to run a page. `--latency 3` repeats with a three-master-clock
external-memory response. `--rtl /path/to/src` tests a baseline without changing
production files. Each output directory is isolated; do not share it between
concurrent runs. Existing matching Verilator builds are reused.

## Corrected hardware behavior

| Original failure | Original code | Correction |
|---|---:|---|
| $2004 Stress Test | 2 | OAM bus reads alternate between primary and secondary OAM after overflow; primary wrap continues scanning; an overflow hit finishes its remaining bytes before realignment. |
| $2007 Stress Test | 2 | PPUDATA read completion and scroll increment occur together, after the PPU DATA pipeline; dummy fetches use nametable addresses. |
| Stale BG Shift Registers | 4 | Sprite counters and pixel shifters have separate enables; each fetched sprite updates its own slot. |
| BG Serial In | 2 | The two background pattern planes shift in zero and one respectively. |
| ALE + Read | 2 | The low address latch persists across fetch phases and handles a simultaneous PPUDATA read. |
| Hybrid Addresses | 2 | PPUADDR updates v after its transfer pipeline; high address pins can change while the low latch retains its previous value. |
| Sprites On Scanline 0 | 2 | Pre-render fetch uses retained secondary OAM and the physical pre-render line's low byte (NTSC 261; PAL/Dendy 311). |
| Stale Sprite Shift Registers | 3 | Forced blank clocks X counters while preserving pixel shifters; HBlank fetches require rendering enabled. |
| Frozen OAM2 Increment | 2 | Secondary address overflow freezes increments until the rendering-dependent reset dots. |
| Misaligned OAM2 Address | 3 | Sprite fetch uses the persistent secondary address, including after interrupted rendering. |

The focused OAM boundary tests sample the bus **before** the address-advance
edge. Their expected bytes are retained. The Loopy arithmetic test drives the
completed-read pin and drains PPUADDR's transfer pipeline before its existing
exhaustive arithmetic checks. `tb_sprite_counters.sv` independently checks forced
blank countdown, shifter retention, HBlank and partial fetch slot isolation using
module pins.

## Scope of the evidence

A ROM simulation pass is not a physical Tang Nano 20K result. The fixture does
not model SDRAM electrical behavior, routed delays or the full boot/menu/HDMI
path. Focused tests separately exercise those RTL blocks and memory request
phases. Hardware validation still needs a temporary SRAM load, AccuracyCoin,
representative mapper games, audio, region switching and menu return. Preserve
the installed release until those checks succeed.

Build the live candidate with `scripts/build_nes_accuracy.py`; the archived
release inputs intentionally remain unchanged. This uses the preserved native
HDMI pin constraints and the verified HDMI packer. The packer reads the existing
SMS/Game Gear vendor-pad reference, whose SHA256 is
`3a2f54a827b33371b459519e610605de857c2ebe9e2c10ace02bab44c42567b1`.
A failed timing route stops the build before packing.
