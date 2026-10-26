// GPL-3.0.
#pragma once
void nanoblast_load_background();
const char *nanoblast_background_status();
const char *nanoblast_background_fallback_status();
const char *nanoblast_background_fallback_sd();
void nanoblast_background_reply(unsigned status);

void nanoblast_background_oled(bool enabled);
