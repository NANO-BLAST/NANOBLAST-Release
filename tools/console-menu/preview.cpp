// Host preview: production Menu + FileChooser, with simulated files and services.
#include "../../firmware/ui/nanoblast_menu.h"
#define NANOBLAST_BROWSER_HOST_TEST
#include "../../firmware/ui/file_chooser.cpp"
#include <iostream>
#include <cstring>
#include <sstream>
using namespace nanoblast;
namespace {struct FrameReady{};std::vector<uint16_t> keys;unsigned at=0;uint16_t current=0;bool seed=false;std::string last_game;bool transfer=false,oled=false;}
FRESULT f_opendir(DIR*d,const char*p){d->path=p;d->index=0;return FR_OK;}
FRESULT f_readdir(DIR*d,FILINFO*f){
 static const char*names[]={"Adventure Island.zip","Blazing Star (USA).zip","Castle Quest.zip","Dragon Valley.zip","Game Collection","Horizon Runner.zip","Moon Patrol.zip","Pixel Knights.zip","River Rescue.zip","Sky Riders.zip","Space Explorer.zip","Tiny World.zip"};
 if(d->index>=12){f->fname[0]=0;return FR_OK;}
 auto i=d->index++;std::strcpy(f->fname,names[i]);f->fattrib=i==4?AM_DIR:0;return FR_OK;
}
FRESULT f_closedir(DIR*){return FR_OK;}
void overlay_clear(){}void overlay_status(const char*,...){}void overlay_printf(const char*,...){}void overlay_cursor(int,int){}void delay(int){}
int joy_choice(int,int,int*,int,bool){return 0;}
void get_joypad_states(uint16_t*a,uint16_t*b,uint16_t*c,uint16_t*d){
 if(seed)seed=false;
 else{if(at==keys.size())throw FrameReady{};current=keys[at++];}
 *a=current;*b=*c=*d=0;
}
struct View:Platform{
 char grid[28][33]{};unsigned selected=16;int half_row=-1;bool highlight=true,shown=true,theme=true,helpers=false;
 void clear()override{helpers=false;for(auto&r:grid){std::memset(r,' ',32);r[32]=0;}}
 void menu_theme(bool on)override{theme=on&&!::oled;}
 void text(unsigned x,unsigned y,const char*s)override{if(y<28&&x<32)std::memcpy(grid[y]+x,s,std::min<size_t>(32-x,std::strlen(s)));}
 void button_helpers()override{helpers=true;if(theme){text(10,27,"Select");text(20,27,"Back");}else Platform::button_helpers();}
 void panel(bool,unsigned,unsigned,unsigned,unsigned)override{}
 void half_cell_row(int row)override{half_row=row;}
 void selection(bool on,unsigned,unsigned top,unsigned,unsigned)override{highlight=on;selected=top;}
 void overlay(bool on)override{shown=on;}
 bool available(unsigned)override{return true;}
 SwitchResult switch_core(unsigned)override{return SwitchResult::Loaded;}
 BrowseResult browse_games(unsigned core)override{
  FileChooser browser;browser.rootdir=browser.curdir=core==1?"sd:/nes":core==5?"sd:/sms":core==7?"sd:/gb":"sd:/snes";browser.menu_platform=this;seed=true;
  if(!browser.choose_file(last_game))return BrowseResult::Cancelled;
  return BrowseResult::Loaded;
 }
 void shortcut(bool)override{}
 void oled(bool on)override{::oled=on;}
 bool usb_transfer()override{draw_usb_transfer_screen(*this);transfer=true;return true;}
 bool save_boot_core()override{return true;}
 unsigned detected_core()const override{return 1;}
 ClockDate clock_get()override{ClockDate d;d.year=2026;d.month=10;d.day=31;d.hour=12;return d;}
 bool clock_set(const ClockDate&)override{return true;}
};
std::string json(const char*s){std::string out="\"";for(;*s;s++){if(*s=='"'||*s=='\\')out+='\\';out+=*s;}return out+'"';}
int main(int argc,char**argv){
 for(int i=1;i<argc;i++)keys.push_back(static_cast<uint16_t>(std::stoul(argv[i])));
 View view;view.clear();Menu menu(view,1);menu.redraw();
 try{while(at<keys.size()&&!transfer){current=keys[at++];menu.input(current);}}catch(const FrameReady&){}
 std::cout<<"{\"rows\":[";for(unsigned y=0;y<28;y++){if(y)std::cout<<',';std::cout<<json(view.grid[y]);}
 std::cout<<"],\"half_row\":"<<view.half_row<<",\"selected\":"<<view.selected<<",\"helpers\":"<<view.helpers<<",\"highlight\":"<<view.highlight<<",\"visible\":"<<view.shown<<",\"theme\":"<<view.theme<<",\"transfer\":"<<transfer<<",\"game\":"<<json(last_game.c_str())<<"}";
}
