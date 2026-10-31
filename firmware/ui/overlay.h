#pragma once

extern int _overlay_on;
extern int overlay_on();
extern void overlay_cursor(int x, int y);
extern void dprint(const char *fmt, ...);
extern void overlay_printf(const char *fmt, ...);
extern void overlay_clear();
extern void overlay_status(const char *fmt, ...);
// Route game-loader progress to the dedicated centre box until the load ends.
extern void overlay_game_loading(bool enabled);
extern void overlay_message(const char *msg, int center);
extern void overlay(int state);     // turn overlay on/off
