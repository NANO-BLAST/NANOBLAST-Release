# NANOBLAST

A shared BL616 menu and FPGA console cores for the **Sipeed Tang Nano 20K**.

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
- [`SOURCE_MAP.json`](SOURCE_MAP.json): paths from the original source snapshot.

Version v0.2.0 uses one contiguous compressed asset per core and a shared checked loader. Core storage falls from 3,100,672 to 1,462,272 bytes. The firmware was built natively on macOS; the complete board flash readback passed, and the user confirmed core switching, game launching, GB saves and clock resume work. FPGA bitstreams are unchanged. SNES remains experimental with the existing gameplay limitations.

## Credits and licence

Derived from NESTang/NANOBLAST, SMSTang, SNESTang, GBTang and MiSTer Gameboy. Game Boy replacement boot code derives from SameBoy/MiSTer and retains its MIT notice. Firmware uses Bouffalo SDK and credited libraries. GPL-3.0 and applicable per-file licences apply; see [LICENSE](LICENSE) and source notices.

No commercial games, saves, credentials, device backups or toolchains are included.
