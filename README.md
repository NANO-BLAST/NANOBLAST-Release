# NANOBLAST

A shared BL616 menu and FPGA console cores for the **Sipeed Tang Nano 20K**.

## Current release

[NANOBLAST v0.4.0](https://github.com/NANO-BLAST/NANOBLAST-Release/releases/tag/v0.4.0) includes the corrected NES147 r3 core, the full-screen Horizon menu and NANOBLAST Flasher v0.2.0 for Apple Silicon Macs. The NES core passes all 147 AccuracyCoin tests in shared-SDRAM simulation and on the physical console as confirmed by the user. The other three core payloads are unchanged from rc.2; SNES remains experimental.

After flashing, switch to SMS/Game Gear and back to NES to load the updated bank image. Saved startup cores are not replaced automatically. The Flasher is a compact firmware-only updater with no ROM-upload tools or confirmation checkbox. Its Mac installer is ad-hoc signed and not Apple-notarized.

## Downloads

[Latest public release](https://github.com/NANO-BLAST/NANOBLAST-Release/releases/latest) · [All releases](https://github.com/NANO-BLAST/NANOBLAST-Release/releases)

Firmware downloads and checksums live on Releases. The repository contains browsable source rather than binary ZIP archives.

| Core | Status |
|---|---|
| NES / Famicom | Working |
| Master System / Game Gear | Working |
| Game Boy / Game Boy Colour | Working; battery saves and saved-clock resume |
| SNES | Experimental; hidden by default, with known graphical and compatibility faults |

Shared menus, artwork, core switching, explicit Core boot flash, manual clock settings and OLED Mode (Beta). NFC is not included. The clock resumes its saved value after power-off; it cannot measure elapsed time while unplugged.

## Source

- [`firmware/`](firmware): BL616 menu, loaders, storage and controller handling.
- [`cores/`](cores): NES, SMS/Game Gear, GB/Colour and experimental SNES source.
- [`tools/`](tools): source utilities and checks.
- [`licenses/`](licenses): additional third-party notices; upstream notices remain in source files.
- [`SOURCE_MAP.json`](SOURCE_MAP.json): source provenance and snapshot details.

Version v0.3.1 adds **Select + L** (left shoulder) to enter USB ROM transfer from any console menu page, without navigating Settings. Use both buttons on the same controller. If a game has run, restart first; the existing save/clock checks and SD ownership guard still apply. Power-cycle to leave transfer mode. Settings → Advanced → USB ROM transfer remains available.

This also includes the v0.3.0 USB ROM browsing/uploads, single-game ZIP streaming, Game Boy library fixes, and solid black loading panel in all four cores. The four FPGA images are unchanged from v0.3.0. SNES remains experimental.

The new shortcut passes host tests and the BL616 build, but has not yet been checked on a physical controller. The v0.3.0 firmware/core bundle passed full board readback. See [BUILDING.md](BUILDING.md) for source layout and build requirements.

## Credits and licence

Derived from NESTang/NANOBLAST, SMSTang, SNESTang, GBTang and MiSTer Gameboy. Game Boy replacement boot code derives from SameBoy/MiSTer and retains its MIT notice. Firmware uses Bouffalo SDK and credited libraries. GPL-3.0 and applicable per-file licences apply; see [LICENSE](LICENSE) and source notices.

No commercial games, saves, credentials, device backups or toolchains are included.
