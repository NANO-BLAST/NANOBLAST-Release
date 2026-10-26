#include "nanoblast_menu.h"
#include <cassert>
#include <cstring>
#include <string>
#include <fstream>
#include <algorithm>
using namespace nanoblast;
struct View:Platform{
 int offset_row=-1;
 void half_cell_row(int row)override{offset_row=row;}
 char grid[28][32];unsigned row=0,switches=0,saves=0,browses=0;bool oled_on=false,overlay_on=true,game=false,debug_on=false,verification=true;
 void clear()override{std::memset(grid,' ',sizeof grid);}
 void text(unsigned x,unsigned y,const char*s)override{
  const unsigned n=std::strlen(s);
  if(y>=14&&y<24)assert(x==(n<31?1+(31-n)/2:1));
  assert(std::string(s)!="Back");
  if(y<28&&x<32)std::memcpy(grid[y]+x,s,std::min<unsigned>(32-x,n));
 }
 void panel(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{assert(on&&l==1&&t==14&&r==31&&b==23);}
 void black_panel(unsigned,unsigned,unsigned,unsigned)override{assert(false);}
 void selection(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{assert(on&&l==1&&r==31&&t==b&&t>=15&&t<=22);row=t;}
 void present()override{for(unsigned y=24;y<27;y++)if(!(y==25&&has(25,"Loading core...")))assert(std::string(grid[y],32)==std::string(32,' '));assert(has(27,"Up/Down Move  A Select  B Back"));assert(std::string(grid[14],32)==std::string(32,' '));}
 void overlay(bool on)override{overlay_on=on;}
 bool available(unsigned)override{return true;}
 SwitchResult switch_core(unsigned)override{switches++;return SwitchResult::Loaded;}
 BrowseResult browse_games(unsigned)override{browses++;return game?BrowseResult::Loaded:BrowseResult::Cancelled;}
 void shortcut(bool)override{}
 void oled(bool on)override{oled_on=on;}
 void debug(bool on)override{debug_on=on;}
 void verify_core(bool on)override{verification=on;}
 void status()override{text(0,13,"diagnostics");}
 bool save_boot_core()override{saves++;return true;}
 unsigned detected_core()const override{return 1;}
 bool has(unsigned y,const char*s){const unsigned n=std::strlen(s);return std::string(grid[y]+(n<31?1+(31-n)/2:1),n)==s;}
 void dump(const char*p){std::ofstream f(p,std::ios::binary);f.write(&grid[0][0],sizeof grid);}
};
void press(Menu&m,unsigned k){m.input(k);m.input(0);}
void down(Menu&m,unsigned n){while(n--)press(m,0x20);}
int main(int argc,char**argv){
 // Every core uses the same menu renderer and controller actions.
 View base;Menu base_menu(base,1);base_menu.redraw();
 for(unsigned core:{5u,7u,2u}){
  View shared;Menu menu(shared,core);menu.redraw();
  assert(std::memcmp(base.grid,shared.grid,sizeof base.grid)==0);
  press(menu,0x80);assert(shared.browses==0&&menu.page()==Page::Home);
  down(menu,1);press(menu,0x100);assert(menu.page()==Page::Cores);
  press(menu,1);assert(menu.page()==Page::Home);
 }
 // B returning from Games must not immediately close the home menu too.
 View returning;Menu returned(returning,7);returning.game=true;
 press(returned,0x100);press(returned,0x84);assert(returned.visible()&&returned.running());
 returning.game=false;returned.input(0x100);returned.input(1);
 assert(returned.visible()&&returned.page()==Page::Home);
 returned.input(0);returned.input(1);assert(!returned.visible());
 // Game Boy is reachable with experimental cores off; SNES stays hidden.
 View regular;Menu promoted(regular,1);down(promoted,1);press(promoted,0x100);
 assert(regular.has(15,"Nintendo NES / Famicom")&&regular.has(16,"Sega Master System / Game Gear")&&regular.has(17,"Game Boy / Game Boy Colour"));
 assert(!regular.has(18,"SNES (experimental)"));down(promoted,3);assert(regular.row==17);
 press(promoted,0x100);assert(promoted.active_core()==7&&regular.switches==1&&promoted.page()==Page::Home);
 View v;Menu m(v,1);m.redraw();assert(v.has(17,"Games")&&v.has(18,"Cores")&&v.has(19,"Settings")&&!v.verification&&v.offset_row==19);
 if(argc>1)v.dump(argv[1]);
 press(m,1);press(m,0x101);assert(v.browses==0&&m.page()==Page::Home); // B never selects, even with A.
 down(m,2);press(m,0x100);assert(m.page()==Page::Settings&&v.row==15&&v.has(15,"Menu: SELECT + RIGHT")&&!v.has(19,"[ ] OLED Mode (Beta)"));
 if(argc>2)v.dump(argv[2]);
 press(m,1);assert(m.page()==Page::Home&&v.row==19);press(m,0x100);
 down(m,4);press(m,0x100);down(m,3);press(m,0x100);assert(v.oled_on&&v.row==18&&v.has(18,"[x] OLED Mode (Beta)"));
 press(m,0x10);press(m,0x10);press(m,0x10);assert(m.page()==Page::Advanced&&v.row==15&&v.has(15,"[ ] Debug mode"));
 press(m,0x100);assert(v.debug_on&&v.has(15,"[x] Debug mode"));
 down(m,1);press(m,0x100);assert(v.verification&&v.has(16,"[x] Verify core"));
 down(m,1);press(m,0x100);assert(v.has(17,"[x] Experimental cores"));
 press(m,1);assert(m.page()==Page::Settings&&v.row==19);press(m,1);assert(m.page()==Page::Home&&v.row==19);
 press(m,0x10);press(m,0x100);assert(m.page()==Page::Cores&&v.row==15&&v.has(15,"Nintendo NES / Famicom")&&v.has(17,"Game Boy / Game Boy Colour")&&v.has(18,"SNES (experimental)"));
 press(m,1);assert(m.page()==Page::Home&&v.row==18);press(m,0x100);down(m,1);press(m,0x100);
 assert(m.active_core()==5&&v.switches==1&&m.page()==Page::Home);
 v.game=true;press(m,0x100);assert(m.running()&&!m.visible()&&!v.overlay_on);
 press(m,0x84);assert(m.visible()&&v.has(20,"Resume game"));press(m,1);assert(!m.visible()&&!v.overlay_on);
 assert(v.saves==0);
 View save;Menu saver(save,1);down(saver,2);press(saver,0x100);down(saver,2);
 saver.input(0x100);saver.input(0x100);assert(save.saves==1);saver.input(0);
 View gb;Menu gbmenu(gb,7);gbmenu.redraw();down(gbmenu,2);press(gbmenu,0x100);assert(gb.has(16,"Region: fixed (Game Boy)"));
 down(gbmenu,4);press(gbmenu,0x100);down(gbmenu,2);press(gbmenu,0x100);press(gbmenu,1);press(gbmenu,1);
 press(gbmenu,0x10);press(gbmenu,0x100);down(gbmenu,2);assert(gb.has(23,"GB core running"));
 return 0;
}
