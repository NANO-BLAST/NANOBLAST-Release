// GPL-3.0.
#pragma once
void nanoblast_load_background();
const char *nanoblast_background_status();
const char *nanoblast_background_fallback_status();
const char *nanoblast_background_fallback_sd();
void nanoblast_background_reply(unsigned status);

void nanoblast_background_oled(bool enabled);

bool nanoblast_background_ready();

// Paint button tiles, or restore the exact original artwork beneath them.
bool nanoblast_background_helpers(bool visible);
