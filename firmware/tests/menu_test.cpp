#include "nanoblast_menu.h"
#include <cassert>
#include <string>
#include <vector>
using namespace nanoblast;
struct Fake:Platform {
    std::vector<std::string> lines;
    bool nes=true,sms=false,snes=false,game=false,enabled=true,start=false,debug_enabled=false;
    unsigned switches=0,status_calls=0,recovered=0;
    unsigned region_core=0;bool region_pal=false;
    bool oled_mode=false;
    void oled(bool v)override{oled_mode=v;}
    bool verification=true,save_ok=true;unsigned boot_saves=0;
    unsigned selected_row=0,selected_left=0,selected_right=0;bool large=false;
    SwitchResult result=SwitchResult::Loaded;
    void clear() override {lines.clear();}
    void text(unsigned,unsigned y,const char*s) override {if(std::string(s)=="Up/Down Move   A/B Select")assert(y==24);lines.emplace_back(s);}
    void panel(bool enabled,unsigned,unsigned,unsigned,unsigned) override {assert(!enabled);}
    void overlay(bool x) override {enabled=x;}
    bool available(unsigned id) override {return id==1?nes:id==5?sms:id==2?snes:false;}
    SwitchResult switch_core(unsigned) override {++switches;return result;}
    BrowseResult browse_games(unsigned) override {return game ? BrowseResult::Loaded : BrowseResult::Cancelled;}
    unsigned detected_core()const override{return recovered;}
    void shortcut(bool v) override {start=v;}
    void region(unsigned id,bool pal) override {region_core=id;region_pal=pal;}
    bool save_boot_core()override{++boot_saves;return save_ok;}
    void verify_core(bool v) override {verification=v;}
    void debug(bool v) override {debug_enabled=v;}
    void status() override {++status_calls;text(2,3,"Core: NES");}
    void large_text(bool enabled)override{assert(!enabled);large=enabled;}
    void selection(bool enabled,unsigned left,unsigned top,unsigned right,unsigned bottom) override {assert(enabled&&bottom==top+(large?1:0));selected_row=top;selected_left=left;selected_right=right;}
    bool has(const char*s) {for(auto &v:lines)if(v==s)return true;return false;}
};
void press(Menu&m,unsigned key){m.input(key);m.input(0);}
void sms(Menu&m){press(m,0x20);press(m,1);press(m,0x20);press(m,0x20);press(m,1);}
int main(){
    Fake oled_view;Menu oled_menu(oled_view);oled_menu.redraw();
    press(oled_menu,0x20);press(oled_menu,0x20);press(oled_menu,1);
    assert(oled_view.has("[ ] OLED Mode")&&!oled_view.oled_mode);
    for(unsigned i=0;i<5;i++)press(oled_menu,0x20);
    press(oled_menu,1);assert(oled_view.oled_mode&&oled_view.has("[x] OLED Mode")&&oled_view.selected_row==20);
    press(oled_menu,0x40);assert(oled_view.oled_mode);
    press(oled_menu,0x20);press(oled_menu,0x20);press(oled_menu,1);
    for(unsigned i=0;i<5;i++)press(oled_menu,0x20);
    press(oled_menu,1);assert(!oled_view.oled_mode&&oled_view.has("[ ] OLED Mode"));

    Fake verification;Menu verified(verification);
    assert(!verification.verification);
    press(verified,0x20);press(verified,0x20);press(verified,1);
    assert(verification.has("Advanced")&&!verification.has("[ ] Verify core")&&!verification.has("[ ] Debug mode"));
    for(unsigned i=0;i<4;i++)press(verified,0x20);
    press(verified,1);assert(verified.page()==Page::Advanced);
    assert(verification.has("[ ] Verify core")&&verification.has("[ ] Debug mode"));
    press(verified,0x20);press(verified,0x20);
    press(verified,1);assert(verification.has("[x] Verify core")&&verification.verification&&verification.selected_row==17);
    press(verified,1);assert(!verification.verification);
    press(verified,1);assert(verification.verification);
    press(verified,0x40);assert(verified.page()==Page::Settings&&verification.selected_row==19);
    press(verified,1);press(verified,1);assert(verified.page()==Page::Settings&&verification.selected_row==19);
    Menu next_boot(verification);assert(!verification.verification);
    Fake region;region.sms=true;Menu region_menu(region,1);
    press(region_menu,0x20);press(region_menu,0x20);press(region_menu,1);
    assert(region.has("Region: NTSC"));
    for(unsigned i=0;i<2;i++)press(region_menu,0x20);
    press(region_menu,1);assert(region.has("Region: PAL")&&region.region_core==1&&region.region_pal);
    assert(region.has("Applies to next game load")&&region.selected_row==17);
    press(region_menu,0x40);sms(region_menu);
    assert(region.region_core==5&&!region.region_pal);
    press(region_menu,0x20);press(region_menu,0x20);press(region_menu,1);
    assert(region.has("Region: NTSC"));
    Fake no_core;Menu missing(no_core,0);
    press(missing,0x20);press(missing,0x20);press(missing,1);
    assert(no_core.has("Region: choose a core"));
    Fake diagnostics;Menu settings(diagnostics);settings.redraw();
    assert(!diagnostics.has("NANOBLAST"));
    assert(!diagnostics.has(">")&&diagnostics.selected_row==15&&diagnostics.selected_left==3&&diagnostics.selected_right==28);
    assert(!diagnostics.debug_enabled&&diagnostics.status_calls==0&&!diagnostics.has("Core: NES"));
    press(settings,0x20);press(settings,0x20);press(settings,1);
    assert(settings.page()==Page::Settings&&!diagnostics.has("[ ] Debug mode"));
    assert(diagnostics.selected_row==15&&!diagnostics.has(">"));
    for(unsigned i=0;i<4;i++)press(settings,0x20);
    press(settings,1);assert(settings.page()==Page::Advanced);press(settings,0x20);
    settings.input(1);settings.input(1);settings.input(0);
    assert(diagnostics.debug_enabled&&diagnostics.has("[x] Debug mode")&&diagnostics.has("Core: NES"));
    assert(diagnostics.selected_row==16&&!diagnostics.has(">"));
    press(settings,0x40);assert(settings.page()==Page::Settings);press(settings,0x40);assert(diagnostics.debug_enabled&&diagnostics.has("Core: NES"));
    press(settings,0x20);press(settings,0x20);press(settings,1);
    for(unsigned i=0;i<4;i++)press(settings,0x20);
    press(settings,1);press(settings,0x20);press(settings,0x100);
    assert(!diagnostics.debug_enabled&&diagnostics.has("[ ] Debug mode")&&!diagnostics.has("Core: NES"));
    // A fresh boot must start off even if the preceding session enabled it.
    press(settings,1);assert(diagnostics.debug_enabled);
    Menu reboot(diagnostics);reboot.redraw();assert(!diagnostics.debug_enabled&&!diagnostics.has("Core: NES"));
    // A running core needs no SD copy to remain selected.
    Fake active;active.nes=false;Menu current(active,1);
    press(current,0x20);press(current,1);
    assert(active.has("NES core running")&&!active.has("NES core unavailable"));
    assert(active.selected_left==0&&active.selected_right==31&&!active.has(">"));
    press(current,0x20);press(current,1);
    assert(current.page()==Page::Home&&current.active_core()==1&&active.switches==0);
    assert(!active.has("Core image not installed"));
    Fake f;Menu m(f);m.redraw();assert(f.has("Cores")&&!f.has("Resume game"));
    sms(m);assert(f.switches==0&&m.active_core()==1&&f.has("Core image not installed"));
    f.sms=true;press(m,1);assert(f.switches==1&&m.active_core()==5&&!m.running());
    // Holding Select must not launch a second action after a page transition.
    m.input(0x20);m.input(0x20);m.input(0);m.input(1);m.input(1);m.input(0);
    assert(m.page()==Page::Cores&&f.switches==1);
    press(m,0x40);f.game=true;press(m,1);assert(m.running()&&!m.visible()&&!f.enabled);
    press(m,0x84);assert(m.visible()&&f.has("Resume game"));
    f.game=false;press(m,1);assert(m.running()&&m.visible());
    press(m,0x20);press(m,0x20);press(m,1);press(m,0x20);press(m,1);assert(f.start);
    press(m,0x40);press(m,0x20);press(m,1);press(m,0x20);
    f.result=SwitchResult::Failed;press(m,1);
    assert(m.active_core()==0&&!m.running()&&f.has("Core load failed"));
    press(m,0x40);press(m,1);assert(f.has("Choose a core first"));
    // A failed SMS switch that actually restores NES must retain NES in both
    // Cores and Games, without claiming the requested SMS core was loaded.
    Fake recovery;recovery.sms=true;recovery.result=SwitchResult::Failed;recovery.recovered=1;
    Menu restored(recovery,1);sms(restored);
    assert(restored.active_core()==1&&recovery.has("NES core running")&&recovery.has("Core load failed"));
    press(restored,0x40);press(restored,1);
    assert(!recovery.has("Choose a core first"));
    // Experimental cores are hidden and unreachable until explicitly enabled.
    Fake sn;sn.snes=true;Menu snes_menu(sn,1);assert(sn.switches==0);
    press(snes_menu,0x20);press(snes_menu,1);
    assert(!sn.has("Super Nintendo (experimental)")&&!sn.has("SNES core unavailable"));
    for(unsigned i=0;i<5;i++)press(snes_menu,0x20);
    assert(sn.selected_row==17); // No hidden SNES navigation slot.
    press(snes_menu,0x40);press(snes_menu,0x20);press(snes_menu,0x20);press(snes_menu,1);
    for(unsigned i=0;i<4;i++)press(snes_menu,0x20);
    press(snes_menu,1);
    for(unsigned i=0;i<3;i++)press(snes_menu,0x20);
    press(snes_menu,1);assert(sn.has("[x] Experimental cores"));
    press(snes_menu,0x40);
    press(snes_menu,0x40);press(snes_menu,0x20);press(snes_menu,1);
    for(unsigned i=0;i<3;i++)press(snes_menu,0x20);
    assert(sn.selected_row==18&&sn.has("Super Nintendo (experimental)"));
    press(snes_menu,1);assert(snes_menu.active_core()==2&&sn.switches==1&&sn.region_core==2&&!sn.region_pal);
    press(snes_menu,0x20);press(snes_menu,0x20);press(snes_menu,1);
    for(unsigned i=0;i<2;i++)press(snes_menu,0x20);
    press(snes_menu,1);assert(sn.region_core==2&&sn.region_pal);
    // Disabling visibility neither unloads nor switches the running core.
    press(snes_menu,0x20);press(snes_menu,0x20);press(snes_menu,1);
    for(unsigned i=0;i<3;i++)press(snes_menu,0x20);
    press(snes_menu,1);assert(sn.has("[ ] Experimental cores"));
    press(snes_menu,0x40);
    press(snes_menu,0x40);press(snes_menu,0x20);press(snes_menu,1);
    assert(!sn.has("Super Nintendo (experimental)")&&snes_menu.active_core()==2&&sn.switches==1);
    press(snes_menu,0x40);press(snes_menu,1);assert(sn.region_core==2&&sn.region_pal);
    Fake retained;Menu snes_boot(retained,2);snes_boot.redraw();assert(!retained.switches);
    press(snes_boot,0x20);press(snes_boot,1);assert(!retained.has("SNES core running"));
    Fake save;save.sms=true;save.recovered=1;Menu saver(save,1);saver.redraw();
    assert(!save.boot_saves);
    press(saver,0x20);press(saver,0x20);press(saver,1);
    assert(save.has("Core boot flash")&&!save.has("[ ] Core boot flash")&&!save.has("[x] Core boot flash"));
    for(unsigned i=0;i<3;i++)press(saver,0x20);
    save.save_ok=false;press(saver,1);assert(save.boot_saves==1&&save.has("Core load failed"));
    save.save_ok=true;saver.input(1);saver.input(1);saver.input(0);
    assert(save.boot_saves==2&&save.has("Core saved to boot flash")&&saver.active_core()==1);
    press(saver,1);assert(save.boot_saves==3); // Each fresh press is one action.
    press(saver,0x40);sms(saver);assert(save.boot_saves==3&&saver.active_core()==5);
    Fake no_active;Menu no_active_menu(no_active,0);
    press(no_active_menu,0x20);press(no_active_menu,0x20);press(no_active_menu,1);
    for(unsigned i=0;i<3;i++)press(no_active_menu,0x20);
    press(no_active_menu,1);assert(!no_active.boot_saves&&no_active.has("Choose a core first"));
    Fake rebooted;Menu reboot_menu(rebooted,5);reboot_menu.redraw();
    assert(!rebooted.switches&&!rebooted.boot_saves&&reboot_menu.active_core()==5);
    return 0;
}
