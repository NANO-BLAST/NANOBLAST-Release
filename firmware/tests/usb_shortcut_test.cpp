// Exercise the production shortcut dispatcher and its existing SD-ownership guard.
#include "nanoblast_menu.h"
#include <cassert>
#include <array>
#include <string>
#include <vector>
using namespace nanoblast;
struct Fake:Platform {
 unsigned transfers=0; bool transfer_ok=true,game=false,overlay_enabled=true;
 std::vector<std::string> lines;
 void clear()override{lines.clear();}
 void text(unsigned,unsigned,const char*s)override{lines.emplace_back(s);}
 void panel(bool,unsigned,unsigned,unsigned,unsigned)override{}
 void overlay(bool enabled)override{overlay_enabled=enabled;}
 bool available(unsigned)override{return true;}
 SwitchResult switch_core(unsigned)override{return SwitchResult::Loaded;}
 BrowseResult browse_games(unsigned)override{return game?BrowseResult::Loaded:BrowseResult::Cancelled;}
 void shortcut(bool)override{}
 bool usb_transfer()override{++transfers;return transfer_ok;}
 bool has(const char*s)const{for(const auto&line:lines){std::string normalized;for(char c:line)if(c!=' '||normalized.empty()||normalized.back()!=' ')normalized+=c;if(normalized==s)return true;}return false;}
};
void press(Menu&m,uint16_t keys){m.input(keys);m.input(0);}
void down(Menu&m,unsigned n){while(n--)press(m,0x20);}
void page(Menu&m,Page p){
 if(p==Page::Home)return;
 if(p==Page::Cores){down(m,1);press(m,0x100);return;}
 down(m,2);press(m,0x100);
 if(p==Page::Settings)return;
 down(m,p==Page::Clock?3:4);press(m,0x100);
 assert(m.page()==p);
}
int main(){
 constexpr uint16_t select=4,left_shoulder=0x400,combo=0x404;
 for(Page p:{Page::Home,Page::Cores,Page::Settings,Page::Advanced,Page::Clock}){
  Fake f;Menu m(f);page(m,p);m.input(combo);assert(f.transfers==1);
  for(unsigned i=0;i<100;i++)m.input(combo);
  assert(f.transfers==1);m.input(0);m.input(combo);assert(f.transfers==2);
 }
 // Either button can be pressed first, on any of the four input streams.
 for(unsigned device=0;device<4;device++)for(uint16_t first:{select,left_shoulder}){
  Fake f;Menu m(f);std::array<uint16_t,4> pads{};pads[device]=first;
  m.input(pads[0],pads[1],pads[2],pads[3]);assert(!f.transfers);
  pads[device]=combo;m.input(pads[0],pads[1],pads[2],pads[3]);assert(f.transfers==1);
 }
 // No cross-controller chord, right shoulder, or chord with an extra button.
 for(unsigned a=0;a<4;a++)for(unsigned b=0;b<4;b++)if(a!=b){
  Fake f;Menu m(f);std::array<uint16_t,4> pads{};pads[a]=select;pads[b]=left_shoulder;
  m.input(pads[0],pads[1],pads[2],pads[3]);assert(!f.transfers);
 }
 for(uint16_t other:{uint16_t(0x804),uint16_t(0x414),select,left_shoulder}){
  Fake f;Menu m(f);press(m,other);assert(!f.transfers);
 }
 // Menu-shortcut configuration cannot disable Select+L.
 Fake changed;Menu configured(changed);page(configured,Page::Settings);press(configured,0x100);
 press(configured,combo);assert(changed.transfers==1);
 // Failed save/transfer preparation is reported and a held chord never retries.
 Fake failed;failed.transfer_ok=false;Menu failure(failed);failure.input(combo);
 assert(failed.transfers==1&&failed.has("USB transfer unavailable"));
 failure.input(combo);assert(failed.transfers==1);
 failure.input(0);failure.input(combo);assert(failed.transfers==2);
 // The shortcut cannot bypass the same running-game restriction as Advanced.
 Fake playing;playing.game=true;Menu game(playing);press(game,0x100);
 assert(game.running()&&!game.visible()&&!playing.overlay_enabled);
 press(game,combo);assert(!playing.transfers&&game.running()&&game.visible()&&playing.overlay_enabled);
 assert(playing.has("Restart before USB transfer"));
 page(game,Page::Advanced);down(game,4);press(game,0x100);
 assert(!playing.transfers&&playing.has("Restart before USB transfer"));
 // The ordinary Advanced action still enters transfer mode when idle.
 Fake idle;Menu advanced(idle);page(advanced,Page::Advanced);down(advanced,4);press(advanced,0x100);
 assert(idle.transfers==1);
}
