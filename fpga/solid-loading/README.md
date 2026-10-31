# Opaque loading panel

The existing BL616 menu already sends command 3 bit 21 for the centred loading
rectangle. The shipped FPGA renderer stores that bit but does not use it when
producing overlay pixels. It therefore emits the ordinary translucent panel mask.

`textdisp.v` corrects that pixel path: when panel enable and solid are set, blank
pixels inside the rectangle emit opaque BGR black (`16'h8000`). Glyphs still
render above that background. Outside the rectangle the normal transparency
contract is preserved. Solid mode also takes priority over stale selection
colour/inversion; ordinary menu selection and translucent panels are unchanged.

The file derives from the NanoBlast shared renderer (GPL-3.0); baseline SHA-256
`cb1a2d0e82346e539583aff3c6fe0d6c2f5703c08d07da606b9da39b7d47410c`.
The only renderer changes are the solid-panel background condition and suppression
of selection glyph inversion in solid mode. CDC/reset support is copied unchanged.

Run `python3 scripts/test_solid_loading.py --tools /path/to/iverilog/bin` from the
setup repository. The test exercises 229,376 actual renderer pixels across
normal translucent panels, solid panels, overlapping selection and panel cleanup.
It checks black opacity, glyph colour, rectangle edges and transparent surroundings.

Build products and full source snapshots remain under ignored `hardware-tests/`.
`prepare_solid_loading_cores.py` prepares isolated NES/SMS/SNES inputs from the
existing source workspace without editing it. GB uses the self-contained
`outputs/gb-mister-save-clock/source.zip` archive with only its shared renderer
replaced. Gowin/nextpnr timing and physical storage pins must pass before packaging.
The developer installer updates the BL616 core bank and menu with full backup and
readback. It does not program the FPGA boot flash; explicitly select each core
after installation to load its new renderer into SRAM.

SNES uses the equivalent implementation from `scripts/pipeline_snes_solid_panel.py`,
which latches solid opacity with its rectangle hit. It passes the same pixel
comparisons and provides a route that meets the existing SNES clock requirements.
