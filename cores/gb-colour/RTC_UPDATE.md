# MBC3 timer cartridge update

The first MiSTer-based candidate displayed artwork and accepted controller input on the board. Pokémon Crystal was rejected by firmware before download because timer cartridge types 0x0f/0x10 were explicitly excluded.

This revision connects a free-running 32768 Hz enable from 27 MHz to the existing MiSTer MBC3 RTC, defines deterministic zero initial clock state on cartridge reset, and advertises debug register 13 as RTC1. The shared loader accepts the timer types only after verifying RTC1, keeping older assets protected. CGB1 negotiation, ROM header checksum, size and CRC checks remain.

Clock ticking, registers, latching, rollover, halt and CPU-pause operation were simulated. Native Gowin timing and pin checks passed. The production packed-image decoder passed. Physical Pokémon Crystal validation remains pending. Battery saves and clock persistence across power-off are not integrated; this revision must not be represented as supporting persistent saves.
