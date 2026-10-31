#include "../ui/nanoblast_menu.h"
#include <cassert>
#include <map>
#include <string>
using namespace nanoblast;
struct View:Platform {
 std::map<unsigned,std::string>rows;ClockDate date{2024,2,29,23,59,30};unsigned sets=0;bool success=true;
 void clear()override{rows.clear();}void text(unsigned,unsigned y,const char*s)override{rows[y]=s;}
 void panel(bool,unsigned,unsigned,unsigned,unsigned)override{}
 void overlay(bool)override{}bool available(unsigned)override{return true;}
 SwitchResult switch_core(unsigned)override{return SwitchResult::Loaded;}
 BrowseResult browse_games(unsigned)override{return BrowseResult::Cancelled;}
 void shortcut(bool)override{}ClockDate clock_get()override{return date;}
 bool clock_set(const ClockDate&d)override{assert(valid_date(d));sets++;if(success)date=d;return success;}
 bool valid_date(const ClockDate&d){return d.year>=2000&&d.year<=2099&&d.month>0&&d.month<=12&&d.day>0&&d.day<=31&&d.hour<24&&d.minute<60&&d.second==0;}
 bool has(const char*s){for(auto&r:rows)if(r.second==s)return true;return false;}
};
void key(Menu&m,unsigned k){m.input(k);m.input(0);}
int main(){
 View v;Menu m(v,7);key(m,0x20);key(m,0x20);key(m,0x100);assert(m.page()==Page::Settings&&v.has("Clock")&&v.has("Advanced"));
 for(unsigned i=0;i<3;i++)key(m,0x20);key(m,0x100);assert(m.page()==Page::Clock&&v.has("Day: 29"));
 key(m,0x100);key(m,0x10);key(m,0x100);assert(v.has("Year: 2025")&&v.has("Day: 28"));assert(v.sets==0);
 for(unsigned i=0;i<5;i++)key(m,0x20);key(m,0x100);assert(v.sets==1&&v.date.year==2025&&v.date.second==0&&v.has("Clock saved"));
 v.success=false;key(m,0x100);assert(v.has("Clock save failed"));
 key(m,1);assert(m.page()==Page::Settings);key(m,0x20);key(m,0x100);assert(m.page()==Page::Advanced);
 key(m,1);assert(m.page()==Page::Settings);key(m,1);assert(m.page()==Page::Home);
}
