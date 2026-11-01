# Source and build notes

`firmware/` is the current BL616 menu, including the Horizon menu and Select + L. The FPGA cores are the v0.3.0 opaque-panel images. `build-inputs/` preserves their exact NES/SMS/SNES synthesis inputs; `cores/gb-colour/` contains the self-contained GB/Colour build. Upstream and per-file notices are retained.

## Host tests

Run `python3 scripts/test_menu_runtime.py` with a C++17 compiler and AddressSanitizer/UndefinedBehaviorSanitizer. It builds and runs the actual menu shortcut, overlay, loading, GB library, browser and ROM-loader code without writing hardware.

## BL616 menu

Install CMake, Ninja, Bouffalo SDK commit `7f44f9ea6b4ccf96db8c5236c8024b68e2a76df7`, and the BL616 GCC toolchain. Set `BL_SDK_BASE` and `CROSS_COMPILE` to those external installations.

```
cmake -S firmware -B firmware/build -G Ninja -DCHIP=bl616 -DBOARD=bl616dk -DTANG_BOARD=nano20k -DCROSS_COMPILE="$CROSS_COMPILE"
cmake --build firmware/build --parallel 3
```

The raw SDK binary must be finalized before flashing. Download the matching firmware release ZIP and copy its four `cores/*.core` files to a flat `artifacts/core-bank/` folder. Put `release-core-layout.json` in that folder as `core-manifest.json`, then install `scripts/requirements-bl616.txt` and run:

```
python3 scripts/package_usb_firmware.py firmware/build/build_out/tangcore_bl616.bin --core-manifest artifacts/core-bank/core-manifest.json --output artifacts/menu
```

This verifies the menu/core table binding, the four core hashes and the protected secondary-image size, and finalizes the BFNP header. Never flash the raw SDK image or write the secondary menu at address zero. Use a compatible NanoBlast setup utility and its verified firmware/core release package.

## FPGA source snapshots

Run `python3 relocate_build_inputs.py` to rebase the archived `.ys`, `.f` and `.tcl` recipes. NES/SMS use Yosys with slang, nextpnr-himbaechel and apycula for the GW2A-18C / GW2AR-LV18QN88C8/I7. The custom packer is preserved under `build-inputs/original-workspace/work/pack-nanoblast.py`. GB uses `cores/gb-colour/build_native.py --all` with native Gowin. SNES uses the archived `snes-pixel-pipeline2/build.tcl` and its selected pipelined renderer. SDK/toolchain binaries are not shipped. Tool versions and routing seeds can change rebuilt image hashes.

`SOURCE_SHA256.json` covers the release source snapshot (before build outputs or recipe relocation). No device captures, saves or commercial ROMs are included. The setup app is distributed separately.

## Horizon artwork and desktop preview

Install Pillow, then run `python3 tools/console-menu/build_artwork.py` to regenerate the embedded artwork. It uses the supplied `src/assets/nanoblast-horizon.png`, the preserved FPGA font and the existing palette/decompression protocol. Run `python3 tools/console-menu/serve.py` and open http://127.0.0.1:1421/ for the actual C++ menu/browser against simulated files. See `docs/horizon-console-menu.md`. The preview does not access hardware.

For current CMake/Ninja, remove the literal `\r\n` from the two `COMMENT "Generate ${BIN_FILE}\r\n"` strings in the private SDK’s `cmake/extension.cmake` before configuring. This affects build messages only.
