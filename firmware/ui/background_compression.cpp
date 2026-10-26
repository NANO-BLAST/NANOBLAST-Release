// GPL-3.0.
#include "background_compression.h"
#include <cstring>
namespace nanoblast {
CompressedBackground::CompressedBackground(AssetSource&s):source_(s){
 uint8_t header[16];
 valid_=s.size()>16 && s.read(header,16) && !std::memcmp(header,"NBLZ0001",8)
  && header[8]==0x20 && header[9]==0x13 && header[10]==0x0e && header[11]==0
  && !header[12]&&!header[13]&&!header[14]&&!header[15];
 if(valid_)failure_="none";
}
bool CompressedBackground::byte(uint8_t &b){
 if(used_==available_){
  unsigned remaining=source_.size()-consumed_;
  available_=remaining<sizeof input_?remaining:sizeof input_;used_=0;
  if(!available_){failure_="truncated";return false;}
  if(!source_.read(input_,available_)){failure_="SD read";return false;}
 }
 b=input_[used_++];++consumed_;return true;
}
bool CompressedBackground::read(uint8_t*out,unsigned n){
 if(!valid_||n>922400-produced_)return false;
 while(n--){
  uint8_t value;
  if(!match_){
   if(!bits_){uint8_t f;if(!byte(f))return valid_=false;flags_=f;bits_=8;}
   bool backref=flags_&1;flags_>>=1;--bits_;
   if(backref){
    uint8_t low,high;if(!byte(low)||!byte(high))return valid_=false;
    unsigned token=low|(unsigned(high)<<8);
    distance_=(token>>4)+1;match_=(token&15)+3;
    if(distance_>produced_||match_>922400-produced_){failure_="token";return valid_=false;}
   }else if(!byte(value))return valid_=false;
  }
  if(match_){value=history_[(produced_-distance_)&4095];--match_;}
  history_[produced_++&4095]=value;*out++=value;
 }
 if(produced_==922400 && (match_||flags_||consumed_!=source_.size())){failure_="trailing";return valid_=false;}
 return true;
}
}
