#include "../storage/core_stage.h"
#include <algorithm>
#include <cassert>
#include <cstring>
#include <vector>
using namespace nanoblast;
struct IO:StageIO {
 std::vector<uint8_t> flash=std::vector<uint8_t>(4*1024*1024,255),source;
 unsigned pos=0,erases=0,writes=0;bool read_bad=false,flash_bad=false,corrupt=false;
 IO(){source.resize(907418);for(unsigned i=0;i<source.size();i++)source[i]=(i*13)^(i>>8);flash[0]=0x5a;flash[CacheStart-1]=0xa5;}
 uint32_t flash_size()override{return flash.size();}
 bool read_source(uint8_t*p,unsigned n)override{if(read_bad||pos+n>source.size())return false;std::memcpy(p,source.data()+pos,n);pos+=n;return true;}
 bool read_flash(uint32_t a,uint8_t*p,unsigned n)override{if(a+n>flash.size())return false;std::memcpy(p,flash.data()+a,n);if(corrupt&&writes&&a==CacheData)p[0]^=1;return true;}
 bool write_flash(uint32_t a,const uint8_t*p,unsigned n)override{if(flash_bad)return false;assert(a>=CacheStart&&a+n<=CacheStart+CacheSize);for(unsigned i=0;i<n;i++){assert((flash[a+i]&p[i])==p[i]);flash[a+i]&=p[i];}writes++;return true;}
 bool erase_flash(uint32_t a,unsigned n)override{if(flash_bad)return false;assert(a%4096==0&&n==4096&&a>=CacheStart&&a+n<=CacheStart+CacheSize);std::fill(flash.begin()+a,flash.begin()+a+n,255);erases++;return true;}
};
int main(){
 IO io;assert(stage_core(io,io.source.size())==StageResult::Ready);
 assert(std::equal(io.source.begin(),io.source.end(),io.flash.begin()+CacheData));
 assert(io.flash[0]==0x5a&&io.flash[CacheStart-1]==0xa5);
 // Re-use only our own slot, including after an interrupted source read.
 io.pos=0;io.read_bad=true;assert(stage_core(io,io.source.size())==StageResult::ReadError);
 io.pos=0;io.read_bad=false;assert(stage_core(io,io.source.size())==StageResult::Ready);
 IO foreign;foreign.flash[CacheData+1500]=0;
 assert(stage_core(foreign,100)==StageResult::ForeignData&&foreign.erases==0&&foreign.pos==0);
 IO large;assert(stage_core(large,CacheSize)==StageResult::TooLarge&&large.erases==0);
 large.flash.resize(1024*1024);assert(stage_core(large,100)==StageResult::TooLarge&&large.erases==0);
 IO bad;bad.corrupt=true;assert(stage_core(bad,1024)==StageResult::VerifyError);
 IO fail;fail.flash_bad=true;assert(stage_core(fail,1024)==StageResult::FlashError);
 // The third built-in image owns the old staging area. Never erase it
 // or the separate journal in order to stage a custom card image.
 IO snes;std::memcpy(snes.flash.data()+CacheStart,"NBCORE01",8);
 std::memcpy(snes.flash.data()+0x3ff000,"NBTRACE1",8);auto before=snes.flash;
 assert(stage_core(snes,907418)==StageResult::ForeignData&&!snes.erases&&snes.flash==before);
 IO zero;assert(stage_core(zero,0)==StageResult::TooLarge&&zero.erases==0);
}
