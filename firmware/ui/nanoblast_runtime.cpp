// NANOBLAST menu runtime. GPL-3.0; see COPYING.NANOBLAST.
#include "nanoblast_runtime.h"
#include "nanoblast_menu.h"
#ifdef NANOBLAST_RUNTIME_HOST_TEST
#include "../tests/runtime_platform.h"
static bool gb_save_flush(){return true;}
static void gb_save_forget(){}
static void gb_save_service(){}
static const char *gb_save_status(){return "GB save test";}
void nanoblast_clock_service(bool){}
bool nanoblast_clock_checkpoint(){return true;}
nanoblast::ClockDate nanoblast_clock_date(){return {};}
bool nanoblast_clock_set(const nanoblast::ClockDate&){return true;}
#else
#include "utils.h"
#include "overlay.h"
#include "cores.h"
#include "file_chooser.h"
#include "programmer.h"
#include "background_runtime.h"
#include "init.h"
#include "fpga_sd.h"
#include "fpga_flash.h"
#include "background_setup.h"
#include "core_assets.h"
#include "switch_trace.h"
#include "gb_save.h"
#endif
#include <cstdio>
#include <algorithm>
#include <cstring>
#include "loading_screen.h"
extern int nanoblast_sd_mount_result;
extern const char *drv;
extern const char *BOARD_NAME;
extern int option_osd_key;

namespace {
const char *startup_diagnostic="Startup: not sampled";
struct TextFrames {char shown[28][32],frame[28][32];};
class Runtime : public nanoblast::Platform {
    int detected_core_=-1;
    bool debug_=false;
    bool game_imported_=false,gb_test_ready_=false;
    bool verify_core_=false,oled_=false;
    const char *switch_error_="Core load failed";
    char (&shown_)[28][32],(&frame_)[28][32];
    bool composing_=false,shown_valid_=false,logo_cleared_=false,panel_known_=false;
    bool large_text_=false,shown_large_text_=false;
    bool status_panel_=false,shown_status_panel_=false;
    int half_cell_row_=-1,shown_half_cell_row_=-1;
    uint32_t panel_word_=0x03000000u,shown_panel_=0;
    bool selection_known_=false;
    uint32_t selection_word_=0x02000000u,shown_selection_=0;
    bool image(unsigned id,std::string &path) {
        core_info *c=find_core_by_id(id);
        if(!c)return false;
        // Never fall back to a Console bitstream in the generic core folder.
        if(const char *installed=nanoblast_core_path(id))path=installed;
        else path=std::string(drv)+"cores/"+BOARD_NAME+"/"+c->core_file;
        FILINFO info;
        return f_stat(path.c_str(),&info)==FR_OK && info.fsize && !(info.fattrib&AM_DIR);
    }
    void clear_legacy_logo() {
        if(logo_cleared_)return;
        for(unsigned address=0x380;address<0x400;address++)
            register_word(((address&31)<<16)|((address>>5)<<8));
        logo_cleared_=true;
    }
    void register_word(uint32_t word) {
        taskENTER_CRITICAL();
        fpga_tx_header(0x0e,5);
        for(int shift=24;shift>=0;shift-=8)fpga_tx_byte(word>>shift);
        taskEXIT_CRITICAL();
    }
public:
    explicit Runtime(TextFrames &frames):shown_(frames.shown),frame_(frames.frame){}
    bool save_boot_core() override{
        const unsigned id=detected_core();
        if(!id){switch_error_="Choose a core first";return false;}
        if(get_core_id()!=static_cast<int>(id)){
            switch_error_="Active core did not reply";return false;
        }
        const auto result=configure_core(id,true);
        if(result==nanoblast::SwitchResult::Unavailable)switch_error_="Core image not installed";
        return result==nanoblast::SwitchResult::Loaded;
    }
    void remember_core(int id){detected_core_=id==1||id==5||id==2||id==7?id:-1;}
    unsigned detected_core() const override {return detected_core_==1||detected_core_==5||detected_core_==2||detected_core_==7?unsigned(detected_core_):0;}
    void external_screen_changed() {shown_valid_=false;}
    void load_artwork() {
        if(!oled_)nanoblast_loading_screen();
        // A JTAG reload restores the FPGA bitmap even if normal text is blank.
        // Remove it before the artwork loader draws its single LOADING label.
        clear_legacy_logo();
        nanoblast_load_background();
        // Artwork/provisioning writes directly to the FPGA text buffer.
        // Invalidate after it finishes so the next menu frame replaces every
        // progress cell and redraws labels that were cleared behind our cache.
        external_screen_changed();
    }

    void oled(bool enabled) override {
        if(oled_==enabled)return;
        oled_=enabled;nanoblast_background_oled(enabled);external_screen_changed();
    }
    void debug(bool enabled) override {debug_=enabled;}
    void status() override {
        if(!debug_)return;
        status_panel_=true;
        text(0,1,startup_diagnostic);
        text(0,2,fpga_boot_flash_diagnostic());
        text(2,3,detected_core_==1?"Core: NES":detected_core_==5?"Core: SMS/Game Gear":detected_core_==2?"Core: SNES":detected_core_==7?"Core: GB":"Core: waiting for reply");
        char line[33];
        if(nanoblast_sd_mount_result==FR_OK)text(2,4,"SD card: ready");
        else {std::snprintf(line,sizeof line,"SD card: mount error %d",nanoblast_sd_mount_result);text(2,4,line);}
        std::snprintf(line,sizeof line,"Artwork: %s",nanoblast_background_status());text(2,5,line);
        // Diagnostic counters identify receive loss on screen.
        std::snprintf(line,sizeof line,"Link: %lu bytes, lost %lu",static_cast<unsigned long>(uart_receive_count()),static_cast<unsigned long>(uart_receive_dropped()));text(2,6,line);
        text(2,7,fpga_sd_diagnostic());
        if(detected_core_==7){for(unsigned i=0;i<4;i++)text(0,10+i,gb_diagnostic(i));return;}
        text(0,10,detected_core_==2?snes_load_diagnostic():nanoblast_background_fallback_status());
        text(2,11,detected_core_==2?snes_transfer_diagnostic():nanoblast_background_fallback_sd());
        text(0,12,detected_core_==2?snes_cpu_diagnostic():nanoblast_core_setup_status());

        text(0,13,detected_core_==7?gb_save_status():detected_core_==2?snes_apu_diagnostic():nanoblast_switch_trace_status());
    }
    void clear() override {
        // Compose the complete screen in RAM without blanking the live display.
        std::memset(frame_,' ',sizeof frame_);
        composing_=true;status_panel_=false;
    }
    void text(unsigned x,unsigned y,const char *s) override {
        if(composing_) {
            if(x<32&&y<28)std::memcpy(frame_[y]+x,s,std::min<std::size_t>(32-x,std::strlen(s)));
        } else {
            overlay_cursor(x,y);overlay_printf("%s",s);
            shown_valid_=false;
        }
    }
    void large_text(bool enabled) override {large_text_=enabled;}
    void half_cell_row(int row) override {half_cell_row_=row>=0&&row<28?row:-1;}
    void present() override {
        if(!composing_)return;
        clear_legacy_logo();
        for(unsigned y=0;y<28;y++)for(unsigned x=0;x<32;) {
            if(shown_valid_&&shown_[y][x]==frame_[y][x]){++x;continue;}
            unsigned start=x++;
            while(x<32&&(!shown_valid_||shown_[y][x]!=frame_[y][x]))++x;
            overlay_cursor(start,y);overlay_printf("%.*s",int(x-start),frame_[y]+start);
        }
        if(!shown_valid_||large_text_!=shown_large_text_||half_cell_row_!=shown_half_cell_row_||status_panel_!=shown_status_panel_)
            register_word(0x04200000u|(status_panel_?1u<<23:0)|(large_text_?1u<<20:0)|(half_cell_row_>=0?1u<<22:0)|(22u<<15)|((half_cell_row_>=0?unsigned(half_cell_row_):15u)<<10));
        shown_status_panel_=status_panel_;
        shown_half_cell_row_=half_cell_row_;
        shown_large_text_=large_text_;
        if(!panel_known_||!shown_valid_||shown_panel_!=panel_word_)register_word(panel_word_);
        if(!selection_known_||!shown_valid_||shown_selection_!=selection_word_)register_word(selection_word_);
        shown_selection_=selection_word_;selection_known_=true;
        shown_panel_=panel_word_;panel_known_=true;
        std::memcpy(shown_,frame_,sizeof shown_);
        shown_valid_=true;composing_=false;
    }
    void panel(bool enabled,unsigned left,unsigned top,unsigned right,unsigned bottom) override {
        set_panel(enabled,left,top,right,bottom,false);
    }
    void black_panel(unsigned left,unsigned top,unsigned right,unsigned bottom) override {
        set_panel(true,left,top,right,bottom,true);
    }
    void set_panel(bool enabled,unsigned left,unsigned top,unsigned right,unsigned bottom,bool solid) {
        // The FPGA supports one rectangle. Include the diagnostic
        // area only while Debug mode is enabled.
        uint32_t word=0x03000000u | (solid?1u<<21:0) | (enabled?1u<<20:0) | (bottom<<15) | (top<<10) | (right<<5) | left;
        if(composing_)panel_word_=word;
        else {
            register_word(word);
            shown_panel_=word;panel_known_=true;
        }
    }
    void overlay(bool enabled) override {
        ::overlay(enabled);
        if(enabled){gb_save_flush();nanoblast_clock_service(true);}
    }
    nanoblast::ClockDate clock_get() override {return nanoblast_clock_date();}
    bool clock_set(const nanoblast::ClockDate &d) override {
        return gb_save_flush()&&nanoblast_clock_set(d);
    }
    void selection(bool enabled,unsigned left,unsigned top,unsigned right,unsigned bottom) override {
        uint32_t word=0x02000000u|(enabled?1u<<20:0)|(bottom<<15)|(top<<10)|(right<<5)|left;
        if(composing_)selection_word_=word;
        else {register_word(word);shown_selection_=word;selection_known_=true;}
    }
    bool available(unsigned id) override {std::string path;return image(id,path)||nanoblast_core_asset_available(id);}
    const char *switch_error() override {return switch_error_;}
    void recover_boot_display(bool reload=true) {
        detected_core_=-1;
        if(reload)fpga_reload_boot_core();
        shown_valid_=false;logo_cleared_=false;panel_known_=false;selection_known_=false;
        for(unsigned attempt=0;attempt<10;attempt++) {
            int id=get_core_id();
            if(id==1||id==5||id==2||id==7) {detected_core_=id;nanoblast_switch_trace(nanoblast::SwitchStep::Recovered,id);::overlay(1);load_artwork();return;}
            delay(20);
        }
    }
    nanoblast::SwitchResult switch_core(unsigned id) override {
        return configure_core(id,false);
    }
    nanoblast::SwitchResult configure_core(unsigned id,bool save_boot) {
        if(!gb_save_flush()){switch_error_=gb_save_status();return nanoblast::SwitchResult::Failed;}
        nanoblast_clock_service(true);
        switch_error_="Core load failed";
        nanoblast_switch_trace_begin(id);
        std::string path;
        const bool built_in=nanoblast_core_asset_available(id);
        if(!built_in&&!image(id,path))return nanoblast::SwitchResult::Unavailable;
        gb_save_forget();
        shown_valid_=false;logo_cleared_=false;panel_known_=false;selection_known_=false;
        core_running=false;
        detected_core_=-1;
        if(!save_boot){
        // Ordinary core selections always change only volatile SRAM.
        if(!(built_in?fpga_activate_asset(id):(fpga_stage_core(path.c_str())&&fpga_activate_staged()))) {
            switch_error_=fpga_program_diagnostic();recover_boot_display(false);return nanoblast::SwitchResult::Failed;
        }
        bool confirmed=false;
        for(unsigned attempt=0;attempt<20&&!confirmed;attempt++){
            confirmed=get_core_id()==static_cast<int>(id);
            if(!confirmed)delay(20);
        }
        if(!confirmed){switch_error_="SRAM core did not reply";return nanoblast::SwitchResult::Failed;}
        detected_core_=id;::overlay(1);load_artwork();return nanoblast::SwitchResult::Loaded;
        }
        if(!built_in&&!fpga_stage_core(path.c_str())) {switch_error_=fpga_program_diagnostic();recover_boot_display(false);return nanoblast::SwitchResult::Failed;}
        // One-time upgrade from the old bitstream: it has no flash bridge.
        // This runs only after the explicit Core boot flash action.
        if(!fpga_flash_available()) {
            if(!(built_in?fpga_activate_asset(id):fpga_activate_staged())) {switch_error_=fpga_program_diagnostic();recover_boot_display(false);return nanoblast::SwitchResult::Failed;}
            bool identified=false;
            for(unsigned attempt=0;attempt<10&&!identified;attempt++)identified=get_core_id()==static_cast<int>(id);
            if(!identified||!fpga_flash_available()) {switch_error_="Core flash bridge did not start";recover_boot_display();return nanoblast::SwitchResult::Failed;}
        }
        nanoblast_switch_trace(nanoblast::SwitchStep::SaveBoot,id);
        if(!(built_in?fpga_persist_asset(id,verify_core_):fpga_persist_core(verify_core_))) {switch_error_=fpga_persist_diagnostic();recover_boot_display(false);return nanoblast::SwitchResult::Failed;}
        // Only report success after the saved boot image answers as selected.
        bool confirmed=false;
        for(unsigned attempt=0;attempt<10&&!confirmed;attempt++)confirmed=get_core_id()==static_cast<int>(id);
        if(!confirmed){switch_error_="Saved core did not start";recover_boot_display(false);return nanoblast::SwitchResult::Failed;}
        detected_core_=id;nanoblast_switch_trace(nanoblast::SwitchStep::Complete,id);::overlay(1);load_artwork();return nanoblast::SwitchResult::Loaded;
    }

    nanoblast::BrowseResult browse_games(unsigned id) override {
        core_info *c=find_core_by_id(id);
        if(!c || get_core_id()!=static_cast<int>(id))return nanoblast::BrowseResult::Failed;
        if(!gb_save_flush())return nanoblast::BrowseResult::Failed;
        FileChooser chooser;
        chooser.menu_platform=this;
        chooser.menu_title=id==1?"NINTENDO NES":id==5?"SMS / GAME GEAR":id==7?"GAME BOY":"SUPER NINTENDO";
        // The browser writes directly to the overlay; repaint on return.
        shown_valid_=false;
        if(id==5&&!game_imported_) {
            if(!nanoblast_import_game()) {
                overlay_message("SD game copy failed",1);
                return nanoblast::BrowseResult::Failed;
            }
            // The menu never modifies imported games. Verify once per boot,
            // rather than reading the entire imported ROM before each launch.
            game_imported_=true;
        }
        if(id==7&&!gb_test_ready_){
            if(!nanoblast_prepare_gb_game()){overlay_message("GB test ROM copy failed",1);return nanoblast::BrowseResult::Failed;}
            gb_test_ready_=true;
        }
        selection(false,0,0,0,0);
        // Each core owns a games folder; navigation cannot leave that folder.
        chooser.rootdir=drv;
        if(chooser.rootdir.back()!='/')chooser.rootdir+="/";
        chooser.rootdir+=c->rom_dir;
        chooser.curdir=chooser.rootdir;
        chooser.msg_return="<< Return to NANOBLAST";
        std::string name;
        bool chosen=chooser.choose_file(name);
        shown_valid_=false;
        selection(false,0,0,0,0);
        if(!chosen)return chooser.last_error==FR_OK ? nanoblast::BrowseResult::Cancelled : nanoblast::BrowseResult::Failed;
        if(c->load_rom(name.c_str())!=FR_OK) {
            core_running=false;::overlay(1);
            overlay_message("Game load failed",1);
            return nanoblast::BrowseResult::Failed;
        }
        return core_running ? nanoblast::BrowseResult::Loaded : nanoblast::BrowseResult::Failed;
    }
    void shortcut(bool start) override {
        option_osd_key=start ? OPTION_OSD_KEY_SELECT_START : OPTION_OSD_KEY_SELECT_RIGHT;
    }
    void region(unsigned id,bool pal) override {
        if(id!=1&&id!=5&&id!=2)return;
        // All Nano cores latch bit 2 only at the start of a ROM load.
        // Preserve other configuration flags and the currently running game.
        set_core_config((get_core_config()&~4u)|(pal?4u:0u));
    }
    void verify_core(bool enabled) override {verify_core_=enabled;}
};
}
// Observe cold-start readiness only. Never replace the power-on configuration.
bool nanoblast_wait_boot_core() {
    const uint64_t started=bflb_mtimer_get_time_ms();
    do{
        const int id=get_core_id();
        if(id==1||id==5||id==2||id==7){
            startup_diagnostic=id==7?"Startup: GB from power-on":id==5?"Startup: SMS from power-on":id==2?"Startup: SNES from power-on":"Startup: NES from power-on";
            return true;
        }
        delay(20);
    }while(bflb_mtimer_get_time_ms()-started<5000);
    startup_diagnostic="Startup: no core reply";
    return false;
}
void nanoblast_menu_loop() {
    // Keep the screen buffers off the main task's stack.
    static TextFrames frames;
    Runtime runtime(frames);
    int id=-1;
    for(unsigned attempt=0;attempt<5 && id<0;attempt++){
        id=get_core_id();
        if(id<0)delay(20);
    }
    runtime.remember_core(id);
    nanoblast::Menu menu(runtime,id==1 || id==5 || id==2 || id==7 ? id : 0);
    runtime.overlay(true);
    // Boot flash has already configured the FPGA. Never reload a saved choice
    // from software at startup. Saving is an explicit menu action only.
    menu.redraw();
    nanoblast_switch_trace_boot();
    if(id==1 || id==5 || id==2 || id==7)runtime.load_artwork();
    nanoblast_clock_service();
    menu.redraw();
    uint16_t hid1_old=0xffff,hid2_old=0xffff;
    for(;;) {
        uint16_t joy1=0,joy2=0,hid1=0,hid2=0;
        get_joypad_states(&joy1,&joy2,&hid1,&hid2);
        // Keep USB controllers available to the running game.
        if(hid1!=hid1_old || hid2!=hid2_old) {
            taskENTER_CRITICAL();
            fpga_tx_header(0x09,5);
            fpga_tx_byte(hid1>>8);fpga_tx_byte(hid1);
            fpga_tx_byte(hid2>>8);fpga_tx_byte(hid2);
            taskEXIT_CRITICAL();
            hid1_old=hid1;hid2_old=hid2;
        }
        gb_save_service();
        nanoblast_clock_service();
        menu.input(joy1|joy2|hid1|hid2);
        delay(20);
    }
}
