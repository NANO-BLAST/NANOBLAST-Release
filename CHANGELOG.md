# Changelog

## v0.4.0-rc.2 — 1 November 2026

- Remove the full-width navy footer; keep original artwork at all four screen edges.
- Place SNES A Select / B Back helpers outside, beneath the menu panel.
- Restore the exact artwork beneath helper icons during USB transfer. Cache tile visibility to avoid re-uploading on navigation.
- Eleven runtime groups, raw/compressed artwork, host navigation and BL616 build pass; physical console review is pending.
- Four core images unchanged from v0.3.1.


## v0.4.0-rc.1 — Horizon menu candidate

- Blue-sky Horizon theme matching the setup utility, with centred menu choices and one space between words.
- SNES-style red A Select and yellow B Back helpers, one row above the bottom.
- Eight-row game browser; page count stays clear of the button helpers.
- Existing Select + L, USB ROM uploads, ZIP streaming and solid loading panel retained.
- Four core binaries unchanged from v0.3.1. Ten runtime groups, artwork upload/decompression tests, host navigation and BL616 build pass.
- Physical console review is pending; this is a prerelease.


## v0.3.1 — 31 October 2026

- Select + L enters USB ROM transfer from the console menus.
- Accept the chord on either wired input or USB gamepad, on one controller only; trigger once per press.
- Preserve the Advanced-menu action, save/clock checks and running-game SD ownership restriction.
- Display the shortcut beside USB ROM transfer in Advanced.
- All eight focused runtime test groups and the BL616 build pass. Physical shortcut testing is pending.
- Four core binaries are unchanged from v0.3.0.
- Matching firmware and core source snapshots are now in this repository as well as the release source ZIP.

## v0.3.0 — 30 October 2026

- USB SD-card ROM browsing and uploads, including filenames containing parentheses.
- Single-game ZIPs stream into the selected core without an extracted SD-card copy.
- Game Boy library fixes and centred solid black loading panels in all four cores.
- Full 4 MiB board readback passed; menu and loading panel confirmed by the user.
- SNES remains experimental.

## v0.2.0 — 26 October 2026

- One contiguous compressed asset per core, using a shared checked XZ loader.
- Approximately 1.46 MB total core storage instead of 3.10 MB.
- Separate, protected SD-core staging space.
- No FPGA bitstream, gameplay, save-format or clock changes.
- Native build, decoder, programmer and persistence checks passed.
- Full board flash readback passed; core switching, game launching, GB saves and clock resume confirmed by the user.

## v0.1.0 — 26 October 2026

First public release of the shared BL616 menu with NES, Master System/Game Gear and Game Boy/Colour support. Includes GB battery saves, manual clock and saved-clock resume; streamlined Games paging, responsive highlight movement and larger artwork packets. SNES remains experimental. The public firmware excludes device-specific maintenance.
