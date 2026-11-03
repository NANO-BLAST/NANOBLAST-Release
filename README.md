# NANOBLAST

A shared BL616 menu and FPGA console cores for the **Sipeed Tang Nano 20K**.

## Latest stable release

[v0.4.1](https://github.com/NANO-BLAST/NANOBLAST-Release/releases/tag/v0.4.1) promotes the working CRT r12 build with identical firmware and core binaries. It includes the NES loader/reset/SDRAM handoff, CRT presets, SNES-style helpers, Select + Start menu access, centred loading text without a separate black box, and immediate startup after artwork loading.

The maintainer reports r12 working on hardware. Full AccuracyCoin validation remains manual; no 147/147 result is claimed for v0.4.1. SNES and System 16 remain experimental. See [release notes](docs/releases/v0.4.1.md) for the precise validation scope and activation steps.

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

When upgrading, retain the Flasher backup and select SMS/Game Gear, then NES/Famicom to load the new NES bank image. Firmware updates preserve the saved FPGA power-on image; saving a new startup core is an explicit action after testing. If r12 is already active, v0.4.1 requires no reflash because the payloads are unchanged.

## Credits and licence

Derived from NESTang/NANOBLAST, SMSTang, SNESTang, GBTang and MiSTer Gameboy. Game Boy replacement boot code derives from SameBoy/MiSTer and retains its MIT notice. Firmware uses Bouffalo SDK and credited libraries. GPL-3.0 and applicable per-file licences apply; see [LICENSE](LICENSE) and source notices.

No commercial games, saves, credentials, device backups or toolchains are included.
