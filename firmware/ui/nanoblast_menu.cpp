// NANOBLAST BL616 menu controller. GPL-3.0; see COPYING.NANOBLAST.
#include "nanoblast_menu.h"
#include "menu_theme.h"
#include <cstring>
#include <cstdio>
namespace nanoblast {
namespace {
constexpr unsigned cores[]={1,5,7,2};
unsigned region_index(unsigned core){return core==2?2:core==5?1:0;}
void centered(Platform&p,unsigned row,const char*s){
 unsigned n=static_cast<unsigned>(std::strlen(s));
 // Keep the label's word spacing intact; centre on the character grid.
 // Single odd-width words can use the existing half-cell renderer shift.
 if((n&1)&&n<32&&!std::strchr(s,' '))p.half_cell_row(static_cast<int>(row));
 p.text(n<32?(32-n)/2:0,row,s);
}
}
void draw_usb_transfer_screen(Platform &p){
 p.menu_theme(true);p.clear();p.large_text(false);p.half_cell_row(-1);
 fixed_menu_panel(p);p.selection(false,0,0,0,0);
 centered(p,15,"USB ROM TRANSFER");centered(p,20,"READY TO CONNECT");p.present();
}
Menu::Menu(Platform&p,unsigned core):p_(p),core_(core){p_.verify_core(false);}
unsigned Menu::count()const{
 if(page_==Page::Home)return running_?4:3;
 if(page_==Page::Settings)return 5;
 if(page_==Page::Clock)return 6;
 if(page_==Page::Advanced)return 5;
 return experimental_?4:3;
}
void Menu::show(){visible_=true;page_=Page::Home;choice_=0;message_="";p_.overlay(true);redraw();}
void Menu::redraw(){
 p_.menu_theme(true);p_.debug(debug_);p_.clear();p_.large_text(false);if(debug_)p_.status();
 fixed_menu_panel(p_);
 const bool spaced=page_==Page::Home||page_==Page::Cores;
 const unsigned first=page_==Page::Home?(count()==3?19:18):spaced&&count()==3?18:horizon::FirstChoice;
 p_.half_cell_row(-1);
 centered(p_,15,page_==Page::Home?"MAIN MENU":page_==Page::Cores?"CHOOSE CORE":page_==Page::Settings?"SETTINGS":page_==Page::Clock?"SET CLOCK":"ADVANCED");
 if(page_==Page::Home){
  centered(p_,first,"PLAY GAMES");centered(p_,first+2,"CHOOSE CORE");centered(p_,first+4,"SETTINGS");
  if(running_)centered(p_,first+6,"RESUME GAME");
 }else if(page_==Page::Cores){
  const char *names[]={"NES / FAMICOM","MASTER SYSTEM / GAME GEAR","GAME BOY / COLOUR","SNES (EXPERIMENTAL)"};
  for(unsigned i=0;i<count();i++)centered(p_,first+2*i,names[i]);
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
  centered(p_,first+4,"USB ROM transfer");
  centered(p_,first+2,experimental_?"[x] Experimental cores":"[ ] Experimental cores");
 }
 p_.selection(true,1,first+choice_*(spaced?2:1),31,first+choice_*(spaced?2:1));
 p_.button_helpers();
 if(*message_)centered(p_,25,message_);p_.present();
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
    centered(p_,25,"Saving core...");p_.present();const bool saved=p_.save_boot_core();
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
  else if(choice_==4){request_usb_transfer();return;}
 }else{
  unsigned selected=cores[choice_];
  if(selected==core_){page_=Page::Home;choice_=0;}
  else if(!p_.available(selected))message_="Core image not installed";
  else{
   p_.text(1,25,"                               ");centered(p_,25,"Loading core...");p_.present();
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
void Menu::request_usb_transfer(){
 // Match the Advanced-menu action: a running game must never share SD access
 // with the transfer service. Runtime also flushes saves/checkpoints the clock.
 if(running_){
  if(!visible_)show();
  message_="Restart before USB transfer";redraw();
 }else if(!p_.usb_transfer()){
  message_="USB transfer unavailable";redraw();
 }
}
void Menu::input(uint16_t buttons){input(buttons,0,0,0);}
void Menu::input(uint16_t joy1,uint16_t joy2,uint16_t hid1,uint16_t hid2){
 // Select is bit 2, L is bit 10 in the common SNES controller format.
 // Check each pad before merging normal navigation, never across two pads.
 constexpr uint16_t transfer_keys=0x0404;
 const bool transfer=joy1==transfer_keys||joy2==transfer_keys||hid1==transfer_keys||hid2==transfer_keys;
 const bool transfer_pressed=transfer&&!usb_shortcut_held_;
 usb_shortcut_held_=transfer;
 const uint16_t buttons=joy1|joy2|hid1|hid2;
 uint16_t pressed=buttons&~previous_;previous_=buttons;
 if(transfer){if(transfer_pressed)request_usb_transfer();return;}
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
