# System 16B experimental port — checkpoint 1

This directory is an unfinished port foundation, not a working console core.
It supplies reproducible game-logic synthesis preparation and tested platform
components. No board top, routed bitstream, firmware ZIP or playable build is
provided. Existing NANOBLAST firmware/core assets are untouched.

## Provenance

- Jotego JT cores: https://github.com/jotego/jtcores
- Pinned commit: `7637835e6b3656c5897bff7c4c421902c27fe7fb`.
- The CPU/sound submodules must be checked out at the gitlinks of that commit:
  `fx68k`, `jt51`, `jt7759`, `jt8255`.
- Native SDRAM timing/geometry derives from NANOBLAST `sms_nano_sdram.sv`;
  its independent SDRAM test model is adapted from `sms-gamegear/tests/sdram_tb.sv`.
- This cloud checkout starts at NANOBLAST commit
  `eced569c8c15323b85ba5016dfec44383d7013ff`; it is separate from the Mac's
  uncommitted CRT/menu work. The Mac has not been modified by this continuation.

## Game-logic probes

`prepare_probe.py` takes a pinned JT checkout, a compiled `jtframe` CLI and an
output directory. Build the CLI from `modules/jtframe/src/jtframe` using the Go
version specified there. Set normal Go caches to writable directories as needed;
do not source the upstream setprj script for these probes.

```sh
git clone --filter=blob:none --no-checkout https://github.com/jotego/jtcores.git jtcores
git -C jtcores fetch --depth 1 origin 7637835e6b3656c5897bff7c4c421902c27fe7fb
git -C jtcores checkout --detach 7637835e6b3656c5897bff7c4c421902c27fe7fb
git -C jtcores submodule update --init modules/fx68k modules/jt51 modules/jt7759 modules/jt8255
cd jtcores/modules/jtframe/src/jtframe
go build -o /absolute/path/jtframe .
```

From NANOBLAST's repository root:

```sh
python3 cores/system16-experimental/prepare_probe.py \
  --upstream /absolute/path/jtcores --jtframe /absolute/path/jtframe \
  --out /absolute/path/probe --logic-mcu-rom
cd /absolute/path/probe
yosys -m slang -s synthesis.ys > synthesis.log 2>&1
```

`--goldenaxe` selects only `goldnaxe3` (World set 3, FD1094), fixes its header
configuration and removes the unused 8751. This does not support every Golden Axe
set. The general profile with `--logic-mcu-rom` retains the 8751 and maps its
unchanged microcode contents into LUT logic instead of block RAM.

Other preparation changes are limited to generic RAM attributes, mapper event
syntax and blocking initial assignments for 68000 registers. These changes and
the Z80's upstream Verilog representation still need game-level regression.
The game-logic probe deliberately excludes the generated SDRAM wrapper; its
external work RAM, memory arbiter, HDMI, menu and board IO are not counted.

Previous Mac synthesis measurements, before that workspace disconnected:

| Profile | LUT cells | ALU cells | Flip-flops | Block-RAM primitives |
| --- | ---: | ---: | ---: | ---: |
| General S16B, direct MCU ROM mapping | 15,065 | 2,157 | 8,224 | 108 |
| General S16B, MCU ROM mapped into logic | 15,526 | 2,153 | 8,267 | 22 |
| Golden Axe World set 3 | 11,227 | 1,485 | 7,264 | 18 |

These are pre-placement counts from the prior Mac run, not new cloud synthesis
results or proof that a complete core fits. The Nano target has 20,736 LUT4 sites,
15,552 flip-flop sites and 46 BSRAM sites. LUT/ALU placement constraints and the
remaining platform logic must be measured with the complete board design.

## Platform components validated here

- `rtl/s16_word_arbiter.sv`: four synchronous 16-bit request-toggle clients,
  packed onto an aligned 32-bit physical channel; active-high byte masks and
  round-robin selection. This is not yet the JTFRAME bank/burst handshake.
- `rtl/s16_sdram32.sv`: aligned native x32 controller for the integrated 8 MiB
  SDRAM. Supports 27–66.7 MHz with conservative BL1/CL2 timings and prioritized
  refresh. It currently has no video burst engine or throughput guarantee for
  the running arcade core. A phase-shifted SDRAM clock remains a board concern.
- `rtl/s16_frame_swap.sv`: two-buffer ownership handshake between asynchronous
  game/display clocks. Publication occurs only after the writer reports DMA
  completion. Display swaps occur at vblank; whole input frames are dropped
  during contention. Both domains must be reset together.

```sh
python3 cores/system16-experimental/test_components.py
```

The memory simulation uses an independent command-level SDRAM model, including
geometry, masked writes, CL2 reads, precharge, refresh timing and bus drive.
It covers 674 serial requests, 64 simultaneous requests, 53 refreshes, all byte
mask combinations, bank/row boundaries, arbitration and reset in flight.
The frame simulation covers 240 frame starts with asynchronous clocks: 144
complete frames displayed and 96 whole frames dropped, without buffer overlap.
These counts describe simulation stress scenarios, not expected game drop rates.

## Remaining integration

1. JTFRAME bank/cache/burst protocol and ROM-download adapter, including address
   remapping for the Nano's smaller row/column geometry and memory allocation.
2. Burst-capable framebuffer capture/scanout and arbitration with game traffic;
   byte-order and worst-case bandwidth tests.
3. Board PLLs, reset/CDC constraints, pixel timing, HDMI audio/video and pads.
4. BL616 loader/menu integration and core-bank packaging/version compatibility.
5. Complete synthesis, placement/routing, timing and physical console tests.
6. Game-level validation with a matching Golden Axe ROM set. No commercial game
   ROMs, keys, device backups or save data are included in this checkpoint.

GPL-3.0-or-later applies to these additions; upstream per-file notices remain.

## Checkpoint 2 update

The upstream-cache bridge now supplies the two consecutive words required by
JTFRAME's default 32-bit read bursts. It also maps active-low 16-bit write masks
onto the correct x32 half and faults before issuing aliased or unaligned reads.
Tests use the pinned upstream caches, including simultaneous bank requests.
The programming port, wider burst modes and framebuffer arbitration remain open.

`rtl/jtframe_fir_gowin.v` splits FIR coefficient/left/right storage into separate
banks and prefetches samples during the existing coefficient phase. It preserves
MAC/output timing and matches upstream outputs over 29,886 simulated cycles,
128 stereo samples, interrupted calculations and reset. FIR hex initialization
is split into three views by the preparation script, preserving the input data.

The Linux build has now synthesized the **Golden Axe World set 3 game plus the
JTFRAME work-RAM/cache/audio wrapper**, using these flags:

```sh
python3 cores/system16-experimental/prepare_probe.py \
  --upstream /absolute/path/jtcores --jtframe /absolute/path/jtframe \
  --out /absolute/path/probe --goldenaxe --with-memory-wrapper --gowin-fir
```

The wrapper relocates XRAM's VRAM_OFFSET from word 0x100000 to word 0x40000;
this still needs integration with the ROM loader and physical bank bridge.
Build/source paths currently must contain no whitespace, quotes or semicolons.
The earlier quoted-path emission in checkpoint 1 did not work with read_slang;
the generated build scripts have been corrected and actually exercised here.

| Wrapped Golden Axe probe | LUT cells | ALU cells | Flip-flops | Block RAM |
| --- | ---: | ---: | ---: | ---: |
| Upstream FIR storage | 16,282 | 1,946 | 12,599 | 27 |
| Split FIR storage | 15,148 | 1,946 | 11,440 | 28 |

Tool: Yosys 0.70+290, OSS CAD Suite Linux 2026-11-02. These figures still omit
physical SDRAM control, framebuffer DMA, HDMI, UART/menu and board IO. They do
not establish final fit or timing. **No routed bitstream or flashable core has
been produced.** A board top, clock/reset constraints and ROM-loader integration
are still necessary; Golden Axe has not been booted in simulation or hardware.

Run all component checks, including upstream cache and FIR comparisons, with:

```sh
python3 cores/system16-experimental/test_components.py \
  --upstream /absolute/path/jtcores \
  --fir-coeff /absolute/path/probe/fir_192k_4k.hex
```
