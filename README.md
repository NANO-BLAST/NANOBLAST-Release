# NANOBLAST

NANOBLAST for the **Sipeed Tang Nano 20K**, with a shared BL616 menu and onboard microSD games.

## v0.1.0

- Nintendo NES / Famicom.
- Sega Master System / Game Gear.
- Game Boy / Game Boy Colour, including battery saves and saved-clock persistence.
- Shared menu, artwork, core switching, explicit Core boot flash, and manual clock settings.
- Faster Games paging and highlight movement; larger acknowledged artwork transfers.
- OLED Mode **(Beta)**.

**SNES is experimental**, hidden by default, with known graphical corruption and game compatibility problems. NFC is not included. The clock resumes its saved value after power-off; it cannot measure elapsed time while unplugged.

## Downloads

- [Release v0.1.0](https://github.com/NANO-BLAST/NANOBLAST-Release/releases/tag/v0.1.0)
- [Source archive](NANOBLAST-v0.1.0-source.zip)
- [Firmware and core images](NANOBLAST-v0.1.0-images.zip)
- [Release manifest](RELEASE.json) and [SHA-256 checksums](SHA256SUMS)

The source archive is the corresponding source snapshot for these images. Release firmware omits the development board's one-time SD cleanup. Existing core images are unchanged; the maintenance-free firmware was compiled and checked natively on macOS, without another physical-board test of that exact firmware binary. Existing gameplay, Game Gear, GB/Colour saves and clock persistence were confirmed on hardware. Loading-time gains have not been measured end to end.

## Credits and licence

Derived from NESTang/NANOBLAST, SMSTang, SNESTang, GBTang and MiSTer Gameboy, with the contributors and upstream notices retained in the source. Game Boy replacement boot code derives from SameBoy/MiSTer and retains its MIT notice. Firmware uses Bouffalo SDK and credited third-party libraries. GPL-3.0 and the applicable per-file licences apply; see [LICENSE](LICENSE) and source notices.

Commercial game files, saves, device backups, credentials and toolchains are not included.
