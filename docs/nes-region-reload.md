# NES menu-paused reload / region switching (CRT r10)

The active region remains latched at ROM-load start. Settings updates bit 2 of
`core_config`, preserving CRT bits 5:4. `nanoblast_iosys` captures bit 2 only on
the rising edge of `rom_loading`. `nestang_top` asserts `reset_nes` for the ROM
transfer and releases it at load completion. A region setting alone does not
change the running game's region; the menu already says “Applies to next game
load”. A PAL/NTSC ROM mismatch does not explain a failed return to NTSC.

## Confirmed RTL defect

The menu freezes the NES while the artwork renderer uses shared SDRAM. Before
r10, the divider process ran during reset even when paused, but `cpu_ce` and
`ppu_ce` were still blocked by menu pause. Counters incremented without their
CE-driven wrap. Meanwhile PPU control/mask registers and rendering/read pipelines
have CE-qualified reset branches, so a paused ROM reload did not reset them.
Changing region only reset some divider state; same-region loads could inherit
PAL extra-tick, PPU subcycle and de-jitter state as well.

The before-fix production-CPU/PPU/shared-SDRAM regression boots the existing
AccuracyCoin ROM until it renders, opens the simulated menu pause, streams its
PRG/CHR through the real controller's loader port, and changes to PAL at reset
entry. It fails with `enabled=1 reset_ce=0 CPUdiv=0 PPUdiv=0`: stale enabled PPU
state and no reset clocks. This is a simulation reproduction of the defect;
the physical report's exact grey-screen waveform has not been captured.

## Correction

CPU/PPU enables now run during reset even when the menu is paused. On reset entry
(or system-type change), all divider/subcycle/PAL/de-jitter state realigns once;
then the divider runs for the rest of the load so CE-qualified resets complete.
The existing pause gates on CPU/PPU memory requests remain in force. The loader
continues to own SDRAM port B; background scanout retains its existing scheduler
and drain/phase handshake. The production reference clock/load-release process,
region latch, PPU implementation and firmware ROM loader are unchanged.

The core stays paused after reset until the menu releases it at its saved memory
reference phase. Reset duration is the complete ROM transfer, not a one-clock
region pulse. The real UART regression verifies pending configuration changes
before/during loads and four NTSC/PAL load boundaries with the overlay open.
The separate memory-phase regression includes background traffic and odd/even
reload lengths. No shared-memory timing constraints were relaxed.

## Reproduce

Use the existing 147-test AccuracyCoin ROM (not included), SHA256
`86ec57789bd7421108cd76d22290d8a24e91b49f8b8b3ddcf09df7847357c6d8`:

```
python3 cores/nes/tests/accuracycoin/run_board.py /path/AccuracyCoin.nes \
  --out /tmp/nes-switch --region-reloads --verilator /path/to/verilator
```

This runs two complete NTSC → PAL → NTSC cycles. Each game renders before the
next reload; PPU reset state/enables, bounded dividers and fresh SDRAM rendering
are checked. The final NTSC game then runs all 147 tests. The normal full ROM
regression remains available without `--region-reloads`. `--render-only` now
allows 90 frames (410 with reloads), since this ROM initializes for more than
30 frames before displaying its menu. PAL stages check restart/rendering; the
NTSC-specific AccuracyCoin accuracy tally is checked after returning to NTSC.

Physical console validation remains required. No board was flashed during this
work. Existing CRT presets, SNES-style helpers, Select + Start access, 500 ms
startup artwork delay and r9 audio mute are retained. System 16 experimental
source/work remains in the checkout; this NES fix does not supply a System 16
FPGA image.
