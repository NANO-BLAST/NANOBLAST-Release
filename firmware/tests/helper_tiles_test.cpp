// Verify tile updates restore each original pixel without touching nearby art.
#include "../ui/background_helpers.h"
#include <cassert>
#include <vector>
#include <algorithm>
using namespace nanoblast;
struct Transport:BackgroundTransport{
 std::vector<uint8_t> pixels_;unsigned calls=0,fail=0;
 Transport():pixels_(1280*720,255){}
 void enable(bool)override{}void palette(uint32_t)override{}void progress(unsigned,unsigned)override{}
 bool pixels(uint32_t address,const uint8_t *data,unsigned n)override{
  ++calls;if(calls==fail)return false;
  assert(n==33&&address+n<=pixels_.size());std::copy(data,data+n,pixels_.begin()+address);return true;
 }
};
int main(){
 Transport t;assert(upload_button_helpers(t,true)&&t.calls==66);
 for(unsigned y=0;y<720;y++)for(unsigned x=0;x<1280;x++){
  bool tile=y>=670&&y<703&&((x>=448&&x<481)||(x>=688&&x<721));
  if(!tile)assert(t.pixels_[y*1280+x]==255);
 }
 assert(upload_button_helpers(t,false)&&t.calls==132);
 for(unsigned row=0;row<33;row++)for(unsigned x=0;x<33;x++){
  assert(t.pixels_[(670+row)*1280+448+x]==helper_0_plain[row*33+x]);
  assert(t.pixels_[(670+row)*1280+688+x]==helper_1_plain[row*33+x]);
 }
 Transport failure;failure.fail=2;assert(!upload_button_helpers(failure,true)&&failure.calls==2);
 failure.fail=0;assert(upload_button_helpers(failure,false));
}
