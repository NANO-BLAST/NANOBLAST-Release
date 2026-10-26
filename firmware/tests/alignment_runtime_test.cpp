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

uint32_t last_layout(){
 uint32_t found=0;for(unsigned i=0;i+7<bytes.size();++i)if(bytes[i]==0xaa&&bytes[i+1]==0&&bytes[i+2]==5&&bytes[i+3]==14&&bytes[i+4]==4)
 found=(uint32_t(bytes[i+4])<<24)|(uint32_t(bytes[i+5])<<16)|(uint32_t(bytes[i+6])<<8)|bytes[i+7];
 return found;
}
int main(){
 TextFrames frames;Runtime r(frames);
 r.clear();r.half_cell_row(19);r.present();assert(last_layout()==(0x04600000u|(22u<<15)|(19u<<10)));
 bytes.clear();r.clear();r.half_cell_row(19);r.present();assert(bytes.empty());
 r.clear();r.half_cell_row(-1);r.present();assert(bytes.size()==8&&last_layout()==(0x04200000u|(22u<<15)|(15u<<10)));
 bytes.clear();r.clear();r.half_cell_row(19);r.present();assert(bytes.size()==8&&last_layout()==(0x04600000u|(22u<<15)|(19u<<10)));
 bytes.clear();r.debug(true);r.clear();r.status();r.present();assert(last_layout()&(1u<<23));
 bytes.clear();r.clear();r.status();r.present();assert(bytes.empty());
 bytes.clear();r.clear();r.present();assert(!(last_layout()&(1u<<23)));
 bytes.clear();r.debug(false);r.clear();r.status();r.present();assert(bytes.empty());
 return 0;
}
