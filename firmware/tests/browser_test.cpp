#define NANOBLAST_BROWSER_HOST_TEST
#include "../ui/file_chooser.cpp"
#include <cassert>
#include <map>
#include <deque>
#include <cstring>
#include <cstdarg>
#include <cstdio>
std::map<string,vector<FileEntry>> directories;
std::deque<std::pair<int,int>> actions;
unsigned held=0,release_polls=0,waits=0,closed=0;bool read_error=false;unsigned read_calls=0;
FRESULT f_opendir(DIR*d,const char*p){if(!directories.count(p))return FR_NO_PATH;d->path=p;d->index=0;return FR_OK;}
FRESULT f_readdir(DIR*d,FILINFO*f){++read_calls;if(read_error)return FR_DISK_ERR;auto&e=directories.at(d->path);if(d->index==e.size()){f->fname[0]=0;return FR_OK;}auto a=e[d->index++];std::strcpy(f->fname,a.name.c_str());f->fattrib=a.is_dir?AM_DIR:0;return FR_OK;}
FRESULT f_closedir(DIR*){closed++;return FR_OK;}
void overlay_clear(){}void overlay_status(const char*,...){}void overlay_cursor(int,int){}void overlay_printf(const char*,...){}
void delay(int ms){assert(ms<=10);waits++;}
bool seed_poll=true,release_due=false;unsigned visible_active=0,stuck=0;
void get_joypad_states(uint16_t*a,uint16_t*b,uint16_t*c,uint16_t*d){
 release_polls++;assert(release_polls<10000);*a=*b=*d=0;*c=stuck;
 if(seed_poll){seed_poll=false;release_due=false;if(held){*c|=0x100;held--;}return;}
 if(held){*c|=0x100;held--;if(!held)release_due=true;return;}
 if(release_due){release_due=false;return;}
 if(actions.empty())return;
 const auto action=actions.front();
 if(unsigned(action.first)!=visible_active)*c|=unsigned(action.first)>visible_active?0x20:0x10;
 else{*c|=action.second==1?1:action.second==2?0x80:action.second==3?0x40:0x100;actions.pop_front();}
 release_due=true;
}
bool choose(FileChooser&c,string&result){seed_poll=true;return c.choose_file(result);}
int joy_choice(int top,int len,int*active,int,bool arrow){assert(top==15&&!arrow&&!held&&!actions.empty());auto a=actions.front();actions.pop_front();assert(len?a.first<len:a.first==0);*active=a.first;return a.second;}
struct View:nanoblast::Platform{
 unsigned frames=0,disabled=0;vector<string> labels;vector<unsigned> selected;char grid[28][32];
 void clear()override{std::memset(grid,' ',sizeof grid);}
 void text(unsigned x,unsigned y,const char*s)override{
  const unsigned n=std::strlen(s);
  if(y>=15&&y<=24)assert(x==2);
  if(y==25)assert(x==(n<31?1+(31-n)/2:1));
  assert(std::string(s)!=".."&&std::string(s)!="Back"&&std::string(s).find("Return")==string::npos);
  labels.emplace_back(s);if(x<32&&y<28)std::memcpy(grid[y]+x,s,std::min<unsigned>(n,32-x));
 }
 void panel(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{assert(on&&l==1&&t==14&&r==31&&b==25);}
 void selection(bool on,unsigned l,unsigned t,unsigned r,unsigned b)override{if(!on){assert(l==0&&t==0&&r==0&&b==0);disabled++;visible_active=0;return;}assert(l==1&&r==31&&t==b&&t>=15&&t<=24);selected.push_back(t);visible_active=t-15;}
 void half_cell_row(int row)override{assert(row==-1);}
 void present()override{for(unsigned y=26;y<27;y++)assert(std::string(grid[y],32)==std::string(32,' '));assert(std::string(grid[27]+1,30)=="U/D Move L/R Page A:Sel B:Back");assert(std::string(grid[14],32)==std::string(32,' '));frames++;}
 void overlay(bool)override{}void shortcut(bool)override{}
 bool available(unsigned)override{return false;}
 nanoblast::SwitchResult switch_core(unsigned)override{return nanoblast::SwitchResult::Unavailable;}
 nanoblast::BrowseResult browse_games(unsigned)override{return nanoblast::BrowseResult::Cancelled;}
};
int main(){
 // A 1,000-file folder is counted once. Page two reads only its first 20 entries.
 directories["sd:/large"]={};for(unsigned i=0;i<1000;i++)directories["sd:/large"].push_back({"game"+std::to_string(i)+".nes",false});
 FileChooser large;vector<FileEntry> rows;int total=0;read_calls=0;
 assert(large.list_files("sd:/large",rows,0,10,&total)&&total==1000&&read_calls==1001);
 read_calls=0;assert(large.list_files("sd:/large",rows,10,10,&total,total)&&total==1000&&rows.front().name=="game10.nes"&&read_calls==20);

 directories["sd:/"]={{"Folder",true}};directories["sd:/Folder"]={{"100% fun.nes",false}};
 FileChooser c;c.rootdir=c.curdir="sd:/";View v;c.menu_platform=&v;string result;
 held=3;actions={{0,4},{0,4}};assert(choose(c,result)&&result=="sd:/Folder/100% fun.nes"&&release_polls>=5);
 // B at the file returns to its parent; another B leaves the root. No file selected.
 actions={{0,1},{0,1}};assert(!choose(c,result)&&c.curdir==c.rootdir&&actions.empty());
 // B at root must not launch its highlighted folder or file.
 c.curdir=c.rootdir;actions={{0,1}};assert(!choose(c,result)&&c.curdir==c.rootdir);
 directories["sd:/Empty"]={};c.curdir="sd:/Empty";actions={{0,4},{0,1},{0,1}};
 assert(!choose(c,result)&&v.disabled>0&&c.curdir==c.rootdir); // A on empty folder does nothing.
 directories["sd:/"].clear();for(unsigned i=0;i<25;i++)directories["sd:/"].push_back({"game"+std::to_string(i)+".nes",false});
 c.curdir=c.rootdir;actions={{0,2},{0,2},{0,4}};assert(choose(c,result)&&result=="sd:/game20.nes");
 c.curdir=c.rootdir;actions={{9,4}};assert(choose(c,result)&&result=="sd:/game9.nes"&&v.selected.back()==24);
 c.curdir=c.rootdir;actions={{0,2},{9,4}};assert(choose(c,result)&&result=="sd:/game19.nes"&&v.selected.back()==24);
 // Core folder is the boundary, including nested directories and missing roots.
 directories["sd:/nes"]={{"Series",true}};
 directories["sd:/nes/Series"]={{"Part2",true}};
 directories["sd:/nes/Series/Part2"]={{"game.nes",false}};
 c.curdir=c.rootdir="sd:/nes";actions={{0,4},{0,4},{0,4}};
 assert(choose(c,result)&&result=="sd:/nes/Series/Part2/game.nes");
 actions={{0,1},{0,1},{0,1}};assert(!choose(c,result)&&c.curdir=="sd:/nes"&&actions.empty());
 c.curdir=c.rootdir="sd:/sms";actions={{0,4},{0,1}};
 assert(!choose(c,result)&&c.last_error==FR_OK&&actions.empty());
 assert(v.labels.back()=="Missing /sms folder");
 c.curdir=c.rootdir="sd:/";
 bool page=false;for(auto&s:v.labels)if(s=="Page 3/3")page=true;assert(page);
 c.curdir=c.rootdir;actions={{0,2},{0,3},{0,4}};assert(choose(c,result)&&result=="sd:/game0.nes");
 c.curdir="sd:/missing";assert(!choose(c,result)&&c.last_error==FR_NO_PATH);
 // A held across entry must not block a new B press, even without a release.
 c.curdir=c.rootdir;stuck=0x100;actions={{0,1}};
 assert(!choose(c,result)&&actions.empty());stuck=0;
 c.curdir=c.rootdir;read_error=true;assert(!choose(c,result)&&c.last_error==FR_DISK_ERR);
 return 0;
}
