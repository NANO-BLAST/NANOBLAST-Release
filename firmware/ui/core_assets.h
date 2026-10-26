#pragma once
// Provision approved Nano images from auxiliary flash to versioned SD files.
void nanoblast_prepare_cores();
const char *nanoblast_core_path(unsigned id);
const char *nanoblast_core_setup_status();

// Inspect availability without copying files or configuring the FPGA.
bool nanoblast_core_asset_available(unsigned id);
// Called only after an explicit core choice from the visible menu.
bool nanoblast_prepare_core(unsigned id);
// Import a user-supplied SMS file from the auxiliary transfer slot on Games.
bool nanoblast_import_game();

bool nanoblast_prepare_gb_game();
