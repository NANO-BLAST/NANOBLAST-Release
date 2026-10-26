# Changelog

## v0.2.0 — 26 October 2026

- One contiguous compressed asset per core, using a shared checked XZ loader.
- Approximately 1.46 MB total core storage instead of 3.10 MB.
- Separate, protected SD-core staging space.
- No FPGA bitstream, gameplay, save-format or clock changes.
- Native build, decoder, programmer and persistence checks passed.
- Full board flash readback passed; core switching, game launching, GB saves and clock resume confirmed by the user.

## v0.1.0 — 26 October 2026

First public release of the shared BL616 menu with NES, Master System/Game Gear and Game Boy/Colour support. Includes GB battery saves, manual clock and saved-clock resume; streamlined Games paging, responsive highlight movement and larger artwork packets. SNES remains experimental. The public firmware excludes device-specific maintenance.
