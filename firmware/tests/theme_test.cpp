// Layout checks for actual Horizon menu frames; no hardware or mock artwork.
#include "nanoblast_menu.h"
#include <cassert>
#include <cstring>
#include <string>
#include <algorithm>
using namespace nanoblast;
struct View:Platform{
 char grid[28][32];unsigned row=0,switches=0;bool theme=false,game=false,shown=true;
 void clear()override{std::memset(grid,' ',sizeof grid);}
 void menu_theme(bool on)override{theme=on;}
 void text(unsigned x,unsigned y,const char*s)override{assert(y<28&&x<32&&std::strlen(s)<=32-x);std::memcpy(grid[y]+x,s,std::strlen(s));}
 void panel(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{assert(on&&l==1&&t==15&&r==31&&b==26);}
 void half_cell_row(int value)override{assert(value==-1||value==20);}
 void selection(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{if(on){assert(l==1&&r==31&&t==b&&t>=17&&t<=24);row=t;}}
 void present()override{assert(theme);assert(has(15,"MAIN MENU")||has(15,"CHOOSE CORE")||has(15,"SETTINGS")||has(15,"SET CLOCK")||has(15,"ADVANCED")||has(15,"USB ROM TRANSFER"));}
 void overlay(bool on)override{shown=on;}
 bool available(unsigned)override{return true;}
 SwitchResult switch_core(unsigned)override{++switches;return SwitchResult::Loaded;}
 BrowseResult browse_games(unsigned)override{return game?BrowseResult::Loaded:BrowseResult::Cancelled;}
 void shortcut(bool)override{}
 bool has(unsigned y,const char*s)const{std::string value;for(char c:grid[y])if(c!=' '||(!value.empty()&&value.back()!=' '))value+=c;return value.find(s)!=std::string::npos;}
};
void press(Menu&m,unsigned k){m.input(k);m.input(0);}
void down(Menu&m,unsigned n){while(n--)press(m,0x20);}
int main(){
 View v;Menu m(v,1);m.redraw();assert(v.row==19&&v.has(19,"PLAY GAMES")&&v.has(21,"CHOOSE CORE")&&v.has(23,"SETTINGS"));
 for(unsigned y=24;y<26;y++)assert(std::string(v.grid[y],32)==std::string(32,' '));
 assert(v.has(26,"A Select")&&v.has(26,"B Back"));
 down(m,1);press(m,0x100);assert(v.row==18&&v.has(22,"GAME BOY / COLOUR")&&!v.has(23,"SNES"));
 down(m,2);press(m,0x100);assert(m.active_core()==7&&v.switches==1&&m.page()==Page::Home);
 down(m,2);press(m,0x100);assert(m.page()==Page::Settings&&v.has(18,"Region: fixed (Game Boy)"));
 down(m,3);press(m,0x100);assert(m.page()==Page::Clock&&v.has(17,"Year:")&&v.has(22,"Set clock"));
 press(m,1);down(m,1);press(m,0x100);assert(m.page()==Page::Advanced&&v.has(21,"USB ROM transfer"));
 down(m,2);press(m,0x100);press(m,1);press(m,1);press(m,0x10);press(m,0x100);
 assert(m.page()==Page::Cores&&v.has(23,"SNES (EXPERIMENTAL)"));
 draw_usb_transfer_screen(v);assert(v.has(20,"READY TO CONNECT")&&std::string(v.grid[26],32)==std::string(32,' '));
}
