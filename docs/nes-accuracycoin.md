# NES AccuracyCoin validation

The updated NES PPU passes **147/147** tests in the unmodified 147-test
AccuracyCoin ROM in full-core simulation. The original release source reproduced
**137/147** with the same ten failures as the supplied hardware screenshot.

The corrected SDRAM-prefetch build passes the complete run at one-master-clock
synchronous external-memory response latency. The first candidate had also
passed at three clocks, but subsequently failed hardware rendering. The fixture
reads the CPU-written result slots and requires the ROM's own finished table to
show 147/147. It never patches the ROM or forces hardware state.

ROM SHA256:
`86ec57789bd7421108cd76d22290d8a24e91b49f8b8b3ddcf09df7847357c6d8`.
Source hashes and machine-readable evidence are in
[`validation/nes-accuracycoin.json`](validation/nes-accuracycoin.json).
The initial accuracy change is commit `41ae2f0` on `codex/nes-accuracycoin-147`;
the follow-up SDRAM-prefetch correction is recorded in the same branch.

## What changed

The production changes are in `cores/nes/src/ppu.v` and its SDRAM read-enable
connection in `cores/nes/src/nes.v`: sprite X-counter clocks are
separate from pixel-shifter clocks; partial fetches update individual slots;
secondary OAM keeps its address and overflow state; OAM evaluation continues
correctly after wrap and overflow hits; pre-render sprite fetches retain OAM;
background planes have their physical serial inputs; and PPUADDR/PPUDATA use
transfer timing and a persistent low-address latch. Dummy reads use nametable
addresses. The CPU/APU/DMA engines, mappers, menu, firmware and clock generators
are unchanged.

## Regression checks

- All 20 focused RTL cases pass, including CPU, DMA, APU, frame IRQ, open bus,
  mapper controls, OAM corruption, sprite counters, scroll arithmetic, palette
  gating, TMDS and video raster.
- Region control, NTSC/PAL clock ratios, 262/312-line frames and menu freeze pass.
- The memory-phase test passes with background traffic: 2,231 requests and 1,111
  returns, retaining the request/return spacing requirements.
- Pre-render sprite-range tests cover NTSC line 261 and PAL/Dendy line 311.
- The obsolete HDMI-reset *trial* is skipped because its module is absent from
  the release. The actual release's TMDS and raster tests pass.

Some older OAM checks observed the bus after the address-advance edge. They now
sample it before that edge, as the consuming PPU does; expected bytes are
retained. The Loopy arithmetic check drives completed-read events and drains the
address-transfer pipeline before its exhaustive arithmetic checks.

## FPGA resources

Both the baseline and candidate synthesize and complete architecture packing for GW2AR-LV18QN88C8/I7.
The packed candidate uses 78% of LUT slots, 45% of flip-flops and 80% of BSRAM.

| Packed resource | Baseline | Candidate | Change |
|---|---:|---:|---:|
| LUT slots, including arithmetic implementation | 16,060 | 16,223 | +163 |
| Flip-flops | 7,037 | 7,091 | +54 |
| BSRAM blocks | 37 | 37 | 0 |

Yosys reports 12,576 versus 12,723 LUT1–LUT4 cells before architecture packing;
that +147 cell count is a different measure from packed LUT-slot use.

## Routed image

The final route passes the actual clock targets, without relaxed periods or
new timing exceptions:

| Clock | Required MHz | Routed maximum MHz |
|---|---:|---:|
| NES | 21.60 | 61.05 |
| SDRAM | 64.80 | 204.79 |
| HDMI pixel | 74.25 | 122.61 |

The build retains 5,847 unchanged non-PPU register locations from the routed
release to avoid a dense-design placer failure. Combinational logic and the
updated PPU remain free to place and route. The compact placement reference and
its provenance hash are under `cores/nes/constraints/`; the build script applies
it explicitly and restores the release's actual clock constraints.

All 61 SDRAM/flash pins match the prior routed design. The packer verifies all
eight HDMI PPLVDS pads against the vendor fuse reference. The fixed device image
size and configuration footer pass validation. Raw image SHA256:
`5e2bcdcebacf4e6ea328bf6eb3a25dc6e44af3bc72ceb617a9599b8a7a6d0612`.

## Hardware status

The first image (`3fe47a86…`) failed physical testing: the NES game screen was
corrupted after loading it. Updating the BL616 bank alone had initially left the
older 137/147 NES core running from FPGA boot flash. Switching to another core
and back exposed the candidate's rendering regression. Do not promote that image.

The standalone ROM fixture had independent CPU/PPU memory access. With the real
shared SDRAM controller, starting the rendering request in the mapper /RD half
of the PPU fetch could return data after the renderer sampled it. An ideal CL2
SDRAM pin model reproduces 65,580 stale bytes among 364,392 initial-menu samples.
Separating SDRAM prefetch from mapper /RD restores the earlier request phase:
the same initial-menu scene has zero stale bytes and readable text. The CPU,
PPU, memory controller and cartridge ROM execute normally in this regression.
The chip pins and clocks are ideal; this is not analog timing signoff. OAM uses
its existing behavioral synchronous RAM implementation in this scheduling test.

`tests/accuracycoin/run_board.py --render-only` within `cores/nes` builds this
shared-controller regression. The original fixture remains the faster full-ROM
accuracy test. A physical pass of the corrected image is still required, along
with representative mapper games/audio, region switching and menu return.

The live-source build script is `scripts/build_nes_accuracy.py`. It records
inputs and stops before packing if route/timing checks fail. The original
archived build inputs and the installed release remain the rollback baseline.
