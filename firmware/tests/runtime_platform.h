// Host fixture for compiling and exercising the real BL616 runtime adapter.
#pragma once
#include <string>
#include <cstdint>
#include "runtime_fatfs_platform.h"
constexpr int OPTION_OSD_KEY_SELECT_START=1,OPTION_OSD_KEY_SELECT_RIGHT=2;
struct core_info {unsigned id;const char *core_file,*rom_dir;int (*load_rom)(const char*);};
namespace nanoblast {struct Platform;}
struct FileChooser {
    std::string rootdir,curdir,msg_return,menu_title;
    int last_error=FR_OK;
    nanoblast::Platform *menu_platform=nullptr;
    bool choose_file(std::string &);
};
void fpga_tx_header(int,int);void fpga_tx_byte(uint8_t);
void overlay_clear();void overlay_cursor(unsigned,unsigned);void overlay_printf(const char*,...);
void overlay(int);void overlay_message(const char*,int);
int f_stat(const char*,FILINFO*);bool fpga_program(const char*);
int get_core_id();uint64_t bflb_mtimer_get_time_ms();void delay(int);
core_info *find_core_by_id(unsigned);
void get_joypad_states(uint16_t*,uint16_t*,uint16_t*,uint16_t*);
extern bool core_running;
#define taskENTER_CRITICAL() do {} while(0)
#define taskEXIT_CRITICAL() do {} while(0)

void nanoblast_load_background();
void nanoblast_background_oled(bool);
const char *nanoblast_background_status();
const char *nanoblast_background_fallback_status();
const char *nanoblast_background_fallback_sd();
uint32_t uart_receive_count();
uint32_t uart_receive_dropped();
const char *fpga_sd_diagnostic();
void nanoblast_prepare_background();
const char *nanoblast_background_setup_status();
const char *nanoblast_background_setup_diagnostic();

const char *nanoblast_core_path(unsigned);
void nanoblast_prepare_cores();

const char *nanoblast_core_setup_status();

bool nanoblast_core_asset_available(unsigned);
bool nanoblast_prepare_core(unsigned);
bool nanoblast_import_game();
bool nanoblast_prepare_gb_game();

bool fpga_persist_core(bool);
bool fpga_persist_asset(unsigned,bool);
bool fpga_activate_staged();
bool fpga_stage_core(const char*);
bool fpga_activate_asset(unsigned);
bool fpga_flash_available();
const char *fpga_persist_diagnostic();
const char *fpga_boot_flash_diagnostic();
const char *snes_load_diagnostic();
const char *snes_transfer_diagnostic();
const char *snes_cpu_diagnostic();
const char *snes_apu_diagnostic();

const char *fpga_program_diagnostic();
void fpga_reload_boot_core();
uint32_t get_core_config();void set_core_config(uint32_t);

#include "../storage/switch_trace.h"

const char *gb_diagnostic(unsigned);
