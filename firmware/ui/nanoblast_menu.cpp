// NANOBLAST BL616 menu controller. GPL-3.0; see COPYING.NANOBLAST.
#include "nanoblast_menu.h"
#include <cstring>
#include <cstdio>
namespace nanoblast {
namespace {
constexpr unsigned cores[]={1,5,7,2};
const char *running_labels[]={"NES core running","SMS/GG core running","GB core running","SNES core running"};
const char *unavailable_labels[]={"NES core unavailable","SMS/GG core unavailable","GB core unavailable","SNES core unavailable"};
unsigned region_index(unsigned core){return core==2?2:core==5?1:0;}
void centered(Platform&p,unsigned row,const char*s){
 unsigned n=static_cast<unsigned>(std::strlen(s));p.text(n<31?1+(31-n)/2:1,row,s);
}
}
Menu::Menu(Platform&p,unsigned core):p_(p),core_(core){p_.verify_core(false);}
unsigned Menu::count()const{
 if(page_==Page::Home)return running_?4:3;
 if(page_==Page::Settings)return 5;
 if(page_==Page::Clock)return 6;
 if(page_==Page::Advanced)return 4;
 return experimental_?4:3;
}
void Menu::show(){visible_=true;page_=Page::Home;choice_=0;message_="";p_.overlay(true);redraw();}
void Menu::redraw(){
 p_.debug(debug_);p_.clear();p_.large_text(false);if(debug_)p_.status();
 fixed_menu_panel(p_);
 const unsigned first=page_==Page::Home?14+(10-count())/2:15;
 p_.half_cell_row(page_==Page::Home?static_cast<int>(first+2):-1);
 if(page_==Page::Home){
  centered(p_,first,"Games");centered(p_,first+1,"Cores");centered(p_,first+2,"Settings");
  if(running_)centered(p_,first+3,"Resume game");
 }else if(page_==Page::Cores){
  const char *names[]={"Nintendo NES / Famicom","Sega Master System / Game Gear","Game Boy / Game Boy Colour","SNES (experimental)"};
  for(unsigned i=0;i<count();i++)centered(p_,first+i,names[i]);
  if(!*message_){unsigned id=cores[choice_];centered(p_,23,id==core_?running_labels[choice_]:p_.available(id)?"Core ready to load":unavailable_labels[choice_]);}
 }else if(page_==Page::Settings){
  centered(p_,first,select_start_?"Menu: SELECT + START":"Menu: SELECT + RIGHT");
  centered(p_,first+1,core_==0?"Region: choose a core":core_==7?"Region: fixed (Game Boy)":pal_[region_index(core_)]?"Region: PAL":"Region: NTSC");
  centered(p_,first+2,"Core boot flash");centered(p_,first+3,"Clock");centered(p_,first+4,"Advanced");
 }else if(page_==Page::Clock){
  char line[32];const char *names[]={"Year","Month","Day","Hour","Minute"};
  const unsigned values[]={clock_draft_.year,clock_draft_.month,clock_draft_.day,clock_draft_.hour,clock_draft_.minute};
  for(unsigned i=0;i<5;i++){std::snprintf(line,sizeof line,"%s: %s%02u%s",names[i],clock_editing_&&choice_==i?"[":"",values[i],clock_editing_&&choice_==i?"]":"");centered(p_,first+i,line);}
  centered(p_,first+5,"Set clock");
 }else{
  centered(p_,first,debug_?"[x] Debug mode":"[ ] Debug mode");
  centered(p_,first+1,verify_core_?"[x] Verify core":"[ ] Verify core");
  centered(p_,first+3,oled_?"[x] OLED Mode (Beta)":"[ ] OLED Mode (Beta)");
  centered(p_,first+2,experimental_?"[x] Experimental cores":"[ ] Experimental cores");
 }
 p_.selection(true,1,first+choice_,31,first+choice_);
 p_.text(1,27,clock_editing_?"Up/Down Adjust A/B Done":"Up/Down Move  A Select  B Back");
 if(*message_)centered(p_,23,message_);p_.present();
}
void Menu::select(){
 message_="";
 if(page_==Page::Home){
  if(choice_==0){
   if(!core_)message_="Choose a core first";
   else{
    p_.region(core_,pal_[region_index(core_)]);
    auto result=p_.browse_games(core_);
    // The browser returns immediately on B. Ignore that already-held press
    // when control returns to the home menu, without blocking other buttons.
    previous_=0xffff;
    if(result==BrowseResult::Loaded){running_=true;visible_=false;p_.overlay(false);return;}
    if(result==BrowseResult::Failed){running_=false;message_="Unable to open/load game";}
   }
  }else if(choice_==1){page_=Page::Cores;choice_=0;}
  else if(choice_==2){page_=Page::Settings;choice_=0;}
  else if(running_){visible_=false;p_.overlay(false);return;}
 }else if(page_==Page::Settings){
  if(choice_==0){select_start_=!select_start_;p_.shortcut(select_start_);}
  else if(choice_==1&&(core_==1||core_==5||core_==2)){
   bool&pal=pal_[region_index(core_)];pal=!pal;p_.region(core_,pal);message_="Applies to next game load";
  }else if(choice_==2){
   if(!core_)message_="Choose a core first";
   else{
    centered(p_,23,"Saving core...");p_.present();const bool saved=p_.save_boot_core();
    core_=p_.detected_core();running_=false;message_=saved?"Core saved to boot flash":p_.switch_error();
   }
  }else if(choice_==3){page_=Page::Clock;choice_=0;clock_draft_=p_.clock_get();clock_draft_.second=0;}
  else if(choice_==4){page_=Page::Advanced;choice_=0;}
 }else if(page_==Page::Clock){
  if(choice_<5)clock_editing_=!clock_editing_;
  else message_=p_.clock_set(clock_draft_)?"Clock saved":"Clock save failed";
 }else if(page_==Page::Advanced){
  if(choice_==0)debug_=!debug_;
  else if(choice_==1){verify_core_=!verify_core_;p_.verify_core(verify_core_);message_=verify_core_?"Core readback enabled":"Core readback disabled";}
  else if(choice_==2)experimental_=!experimental_;
  else if(choice_==3){oled_=!oled_;p_.oled(oled_);}
 }else{
  unsigned selected=cores[choice_];
  if(selected==core_){page_=Page::Home;choice_=0;}
  else if(!p_.available(selected))message_="Core image not installed";
  else{
   p_.text(1,23,"                               ");centered(p_,25,"Loading core...");p_.present();
   switch(p_.switch_core(selected)){
   case SwitchResult::Loaded:p_.region(selected,pal_[region_index(selected)]);core_=selected;running_=false;page_=Page::Home;choice_=0;break;
   case SwitchResult::Unavailable:message_="Core image not installed";break;
   case SwitchResult::Failed:core_=p_.detected_core();running_=false;message_=p_.switch_error();break;
   }
  }
 }
 redraw();
}
void Menu::adjust_clock(int direction){
 unsigned *fields[]={&clock_draft_.year,&clock_draft_.month,&clock_draft_.day,&clock_draft_.hour,&clock_draft_.minute};
 const unsigned lo[]={2000,1,1,0,0},hi[]={2099,12,31,23,59};
 unsigned &v=*fields[choice_];v=direction>0?(v>=hi[choice_]?lo[choice_]:v+1):(v<=lo[choice_]?hi[choice_]:v-1);
 // Calendar fields stay valid when changing month/year, including leap day.
 unsigned month_days[]={31,28,31,30,31,30,31,31,30,31,30,31};
 if(clock_draft_.year%4==0)month_days[1]=29;
 unsigned limit=month_days[clock_draft_.month-1];if(clock_draft_.day>limit)clock_draft_.day=choice_==2&&direction>0?1:limit;
}
void Menu::input(uint16_t buttons){
 uint16_t pressed=buttons&~previous_;previous_=buttons;
 const uint16_t shortcut=select_start_?0x0c:0x84;
 if(buttons==shortcut){if(pressed&&!visible_)show();return;}
 if(!visible_)return;
 if(page_==Page::Clock&&clock_editing_){
  if(pressed&0x001){clock_editing_=false;message_="Edit ended; Set clock to save";redraw();}
  else if(pressed&0x10){adjust_clock(1);redraw();}
  else if(pressed&0x20){adjust_clock(-1);redraw();}
  else if(pressed&0x100){clock_editing_=false;redraw();}
  return;
 }
 if(pressed&0x001){
  if(page_==Page::Home){if(running_){visible_=false;p_.overlay(false);}return;}
  if(page_==Page::Advanced||page_==Page::Clock){choice_=page_==Page::Clock?3:4;page_=Page::Settings;}
  else{choice_=page_==Page::Cores?1:2;page_=Page::Home;}
  message_="";redraw();return;
 }
 if(pressed&0x10){if(choice_)--choice_;redraw();}
 else if(pressed&0x20){if(choice_+1<count())++choice_;redraw();}
 else if(pressed&0x100)select();
}
}
