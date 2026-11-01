# Horizon console menu — development preview

Branch: `codex/horizon-console-menu`. This is the v0.4.0-rc.2 prerelease, following v0.3.1. No console was written or physically tested for this redesign.

The console uses the setup utility's supplied Horizon artwork and navy/blue/red palette. The home menu has spaced Play Games, Choose Core and Settings rows, with Resume Game when appropriate. Cores, Settings, Clock, Advanced and USB transfer share a blue title bar and red selection row, with SNES-style A Select and B Back helpers beneath the menu panel (hidden in USB transfer). Game Library shows its console/folder path, eight filenames per page and a page counter. Long display names are abbreviated; actual file paths and ZIP handling are unchanged. Directories keep a visible `>` marker even when abbreviated.

## Desktop review

Run `python3 tools/console-menu/serve.py`, then open http://127.0.0.1:1421/. It builds the real C++ Menu and FileChooser against simulated directory and platform services. Arrows navigate, Enter selects, Escape goes back, T sends Select + L, R resets the preview; M opens the menu. There is no board, SD-card, USB, flash or ROM-data access. Game launch is a labelled placeholder, not an emulator.

The preview uses the actual 32 × 28 text frames, the FPGA's 8 × 8 font and the compiled 1280 × 720 indexed artwork. It is a layout/interaction preview, not a cycle-accurate HDMI simulation. OLED and failed-artwork behavior retain the hardware panel/selection fallback.

## Build

`tools/console-menu/build_artwork.py` converts the existing supplied PNG into the indexed NBBG0001 payload and its existing NBLZ0001 compression. It requires Pillow (tested with 12.3.0 under the bundled Python runtime). Nearest-neighbour conversion preserves the pixel-art edges. The image itself is unchanged in `src/assets/nanoblast-horizon.png`.

The artwork uses palette entries 0–223; entries 224–234 identify text rows 15–25. The MCU recolours only the changed selected rows using the already supported palette command. The border and shadow use additional reserved entries. Entries 240–246 colour the SNES-style button tiles. Small acknowledged pixel uploads draw these beneath the menu or restore the exact original artwork when hidden. Tile visibility is cached, so moving the selection does not re-upload them. Failed transfers retry on the next redraw. OLED and missing-artwork fallbacks use plain A/B labels. This avoids FPGA changes and repeated artwork uploads on navigation. Palette state is invalidated after artwork/core changes. If artwork is unavailable or OLED mode is enabled, ordinary renderer panels and selection remain active.

The compiled artwork is 183,869 bytes. The BL616 menu stays within its protected secondary-image slot and uses less flash than v0.3.1. The four FPGA core assets are unchanged. Existing core switching, clock/saves, ZIP loading, loading-screen opacity and Select + L SD ownership checks remain in place.

## Verification

- `python3 scripts/test_menu_runtime.py`: eleven groups pass, including the production palette protocol, row-cache invalidation, OLED/missing-artwork fallback, menu geometry, shortcut guards, browser paging, game loading and loader regressions.
- `python3 firmware/tests/run_background_tests.py artifacts/horizon-menu/horizon.nbbg artifacts/horizon-menu/horizon.nblz`: raw upload and streaming decompression pass.
- `python3 tools/console-menu/test_preview.py`: actual home/core/settings/clock/advanced navigation, clock editing, OLED, library paging, launch/transfer guard and transfer screen pass; all frames stay within 32 × 28 cells.
- Native BL616 build passes. The local firmware/core ZIP passes setup-app selection and offline migration planning against the verified v0.3.0 readback; protected regions and unchanged core bank are checked.
- Browser review checks home, core chooser, library paging and USB transfer. Hardware palette timing, display appearance and controller behavior still need checking on the console.

Download `NANOBLAST-v0.4.0-rc.2-firmware.zip` from the prerelease, then select it through Choose release in the utility. Software checks pass; console review is pending. Retain the backup and wait for verification, then unplug all power/USB cables for five seconds before restarting.

The panel now starts one text row (24 output pixels) lower, leaving a clear gap below the artwork tagline. The preview contains only the console image; its heading, buttons and helper labels are removed. Idle core-status hints are removed. The area beneath the panel now shows a red A button for Select and a yellow B button for Back. Folder/page information and actionable errors remain.

The main menu choices are vertically centred in the panel body. The panel and selection band are centred on the 1280-pixel image, and menu text uses the full 32-column centring calculation.

Labels retain single spaces between words and use the full 32-column centre. Odd single words use the existing half-cell renderer offset. The preview models the same offset.

The panel ends at text row 25; helpers use row 27 beneath it and the library page counter remains in row 25. The original artwork reaches every display edge: no full-width footer rectangle is generated. Artwork generation checks that every pixel outside the panel remains unchanged.

SDK build compatibility: with current CMake/Ninja, remove the literal `\r\n` from the two `COMMENT "Generate ${BIN_FILE}\r\n"` strings in the private SDK’s `cmake/extension.cmake`. This changes build messages only.
