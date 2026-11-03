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
struct CrtPlatform:Fake{unsigned preset=0,calls=0;void crt(unsigned p)override{preset=p;++calls;}};
int main(){
 for(unsigned core:{1u,5u}){
  CrtPlatform f;Menu m(f,core);page(m,Page::Settings);down(m,1);
  assert(f.has("CRT: Off"));
  const char* names[]={"CRT: Light Scanlines","CRT: Strong Scanlines","CRT: CRT","CRT: Off"};
  for(unsigned i=0;i<4;++i){press(m,0x100);assert(f.preset==((i+1)&3)&&f.calls==i+1&&f.has(names[i]));}
  press(m,0x100); // Light survives a core switch.
  press(m,1);press(m,0x10);press(m,0x100); // Home -> core chooser.
  if(core==1)down(m,1);
  press(m,0x100);assert(f.preset==1&&f.calls==6);
 }
 for(unsigned core:{0u,2u,7u}){
  CrtPlatform f;Menu m(f,core);page(m,Page::Settings);down(m,1);press(m,0x100);
  assert(f.calls==0&&f.has("CRT: NES / SMS only"));
 }
}
