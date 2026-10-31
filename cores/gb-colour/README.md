# NANOBLAST Game Boy/Colour battery saves and manual clock

Candidate; not installed or board validated. Based on the physically confirmed MiSTer boot-ROM revision. Native macOS builds only.

The new CRC-framed 256-byte save bridge pauses at a safe cartridge boundary, transfers SDRAM battery RAM, and restores MBC3 RTC through the existing mapper backup interface. It advertises SAV1 at diagnostic index20 and a dirty generation counter at21. The page buffer uses synchronous block RAM. The native build retains all mapper and absolute boot-ROM initialization guards.

The BL616 firmware adds Settings → Clock with year, month, day, hour and minute fields. A edits/confirms a field, Up/Down adjusts, B returns, and Set clock commits the date/time to SD. The console clock advances only while powered and resumes its checkpoint after power loss. It cannot measure elapsed time with power disconnected. Games retain their own clock offset and halt/carry state; manual corrections adjust that offset. No network time or external RTC is used.

Battery RAM and RTC use alternating CRC-checked records under /gb/saves; console time uses /nanoblast/clock.0 and .1. Each game record is keyed by ROM CRC and length. Writes sync and read back the new slot before it becomes current, preserving the previous file. Both damaged slots block a game launch instead of silently creating an empty save. RAM changes autosave after a short quiet interval, with a three-second dirty limit; RTC and console time checkpoint approximately every ten seconds. Opening the menu or changing games/cores flushes the session. An immediate unplug can lose changes newer than the last completed checkpoint; opening the menu first flushes them.

The HDMI population count moved ahead of an existing register to shorten disparity feedback timing, without adding latency or changing symbols. A 300000-symbol equivalence test compares all three channels and five modes with the baseline.

Tests cover calendar/leap-day conversion, signed clock corrections, day rollover and halted RTC, interrupted journal writes, RAM/clock restore across simulated power loss, CRC/sequence/timeout bounds, menu navigation, and a physical SDRAM save-page round trip in the full engine/HDMI model. Final native timing, pin mapping and packed-image checks must pass before installation. Physical game/save/clock confirmation is still required.

Build: build_native.py --all, finalize.py, pack.py. Source engine pinned to MiSTer Gameboy_MiSTer f6796f3a021db61f804c3151678941ce4d74a3b9; upstream attribution and replacement boot sources are retained. No commercial ROMs are included. This update must preserve primary firmware, other core assets, journal and FPGA boot flash. No fallback or automatic NES recovery.

Packing: NBGBXZ01 uses independent 64-KiB XZ/LZMA2 blocks (16-KiB dictionary and per-block CRC32) to fit the unchanged GB flash allocation. The firmware retains PK01/ZP01/ZP02 decoding. XZ Embedded is copied from the installed Bouffalo SDK, retains its public-domain notices, and enables single-call mode only. It uses the supplied output buffer as its dictionary. Native firmware uses approximately 325 KiB RAM plus 25 KiB uncached RAM, leaving room for task stacks/heap within the 447-KiB region.
