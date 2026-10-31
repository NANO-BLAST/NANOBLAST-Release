# Horizon console menu — development preview

Branch: `codex/horizon-console-menu`. This is the v0.4.0-rc.1 prerelease, following v0.3.1. No console was written or physically tested for this redesign.

The console uses the setup utility's supplied Horizon artwork and navy/blue/red palette. The home menu has spaced Play Games, Choose Core and Settings rows, with Resume Game when appropriate. Cores, Settings, Clock, Advanced and USB transfer share a blue title bar and red selection row, with SNES-style A Select and B Back helpers on row 26, one row above the bottom (hidden in USB transfer). Game Library shows its console/folder path, eight filenames per page and a page counter. Long display names are abbreviated; actual file paths and ZIP handling are unchanged. Directories keep a visible `>` marker even when abbreviated.

## Desktop review

Run `python3 tools/console-menu/serve.py`, then open http://127.0.0.1:1421/. It builds the real C++ Menu and FileChooser against simulated directory and platform services. Arrows navigate, Enter selects, Escape goes back, T sends Select + L, R resets the preview; M opens the menu. There is no board, SD-card, USB, flash or ROM-data access. Game launch is a labelled placeholder, not an emulator.

The preview uses the actual 32 × 28 text frames, the FPGA's 8 × 8 font and the compiled 1280 × 720 indexed artwork. It is a layout/interaction preview, not a cycle-accurate HDMI simulation. OLED and failed-artwork behavior retain the hardware panel/selection fallback.

## Build

`tools/console-menu/build_artwork.py` converts the existing supplied PNG into the indexed NBBG0001 payload and its existing NBLZ0001 compression. It requires Pillow (tested with 12.3.0 under the bundled Python runtime). Nearest-neighbour conversion preserves the pixel-art edges. The image itself is unchanged in `src/assets/nanoblast-horizon.png`.

The artwork uses palette entries 0–223; entries 224–235 identify text rows 15–26. The MCU recolours only the changed selected rows using the already supported palette command. The border and shadow use additional reserved entries. Entries 240–246 draw the SNES-style button icons and are recoloured to footer navy when the helpers are hidden; OLED and missing-artwork fallbacks use plain A/B labels. This avoids FPGA changes and repeated artwork uploads on navigation. Palette state is invalidated after artwork/core changes. If artwork is unavailable or OLED mode is enabled, ordinary renderer panels and selection remain active.

The compiled artwork is 173,294 bytes. The BL616 menu stays within its protected secondary-image slot and uses less flash than v0.3.1. The four FPGA core assets are unchanged. Existing core switching, clock/saves, ZIP loading, loading-screen opacity and Select + L SD ownership checks remain in place.

## Verification

- `python3 scripts/test_menu_runtime.py`: ten groups pass, including the production palette protocol, row-cache invalidation, OLED/missing-artwork fallback, menu geometry, shortcut guards, browser paging, game loading and loader regressions.
- `python3 firmware/tests/run_background_tests.py artifacts/horizon-menu/horizon.nbbg artifacts/horizon-menu/horizon.nblz`: raw upload and streaming decompression pass.
- `python3 tools/console-menu/test_preview.py`: actual home/core/settings/clock/advanced navigation, clock editing, OLED, library paging, launch/transfer guard and transfer screen pass; all frames stay within 32 × 28 cells.
- Native BL616 build passes. The local firmware/core ZIP passes setup-app selection and offline migration planning against the verified v0.3.0 readback; protected regions and unchanged core bank are checked.
- Browser review checks home, core chooser, library paging and USB transfer. Hardware palette timing, display appearance and controller behavior still need checking on the console.

Download `NANOBLAST-v0.4.0-rc.1-firmware.zip` from the GitHub prerelease and select it through Choose release in the setup utility. It is software-tested and awaits physical console review. Retain the utility backup, allow verification to finish, then disconnect all console power/USB cables for five seconds before reconnecting normally.

The panel now starts one text row (24 output pixels) lower, leaving a clear gap below the artwork tagline. The preview contains only the console image; its heading, buttons and helper labels are removed. Idle core-status hints are removed. Row 26 now shows a red A button for Select and a yellow B button for Back. Folder/page information and actionable errors remain.

The main menu choices are vertically centred in the panel body. The panel and selection band are centred on the 1280-pixel image, and menu text uses the full 32-column centring calculation.

Labels retain single spaces between words and use the full 32-column centre. Odd single words use the existing half-cell renderer offset. The preview models the same offset.

The A Select / B Back helpers sit one row above the bottom; the library page counter uses row 25 to keep them separate.
