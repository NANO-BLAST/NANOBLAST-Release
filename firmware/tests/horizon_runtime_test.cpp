#define main legacy_gb_main
#include "gb_runtime_test.cpp"
#undef main
#include "../ui/menu_theme.h"
std::map<unsigned,uint32_t> palette(){
 std::map<unsigned,uint32_t> p;
 for(unsigned i=0;i+7<bytes.size();i++)if(bytes[i]==0xaa&&bytes[i+1]==0&&bytes[i+2]==5&&bytes[i+3]==18)
  p[bytes[i+4]]=(uint32_t(bytes[i+5])<<16)|(uint32_t(bytes[i+6])<<8)|bytes[i+7];
 return p;
}
uint32_t last_command(unsigned command){
 uint32_t word=0;
 for(unsigned i=0;i+7<bytes.size();i++)if(bytes[i]==0xaa&&bytes[i+3]==14&&(bytes[i+4]&3)==command)
  word=(uint32_t(bytes[i+4])<<24)|(uint32_t(bytes[i+5])<<16)|(uint32_t(bytes[i+6])<<8)|bytes[i+7];
 return word;
}
int main(){
 using namespace nanoblast::horizon;
 TextFrames frames;Runtime r(frames);r.menu_theme(true);r.clear();r.panel(true,1,15,31,25);r.selection(true,1,17,31,17);r.present();
 auto p=palette();assert(p.size()==11&&p[224]==Blue&&p[226]==Red&&p[227]==Navy);
 assert(!host_helpers_visible&&host_helpers_calls==1);
 assert(!(last_command(2)&(1u<<20))&&!(last_command(3)&(1u<<20)));
 bytes.clear();r.selection(true,1,19,31,19);p=palette();
 assert(p.size()==2&&p[226]==Navy&&p[228]==Red);
 bytes.clear();r.selection(true,1,19,31,19);assert(palette().empty());
 r.external_screen_changed();r.selection(true,1,19,31,19);assert(palette().size()==11);
 bytes.clear();r.clear();r.button_helpers();r.present();p=palette();
 assert(host_helpers_visible);
 assert(std::string(screen[27]+14,6)=="Select"&&std::string(screen[27]+24,4)=="Back"&&screen[27][12]==' '&&screen[27][22]==' ');
 bytes.clear();r.clear();r.present();p=palette();
 assert(p.empty()&&!host_helpers_visible);
 assert(std::string(screen[27],32)==std::string(32,' '));
 // Failed tile transfers remain pending and retry, without hiding an error.
 host_helpers_ok=false;unsigned calls=host_helpers_calls;r.clear();r.button_helpers();r.present();
 r.clear();r.button_helpers();r.present();assert(host_helpers_calls==calls+2);
 assert(std::string(screen[27]+12,8)=="A Select"&&std::string(screen[27]+22,6)=="B Back"&&std::string(screen[27],6)=="SEL+ST");
 host_helpers_ok=true;r.clear();r.button_helpers();r.present();calls=host_helpers_calls;
 r.clear();r.button_helpers();r.present();assert(host_helpers_calls==calls);
 assert(screen[27][12]==' '&&screen[27][22]==' ');
 // OLED and failed-artwork paths retain the independent hardware selection.
 r.oled(true);r.menu_theme(true);bytes.clear();r.clear();r.panel(true,1,15,31,25);r.selection(true,1,19,31,19);r.button_helpers();r.present();
 assert(std::string(screen[27]+8,8)=="A Select"&&std::string(screen[27]+18,6)=="B Back");
 assert(palette().empty()&&(last_command(2)&(1u<<20))&&(last_command(3)&(1u<<20)));
 host_background_ready=false;TextFrames fallback_frames;Runtime fallback(fallback_frames);fallback.menu_theme(true);bytes.clear();fallback.clear();fallback.panel(true,1,15,31,25);fallback.selection(true,1,16,31,16);fallback.present();
 assert(palette().empty()&&(last_command(2)&(1u<<20))&&(last_command(3)&(1u<<20)));
 host_background_ready=true;
 // Startup clears loading/UI text and proceeds immediately to the menu.
 // Match the loader's hardware state before testing the reveal.
 r.panel(false,0,0,0,0);r.selection(false,0,0,0,0);
 const auto helper_calls=host_helpers_calls;const auto before=ticks;r.show_startup_artwork();assert(ticks==before&&host_helpers_calls==helper_calls);
 for(unsigned y=0;y<28;y++)assert(std::string(screen[y],32)==std::string(32,' '));
 assert(!(last_command(2)&(1u<<20))&&!(last_command(3)&(1u<<20)));
 host_background_ready=false;const auto missing=ticks;r.show_startup_artwork();assert(ticks==missing);
 host_background_ready=true;
 // Run the actual cold-start loop through artwork loading and the first menu.
 for(int core:{1,5,7,2}){
  reply=core;loop_test=true;const auto started=ticks;
  try{nanoblast_menu_loop();assert(false);}catch(int stop){assert(stop==1);}
  loop_test=false;assert(ticks==started);
  assert(std::string(screen[15],32).find("MAIN MENU")!=std::string::npos);
  assert(std::string(screen[27],32).find("LOADING")==std::string::npos);
 }
 host_background_ready=false;reply=1;loop_test=true;const auto failed_start=ticks;
 try{nanoblast_menu_loop();assert(false);}catch(int stop){assert(stop==1);}
 loop_test=false;assert(ticks==failed_start);host_background_ready=true;
}
