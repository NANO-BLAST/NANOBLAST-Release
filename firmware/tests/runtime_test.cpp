#define NANOBLAST_RUNTIME_HOST_TEST
#include "../ui/nanoblast_runtime.cpp"
#include <cassert>
#include <map>
#include <vector>
#include <cstdarg>
#include <cstdio>
const char *drv="usb:",*BOARD_NAME="nano20k";
int option_osd_key=2;
uint32_t config=0;
uint32_t get_core_config(){return config;}
void set_core_config(uint32_t v){config=v;}
bool core_running=true,program_ok=true,cancel=false;
bool bridge=false;unsigned staged=0;
bool persist_ok=true,loop_test=false,require_logo_cleared=false;unsigned persisted=0,prepared_cores=0,reloads=0;
unsigned loading_screens=0;
unsigned background_preparations=0;
void nanoblast_loading_screen(){
 ++loading_screens;
 for(unsigned command:{2u,3u}){
  fpga_tx_header(14,5);fpga_tx_byte(command);fpga_tx_byte(0);fpga_tx_byte(0);fpga_tx_byte(0);
 }
}
int reply=5,rom_result=0;unsigned programs=0;uint64_t ticks=0;
std::map<std::string,FILINFO> files;
std::vector<uint8_t> bytes;
std::string programmed;
std::vector<std::string> text_lines;
char screen[28][32];unsigned cursor_x=0,cursor_y=0,clear_calls=0;
void fpga_tx_header(int cmd,int len){bytes.insert(bytes.end(),{0xaa,uint8_t(len>>8),uint8_t(len),uint8_t(cmd)});}
void fpga_tx_byte(uint8_t v){bytes.push_back(v);}
void nanoblast_switch_trace(nanoblast::SwitchStep,unsigned,uint32_t){}
void nanoblast_switch_trace_boot(){}
void nanoblast_switch_trace_begin(unsigned){}
const char *nanoblast_switch_trace_status(){return "Switch: no trace";}
const char *nanoblast_core_setup_status(){return "core files ready";}
const char *installed_core=nullptr;
const char *nanoblast_core_path(unsigned id){return id==5?installed_core:nullptr;}
void nanoblast_prepare_cores(){++prepared_cores;}
bool built_in=false;unsigned asset_activations=0,asset_saves=0;bool last_verify=true;
bool nanoblast_core_asset_available(unsigned){return built_in;}
bool fpga_activate_asset(unsigned id){assert(id==1||id==5||id==2);++asset_activations;if(program_ok){bridge=true;
#if defined(NANOBLAST_SRAM_VALIDATION)
 reply=id;
#endif
 }return program_ok;}
bool fpga_persist_asset(unsigned id,bool verify){assert(id==1||id==5||id==2);++asset_saves;last_verify=verify;if(persist_ok)reply=id;return persist_ok;}
bool nanoblast_prepare_core(unsigned){assert(false);return false;}
bool import_ok=true;unsigned imports=0;
bool nanoblast_import_game(){imports++;return import_ok;}
bool oled_mode=false;unsigned oled_changes=0;
void nanoblast_background_oled(bool enabled){oled_mode=enabled;++oled_changes;}
void nanoblast_load_background(){
 assert(loading_screens);
 if(require_logo_cleared){
  assert(bytes.size()>=128*8);
  for(unsigned i=0;i<128;i++){
   unsigned pos=bytes.size()-128*8+i*8;
   assert(bytes[pos]==0xaa&&bytes[pos+3]==0x0e&&bytes[pos+7]==0);
  }
  require_logo_cleared=false;
 }
 if(loop_test)assert(std::string(screen[15],32).find("Games")!=std::string::npos);
 // Production artwork clears all live text outside the frame compositor.
 std::memset(screen,' ',sizeof screen);
 std::memcpy(screen[14]+2,"[==========================]",28);
 std::memcpy(screen[27]+11,"LOADING...",10);
}
const char *nanoblast_background_status(){return "test";}
const char *nanoblast_background_fallback_status(){return "";}
const char *nanoblast_background_fallback_sd(){return "";}
uint32_t uart_receive_count(){return 123;}
uint32_t uart_receive_dropped(){return 0;}
const char *fpga_sd_diagnostic(){return "SD ready";}
void nanoblast_prepare_background(){++background_preparations;if(loop_test)assert(std::string(screen[15],32).find("Games")!=std::string::npos);}
const char *nanoblast_background_setup_status(){return "test";}
const char *nanoblast_background_setup_diagnostic(){return "";}
int nanoblast_sd_mount_result=0;
void overlay_clear(){++clear_calls;std::memset(screen,' ',sizeof screen);}
void overlay_cursor(unsigned x,unsigned y){cursor_x=x;cursor_y=y;}
void overlay_printf(const char*format,...){char line[128];va_list args;va_start(args,format);std::vsnprintf(line,sizeof line,format,args);va_end(args);text_lines.emplace_back(line);if(cursor_x<32&&cursor_y<28)std::memcpy(screen[cursor_y]+cursor_x,line,std::min<std::size_t>(32-cursor_x,std::strlen(line)));}
void overlay(int){}void overlay_message(const char*,int){}
int f_stat(const char *p,FILINFO*out){auto it=files.find(p);if(it==files.end())return 1;*out=it->second;return FR_OK;}
bool fpga_stage_core(const char*p){++staged;programmed=p;return program_ok;}
bool fpga_flash_available(){return bridge;}
bool fpga_activate_staged(){++programs;if(program_ok)bridge=true;return program_ok;}
const char *fpga_program_diagnostic(){return "Test programming failed";}
void fpga_reload_boot_core(){++reloads;}
bool fpga_persist_core(bool verify){++persisted;last_verify=verify;return persist_ok;}
const char *fpga_persist_diagnostic(){return "Test flash failed";}
const char *fpga_boot_flash_diagnostic(){return "Boot flash: SMS DE68D692";}
const char *snes_load_diagnostic(){return "SNES test header";}
const char *snes_transfer_diagnostic(){return "ROM: verified";}
const char *snes_cpu_diagnostic(){return "CPU test capture";}
const char *snes_apu_diagnostic(){return "APU test capture";}
unsigned delayed_core_queries=0;
int get_core_id(){if(delayed_core_queries){--delayed_core_queries;ticks+=200;return -1;}return reply;}
uint64_t bflb_mtimer_get_time_ms(){return ticks+=10;}void delay(int n){ticks+=n;}
int load_rom(const char*){core_running=rom_result==0;return rom_result;}
core_info *find_core_by_id(unsigned id){static core_info nes{1,"nestang.bin","nes",load_rom},sms{5,"smstang.bin","sms",load_rom};return id==1?&nes:id==5?&sms:nullptr;}
bool FileChooser::choose_file(std::string &s){assert(rootdir==std::string(drv)+"/" && curdir==rootdir&&menu_platform);s=curdir+"game.sms";return !cancel;}
void get_joypad_states(uint16_t*a,uint16_t*b,uint16_t*c,uint16_t*d){if(loop_test)throw 1;*a=*b=*c=*d=0;}
int main(){
 TextFrames buffers;Runtime r(buffers);
 config=0xa5a5a5a1;r.region(1,true);assert(config==0xa5a5a5a5);
 r.region(5,false);assert(config==0xa5a5a5a1);
 r.region(0,true);assert(config==0xa5a5a5a1);
 files["usb:cores/smstang.bin"]={123,0};
 assert(!r.available(5));assert(r.configure_core(5,true)==nanoblast::SwitchResult::Unavailable&&programs==0&&core_running);
 files["usb:cores/nano20k/smstang.bin"]={123,0};
 assert(r.available(5));
 installed_core="usb:cores/nano20k/sms-12345678.bin";
 assert(!r.available(5));files[installed_core]={907418,0};assert(r.available(5));
 installed_core=nullptr;
 program_ok=false;require_logo_cleared=true;assert(r.configure_core(5,true)==nanoblast::SwitchResult::Failed&&!core_running);
 assert(!require_logo_cleared&&r.detected_core()==5);
 program_ok=true;reply=1;assert(r.configure_core(5,true)==nanoblast::SwitchResult::Failed&&r.detected_core()==1);
 reply=5;assert(r.configure_core(5,true)==nanoblast::SwitchResult::Loaded&&programmed=="usb:cores/nano20k/smstang.bin");
 assert(persisted==1);
 unsigned old_programs=programs;assert(r.configure_core(5,true)==nanoblast::SwitchResult::Loaded&&programs==old_programs);
 persist_ok=false;assert(r.configure_core(5,true)==nanoblast::SwitchResult::Failed&&std::string(r.switch_error())=="Test flash failed");persist_ok=true;
 assert(imports==0); // Startup and core switching never copy the user game.
 import_ok=false;assert(r.browse_games(5)==nanoblast::BrowseResult::Failed&&imports==1);
 import_ok=true;
 cancel=true;assert(r.browse_games(5)==nanoblast::BrowseResult::Cancelled&&imports==2);
 cancel=false;rom_result=1;assert(r.browse_games(5)==nanoblast::BrowseResult::Failed&&!core_running);
 rom_result=0;assert(r.browse_games(5)==nanoblast::BrowseResult::Loaded&&core_running);
 assert(imports==2); // A verified imported game is not read again this boot.
 unsigned old_staged=staged;built_in=true;
 assert(r.configure_core(5,true)==nanoblast::SwitchResult::Loaded&&asset_saves==1&&asset_activations==0&&staged==old_staged&&!last_verify);
 r.verify_core(false);assert(r.configure_core(5,true)==nanoblast::SwitchResult::Loaded&&!last_verify&&staged==old_staged);
 r.verify_core(true);bridge=false;
 assert(r.configure_core(5,true)==nanoblast::SwitchResult::Loaded&&asset_activations==1&&last_verify&&staged==old_staged);
 TextFrames defaults_frames;Runtime defaults(defaults_frames);
 defaults.remember_core(5);assert(defaults.save_boot_core()&&!last_verify);
 built_in=false;
 assert(reloads==1);bytes.clear();
 TextFrames blank_buffers;Runtime blank(blank_buffers);
 blank.clear();assert(bytes.empty());blank.present();assert(bytes.size()==131*8&&clear_calls==0);
 assert(bytes[128*8-4]==0&&bytes[128*8-3]==31&&bytes[128*8-2]==31&&bytes[128*8-1]==0);
 bytes.clear();
 text_lines.clear();r.status();assert(text_lines.empty());
 r.panel(true,1,13,27,17);
 uint32_t word=0x03000000u|(1u<<20)|(17u<<15)|(13u<<10)|(27u<<5)|1u;
 assert(bytes.size()==8&&bytes[0]==0xaa&&bytes[1]==0&&bytes[2]==5&&bytes[3]==14);
 for(int i=0;i<4;i++)assert(bytes[4+i]==uint8_t(word>>(24-i*8)));
 bytes.clear();r.panel(false,0,0,0,0);
 word=0x03000000u;
 assert(bytes.size()==8);
 for(int i=0;i<4;i++)assert(bytes[4+i]==uint8_t(word>>(24-i*8)));
 r.debug(true);r.remember_core(1);r.status();
 assert(text_lines.size()==13&&text_lines[1]=="Boot flash: SMS DE68D692"&&text_lines[2]=="Core: NES"&&text_lines[5]=="Link: 123 bytes, lost 0");
 bytes.clear();r.panel(false,0,0,0,0);
 word=0x03000000u|(1u<<20)|(13u<<15)|(2u<<10)|(31u<<5)|1u;
 assert(bytes.size()==8);
 for(int i=0;i<4;i++)assert(bytes[4+i]==uint8_t(word>>(24-i*8)));
 bytes.clear();r.panel(true,3,13,28,17);
 word=0x03000000u|(1u<<20)|(17u<<15)|(2u<<10)|(31u<<5)|1u;
 for(int i=0;i<4;i++)assert(bytes[4+i]==uint8_t(word>>(24-i*8)));
 text_lines.clear();r.debug(false);r.clear();r.status();assert(text_lines.empty());r.present();
 r.shortcut(true);assert(option_osd_key==1);
 // Moving selection changes only its rectangle, with no text, full clear,
 // logo writes or diagnostic-panel disable/re-enable sequence.
 TextFrames ui_buffers;Runtime ui(ui_buffers);ui.remember_core(1);nanoblast::Menu menu(ui,1);menu.redraw();
 ui.load_artwork();
 assert(std::string(screen[14],32).find("===")!=std::string::npos);
 menu.redraw();
 assert(std::string(screen[15],32).find("Games")!=std::string::npos);
 assert(std::string(screen[16],32).find("Cores")!=std::string::npos);
 assert(std::string(screen[17],32).find("Settings")!=std::string::npos);
 for(char c:screen[14])assert(c==' ');
 for(char c:screen[27])assert(c==' ');
 auto press=[&](unsigned key){menu.input(key);menu.input(0);};
 bytes.clear();text_lines.clear();press(0x20);
 assert(clear_calls==0&&bytes.size()==8&&text_lines.empty());
 word=0x02100000u|(16u<<15)|(16u<<10)|(28u<<5)|3u;
 for(int i=0;i<4;i++)assert(bytes[4+i]==uint8_t(word>>(24-i*8)));
 for(auto &row:screen)for(char c:row)assert(c!='>');
 for(char c:screen[1])assert(c==' ');
 press(0x20);bytes.clear();text_lines.clear();press(0x20);
 assert(bytes.empty()&&text_lines.empty());
 press(1);assert(menu.page()==nanoblast::Page::Settings&&bytes.size()==8);
 for(unsigned i=0;i<4;i++)press(0x20);press(1);
 assert(menu.page()==nanoblast::Page::Advanced);
 bytes.clear();text_lines.clear();press(0x20);
 assert(bytes.size()==8&&text_lines.empty());
 bytes.clear();text_lines.clear();press(1);assert(bytes.size()==8);
 assert(std::string(screen[3],32).find("Core: NES")!=std::string::npos);
 assert(std::string(screen[16],32).find("[x] Debug mode")!=std::string::npos);
 bytes.clear();press(1);assert(bytes.size()==8&&clear_calls==0);
 for(unsigned y=3;y<=12;y++)for(char c:screen[y])assert(c==' ');
 assert(std::string(screen[16],32).find("[ ] Debug mode")!=std::string::npos);
 // A browser overwrites the overlay independently: returning must repaint it.
 reply=1;cancel=true;assert(ui.browse_games(1)==nanoblast::BrowseResult::Cancelled);
 std::memset(screen,'?',sizeof screen);text_lines.clear();menu.redraw();
 assert(text_lines.size()==28&&clear_calls==0);
 for(char c:screen[1])assert(c==' ');
 // Exercise the exact reported recovery through the real runtime AND menu:
 // Debug knows NES, failed SMS must not leave Menu at core0 or block Games.
 TextFrames rescue_buffers;Runtime rescue(rescue_buffers);rescue.remember_core(1);
 nanoblast::Menu rescue_menu(rescue,1);rescue_menu.redraw();
 auto rescue_press=[&](unsigned key){rescue_menu.input(key);rescue_menu.input(0);};
 reply=1;program_ok=false;cancel=true;
 rescue_press(0x20);rescue_press(1);rescue_press(0x20);rescue_press(0x20);rescue_press(1);
 assert(rescue_menu.active_core()==1&&rescue.detected_core()==1);
 assert(std::string(screen[20],32).find("NES core running")!=std::string::npos);
 assert(std::string(screen[23],32).find("Test programming failed")!=std::string::npos);
 rescue_press(0x40);rescue_press(1);
 assert(std::string(screen[23],32).find("Choose a core first")==std::string::npos);
 program_ok=true;
 // Flash saving is an action, never a mode that changes ordinary selections.
 TextFrames save_frames;Runtime saving(save_frames);saving.remember_core(1);
 built_in=true;bridge=true;reply=1;unsigned saves_before=asset_saves;
 assert(saving.save_boot_core()&&asset_saves==saves_before+1&&reply==1);
 reply=5;assert(saving.switch_core(5)==nanoblast::SwitchResult::Loaded&&asset_saves==saves_before+1);
 assert(saving.save_boot_core()&&asset_saves==saves_before+2);
 persist_ok=false;assert(!saving.save_boot_core());
 assert(std::string(saving.switch_error())=="Test flash failed");persist_ok=true;
 unsigned no_reply_saves=asset_saves;reply=1;
 assert(!saving.save_boot_core()&&asset_saves==no_reply_saves&&std::string(saving.switch_error())=="Active core did not reply");
 TextFrames missing_frames;Runtime missing(missing_frames);assert(!missing.save_boot_core());
 built_in=false;
 // Cold startup with either retained core draws Games before artwork, never
 // programs or provisions any core. Stop at first controller poll.
 for(int active:{1,5}){
  reply=active;unsigned old_programs=programs,old_persisted=persisted,old_staged=staged;
  loop_test=true;try{nanoblast_menu_loop();assert(false);}catch(int){}loop_test=false;
  assert(programs==old_programs&&persisted==old_persisted&&staged==old_staged&&prepared_cores==0&&background_preparations==0);
  assert(std::string(screen[15],32).find("Games")!=std::string::npos);
  for(char c:screen[14])assert(c==' ');
  for(char c:screen[27])assert(c==' ');
 }
 // A previously saved power-on core is never reflashed/reloaded at startup.
 for(unsigned boot_core:{1u,5u}){
  built_in=true;reply=boot_core;
  unsigned old_saves=asset_saves,old_activations=asset_activations,old_staged=staged,old_reloads=reloads;
  loop_test=true;try{nanoblast_menu_loop();assert(false);}catch(int){}loop_test=false;
  assert(reply==int(boot_core)&&asset_saves==old_saves&&asset_activations==old_activations&&staged==old_staged&&reloads==old_reloads);
  assert(std::string(screen[15],32).find("Games")!=std::string::npos);
 }
 TextFrames oled_frames;Runtime oled_runtime(oled_frames);
 unsigned before_oled=oled_changes;
 oled_runtime.oled(true);assert(oled_mode&&oled_changes==before_oled+1);
 oled_runtime.oled(true);assert(oled_changes==before_oled+1);
 oled_runtime.oled(false);assert(!oled_mode&&oled_changes==before_oled+2);
 return 0;
}
