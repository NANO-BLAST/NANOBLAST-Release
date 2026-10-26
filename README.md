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

This branch is the compressed-core candidate. All four assets use one contiguous NBCRXZ01 file each, with the same checked decoder. Bitstreams are unchanged; native decoder, full FPGA-stream and boot-flash persistence checks pass. Physical migration and core-switching checks are pending. The latest published release remains v0.1.0.

## Credits and licence

Derived from NESTang/NANOBLAST, SMSTang, SNESTang, GBTang and MiSTer Gameboy. Game Boy replacement boot code derives from SameBoy/MiSTer and retains its MIT notice. Firmware uses Bouffalo SDK and credited libraries. GPL-3.0 and applicable per-file licences apply; see [LICENSE](LICENSE) and source notices.

No commercial games, saves, credentials, device backups or toolchains are included.
