# CRT presets for NES and Master System

Open Settings and select the CRT row to cycle Off, Light Scanlines, Strong
Scanlines, and CRT. The control is available for NES and Master System/Game Gear.
The selection is kept during this menu session and reapplied when switching
cores. It is not saved to the SD card and defaults to Off after restarting.
Other cores display an unavailable label and cannot change the setting.

Light scanlines attenuate the bottom part of each source line by 25%; Strong
Scanlines attenuate it by 50%. CRT combines light scanlines with a repeating RGB
aperture mask, attenuating the two non-selected channels by approximately 12.5%.
There is no gamma boost in this first implementation. Black stays black, channel
arithmetic cannot overflow, and Off preserves the original RGB values exactly.

The NES effect follows its three-output-row scaling. SMS/Game Gear uses the
existing vertical scaler phase, so 192-, 224-, 240-, and 144-line sources track
their own source lines. The menu bypasses filtering and stays readable.

Configuration occupies core_config[5:4]. Each video path transfers the two-bit
word with the existing bundled-data mailbox and commits it at the start of an
output frame. The filter is in the existing RGB register's input logic, before
HDMI encoding. It adds no framebuffer or extra pipeline register and does not
change emulation clocks, HDMI timings, or refresh rate. Existing output remains
720p; this change does not implement PAL 50 Hz HDMI output.

Build both FPGA cores and the BL616 menu together. Installing the menu alone
cannot add these effects to old FPGA images. Use the established release packer
and checks before flashing; raw SDK output is not a flashable release package.
Hardware validation, including checking picture quality and running AccuracyCoin
on the rebuilt NES image, is required before marking a release hardware tested.

Verification:

```
python3 scripts/test_menu_runtime.py
python3 scripts/test_crt.py --iverilog /path/to/iverilog --vvp /path/to/vvp
```

The focused CRT bench checks all channel levels and presets against independent
integer arithmetic, cross-clock configuration delivery, frame-boundary switching,
menu bypass and reset. Existing SMS/GG video benches also check bypass scanout.
Both NES and SMS pass placement, routing and their existing clock targets.
NES requires four-input LUT mapping and fresh placement for this candidate:

```
python3 scripts/build_nes_accuracy.py --out /tmp/nes-crt \
  --max-lut 4 --no-reference-placement --placement-density 1 \
  --placement-timeout 100000 --yosys /path/to/yosys \
  --nextpnr /path/to/nextpnr-himbaechel --pack-python /path/to/python
```

The search option is a divisor: larger values cap individual searches sooner,
with a minimum of 10,000 attempts. The density target does not change physical
capacity, storage pins or required clocks. The NES build uses 16,863 / 20,736
LUT4 sites in the tool's utilization report, plus its separately reported ALUs.
All 61 storage pins and eight HDMI pad configurations are checked.

The existing production shared-SDRAM AccuracyCoin regression is reused only
after verifying the CPU/PPU/APU/memory and fixture hashes are identical. The CRT
output itself is independently simulated. Hardware validation of the new output
images is still required. The firmware also recognizes the exact pre-CRT r3 NES
and SMS boot images when the user explicitly chooses to save a new startup core.
