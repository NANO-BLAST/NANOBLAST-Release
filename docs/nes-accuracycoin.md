# NES AccuracyCoin validation — r3

R3 passes **147/147** in the unmodified AccuracyCoin ROM through the production
shared SDRAM controller. All 147 CPU-written slots and the ROM's final tally
pass. The original release reproduced **137/147**. Physical console validation
of r3 is still pending.

ROM SHA256: `86ec57789bd7421108cd76d22290d8a24e91b49f8b8b3ddcf09df7847357c6d8`.
Source hashes, result slots and evidence are in
[`validation/nes-accuracycoin.json`](validation/nes-accuracycoin.json).

## Correction and failed candidates

The original accuracy changes (`41ae2f0`) correct sprite counters, partial
fetches, OAM evaluation/wrap/corruption, pre-render sprite fetches, background
serial inputs and PPUADDR/PPUDATA transfer timing. CPU/APU/DMA engines, mappers
and clock generators retain their existing behavior.

R1 (`3fe47a86…`) passed the independent-memory fixture but corrupted rendering
on the console. SDRAM fetches started at the late mapper /RD phase. The shared
controller reproduced 65,580 stale bytes in 364,392 initial-menu samples. R2
(`aa3e844`) separated early SDRAM prefetch from logical mapper /RD and restored
rendering.

R2 (`5e2bcdce…`) then stalled on hardware at test 109, DMA Landing on Write. A
complete shared-controller run reproduced this; the test/page alone did not.
A blanking PPUDATA read requested SDRAM on the same PPU phase that captured the
buffer. CPU memory contention left a stale $02 instead of $A5. The test executes
open-bus instructions through $3FFF; this wrong byte executed KIL and stopped
at $4000.

R3 starts the blanking SDRAM request at read-pipeline phase 3 and retains its
captured address through phases 3 and 4. Buffer completion, mapper /RD, scroll
increment and rendering bus-conflict timing remain at phase 4. R3 production
RTL changes are confined to `cores/nes/src/ppu.v`.

The menu also recognizes the exact rc.2 NES, r1 and r2 boot-image fingerprints
when explicitly saving a replacement with Core boot flash. Its read-before-
erase guard algorithm is unchanged. Updating BL616 does not automatically save
a new FPGA startup core.

## Required release checks

`cores/nes/tests/accuracycoin/run_board.py` now runs the entire ROM by default.
The run starts from reset, uses ordinary controller input, never patches the
ROM and never forces hardware state. It uses the production CPU, PPU, APU and
`sdram_nes.v`, an NROM fixture, ideal CL2/BL1 chip pins, the production 3:1 clock
ratio and forwarded 10/16 phase. OAM uses its existing behavioral synchronous
RAM; focused OAM tests separately use Gowin's DPB model. Ideal chip pins check
digital scheduling, not analog or routed I/O behavior.

- Full shared-controller run: **147/147**, ROM tally **147/147**, stop at frame
  4,293. Test 109 result $0496 = $05 (pass).
- Initial rendering: **zero stale bytes in 2,834,160 samples** through frame 99.
- Original 64-byte CIRAM read-buffer program: **64/64** correct on r3 versus
  **0/64** on r2, with CPU fetch contention through the actual controller.
  `test_read_buffer.py` generates it without needing AccuracyCoin.
- Independent-memory full run: **147/147** on prototype PPU source differing
  from r3 only in comments/whitespace. Its actual source hashes are retained;
  the shared run and FPGA build use exact production RTL.
- All **20** focused RTL cases pass: CPU, DMA, APU, IRQ, open bus, mapper
  controls, vendor-DPB OAM, sprites, scroll, palette, TMDS and raster.
- Region control, NTSC/PAL ratios, 262/312-line frames and menu freeze pass.
- Memory-phase regression passes with 2,231 requests, 1,111 returns and 164
  background words.

The absent legacy HDMI-reset trial is skipped; release TMDS/raster tests pass.
Existing OAM tests sample before the address-advance edge, as the PPU does;
expected bytes are retained. The Loopy check drives completed reads and drains
the transfer pipeline before its arithmetic checks.

From the repository root, with Verilator and the ROM supplied locally:

```sh
python3 cores/nes/tests/accuracycoin/run_board.py /path/AccuracyCoin.nes --out /tmp/nes-shared
python3 cores/nes/tests/accuracycoin/test_read_buffer.py --out /tmp/nes-buffer
python3 scripts/verify_nes_accuracy_release.py --simulation /tmp/nes-shared/results.json --fpga-manifest /path/fpga/manifest.json --rom /path/AccuracyCoin.nes
```

`--render-only` is a short diagnostic and cannot satisfy the release gate.
The gate requires a full shared-controller 147/147 run with RTL hashes matching
current source and the FPGA build, valid rendering, the three original clock
targets and 61 checked storage pins.

## Routed image

Baseline and r3 synthesize, pack and route for GW2AR-LV18QN88C8/I7. R3 uses 79%
of LUT slots, 46% of flip-flops and 80% of BSRAM.

| Packed resource | Baseline | R3 | Change |
|---|---:|---:|---:|
| LUT slots, including arithmetic | 16,060 | 16,366 | +306 |
| Flip-flops | 7,037 | 7,091 | +54 |
| BSRAM blocks | 37 | 37 | 0 |

Original clock targets pass without relaxed periods or new timing exceptions:

| Clock | Required MHz | Routed maximum MHz |
|---|---:|---:|
| NES | 21.60 | 69.03 |
| SDRAM | 64.80 | 194.14 |
| HDMI pixel | 74.25 | 113.83 |

The build reuses 5,845 unchanged non-PPU register locations from the release to
avoid a dense-design placer failure; changed logic remains free to route.
Placement provenance is under `cores/nes/constraints/`. All 61 SDRAM/flash pins
match the routed release. The packer checks eight HDMI PPLVDS pads, the fixed
907,418-byte image size and configuration footer.

Raw SHA256: `9f2ee6bd0b989baed39a87cd1a7e832ebb0a44cc48124f507e8aa5d0c3113fdf`.

`scripts/build_nes_accuracy.py` records live inputs and stops on failed route
or timing. The Setup package binds its rebuilt menu to the compressed directory.
The other three core images remain byte-identical to rc.2. Host verification
decodes all four using the actual firmware decoder under ASan/UBSan and checks
package selection/update planning with the native Setup helper.

## Console validation

Install the r3 ZIP with Setup Utility. Select Master System / Game Gear, then
NES / Famicom to explicitly load the new bank image: the saved startup NES can
remain active after a BL616 update. Run AccuracyCoin, representative games and
audio, region switching and menu return. Only after successful physical testing
should Settings > Core boot flash save the new startup core. Do not promote r1
or r2. The archived release remains the rollback baseline; no console was
flashed automatically by this work.
