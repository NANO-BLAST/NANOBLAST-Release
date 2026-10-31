# Console menu preview tools

These tools render the actual firmware menu and game browser with simulated services; they never access hardware or ROM files.

1. Compile the artwork if necessary: `python3 tools/console-menu/build_artwork.py` (Pillow required).
2. Run `python3 tools/console-menu/serve.py` and open http://127.0.0.1:1421/.
3. Use arrow keys / Enter / Escape. T is Select + L; M opens the menu; R resets the simulated console. The console shows A Select / B Back hints; the browser preview has no extra on-screen controls.

`preview.cpp` links the production Menu and FileChooser. The canvas uses the compiled indexed image and original FPGA font (`font.vh`, copied from NanoBlast's GPL source). Image palette changes mirror the MCU row-selection commands. Simulated names are for navigation only; no ROMs are present. Keyboard/game/USB services are simulated, and video timing is not emulated.

`test_preview.py` exercises production navigation and bounds. Full design and verification notes are in `docs/horizon-console-menu.md`.
