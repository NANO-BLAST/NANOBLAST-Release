# NES AccuracyCoin validation

The updated NES PPU passes **147/147** tests in the unmodified 147-test
AccuracyCoin ROM in full-core simulation. The original release source reproduced
**137/147** with the same ten failures as the supplied hardware screenshot.

Both complete runs of the final PPU passed: one-master-clock and
three-master-clock synchronous external-memory response latency. The fixture
reads the CPU-written result slots and requires the ROM's own finished table to
show 147/147. It never patches the ROM or forces hardware state.

ROM SHA256:
`86ec57789bd7421108cd76d22290d8a24e91b49f8b8b3ddcf09df7847357c6d8`.
Source hashes and machine-readable evidence are in
[`validation/nes-accuracycoin.json`](validation/nes-accuracycoin.json).
The implementation commit is `41ae2f0` on `codex/nes-accuracycoin-147`.

## What changed

The production change is in `cores/nes/src/ppu.v`: sprite X-counter clocks are
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
| LUT slots, including arithmetic implementation | 16,060 | 16,284 | +224 |
| Flip-flops | 7,037 | 7,090 | +53 |
| BSRAM blocks | 37 | 37 | 0 |

Yosys reports 12,576 versus 12,774 LUT1–LUT4 cells before architecture packing;
that +198 cell count is a different measure from packed LUT-slot use.

## Routed image

The final route passes the actual clock targets, without relaxed periods or
new timing exceptions:

| Clock | Required MHz | Routed maximum MHz |
|---|---:|---:|
| NES | 21.60 | 65.33 |
| SDRAM | 64.80 | 136.30 |
| HDMI pixel | 74.25 | 122.35 |

The build retains 5,881 unchanged non-PPU register locations from the routed
release to avoid a dense-design placer failure. Combinational logic and the
updated PPU remain free to place and route. The compact placement reference and
its provenance hash are under `cores/nes/constraints/`; the build script applies
it explicitly and restores the release's actual clock constraints.

All 61 SDRAM/flash pins match the prior routed design. The packer verifies all
eight HDMI PPLVDS pads against the vendor fuse reference. The fixed device image
size and configuration footer pass validation. Raw image SHA256:
`3fe47a8668655d21ed162c837659223d033aa937a65656f9342044275798640d`.

## Hardware status

No physical board pass is claimed and no board or installed core bank has been
programmed. A simulation pass cannot establish routed timing, SDRAM electrical
behavior, HDMI stability or gameplay on every mapper. Physical validation needs
a temporary SRAM image, the same ROM, representative mapper games/audio, region
switching and menu return before promoting a release.

The live-source build script is `scripts/build_nes_accuracy.py`. It records
inputs and stops before packing if route/timing checks fail. The original
archived build inputs and the installed release remain the rollback baseline.
