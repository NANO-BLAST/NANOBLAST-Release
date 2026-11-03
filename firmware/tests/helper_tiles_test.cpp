// Exercise four SNES helper tiles through the aligned SDRAM transport contract.
#include "../ui/background_helpers.h"
#include <cassert>
#include <vector>
#include <algorithm>
using namespace nanoblast;
struct Transport:BackgroundTransport{
 std::vector<uint8_t> pixels_;unsigned calls=0,fail=0,pauses=0;bool scanning=true,drained=false;
 Transport():pixels_(1280*720,255){}
 void enable(bool on)override{scanning=on;if(on)drained=false;}
 void pause_scanout()override{enable(false);drained=true;++pauses;}
 void palette(uint32_t)override{}void progress(unsigned,unsigned)override{}
 bool pixels(uint32_t address,const uint8_t *data,unsigned n)override{
  assert(!scanning&&drained);++calls;if(calls==fail)return false;
  assert(address>=0x200000&&!(address&3)&&n&&!(n&3));address-=0x200000;
  assert(address+n<=pixels_.size());std::copy(data,data+n,pixels_.begin()+address);return true;
 }
};
int main(){
 Transport t;assert(upload_button_helpers(t,true)&&t.calls==132&&t.scanning&&t.pauses==1);
 const unsigned left[]={552,792,264,344},width[]={36,36,80,64};
 const uint8_t*plain[]={helper_0_plain,helper_1_plain,helper_2_plain,helper_3_plain};
 const uint8_t*visible[]={helper_0_visible,helper_1_visible,helper_2_visible,helper_3_visible};
 for(unsigned y=0;y<720;y++)for(unsigned x=0;x<1280;x++){
  bool tile=false;for(unsigned i=0;i<4;i++)tile|=y>=670&&y<703&&x>=left[i]&&x<left[i]+width[i];
  if(!tile)assert(t.pixels_[y*1280+x]==255);
 }
 for(unsigned i=0;i<4;i++)for(unsigned y=0;y<33;y++)for(unsigned x=0;x<width[i];x++)assert(t.pixels_[(670+y)*1280+left[i]+x]==visible[i][y*width[i]+x]);
 assert(upload_button_helpers(t,false)&&t.calls==264&&t.scanning&&t.pauses==2);
 for(unsigned i=0;i<4;i++)for(unsigned y=0;y<33;y++)for(unsigned x=0;x<width[i];x++)assert(t.pixels_[(670+y)*1280+left[i]+x]==plain[i][y*width[i]+x]);
 Transport failure;failure.fail=2;assert(!upload_button_helpers(failure,true)&&failure.calls==2&&failure.scanning);
 failure.fail=0;assert(upload_button_helpers(failure,false));
}
