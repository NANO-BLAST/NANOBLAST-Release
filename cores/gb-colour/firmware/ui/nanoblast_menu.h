// NANOBLAST BL616 menu controller. GPL-3.0; see COPYING.NANOBLAST.
#pragma once
#include <cstdint>
#include "../storage/console_clock.h"

namespace nanoblast {
enum class Page { Home, Cores, Settings, Advanced, Clock };
enum class SwitchResult { Loaded, Unavailable, Failed };
enum class BrowseResult { Cancelled, Loaded, Failed };
struct Platform {
    virtual ~Platform() = default;
    virtual void clear() = 0;
    virtual void text(unsigned x, unsigned y, const char *value) = 0;
    virtual void panel(bool enabled, unsigned left, unsigned top, unsigned right, unsigned bottom) = 0;
    virtual void black_panel(unsigned left, unsigned top, unsigned right, unsigned bottom) {panel(true,left,top,right,bottom);}
    virtual void overlay(bool enabled) = 0;
    virtual bool available(unsigned core) = 0;
    virtual SwitchResult switch_core(unsigned core) = 0;
    virtual BrowseResult browse_games(unsigned core) = 0;
    virtual void shortcut(bool select_start) = 0;
    virtual void region(unsigned, bool) {}
    virtual void verify_core(bool) {}
    virtual bool save_boot_core() {return false;}
    virtual void debug(bool) {}
    virtual void oled(bool) {}
    virtual void present() {}
    virtual void large_text(bool) {}
    virtual void half_cell_row(int) {}
    virtual void selection(bool, unsigned, unsigned, unsigned, unsigned) {}
    virtual ClockDate clock_get() {return ClockDate{};}
    virtual bool clock_set(const ClockDate &) {return false;}
    virtual void status() {}
    virtual unsigned detected_core() const {return 0;}
    virtual const char *switch_error() {return "Core load failed";}
};
inline void fixed_menu_panel(Platform &p){p.panel(true,1,14,31,23);}
class Menu {
public:
    explicit Menu(Platform &platform, unsigned active_core = 1);
    void input(uint16_t buttons);
    void redraw();
    void show();
    Page page() const { return page_; }
    unsigned active_core() const { return core_; }
    bool running() const { return running_; }
    bool visible() const { return visible_; }
private:
    Platform &p_;
    Page page_ = Page::Home;
    unsigned choice_ = 0, core_;
    uint16_t previous_ = 0;
    bool running_ = false, visible_ = true, select_start_ = false;
    bool debug_ = false;
    bool pal_[3] = {false,false,false};
    bool verify_core_ = false;
    bool experimental_ = false;
    bool oled_ = false;
    bool clock_editing_=false;
    ClockDate clock_draft_{};
    void adjust_clock(int direction);
    const char *message_ = "";
    unsigned count() const;
    void select();
};
}
