#include "background_compression.h"
#include <vector>
#include <fstream>
#include <cassert>
#include <cstring>
#include <algorithm>
using namespace nanoblast;
struct Source:AssetSource {
 std::vector<uint8_t> data;unsigned pos=0;
 uint32_t size()override{return data.size();}
 bool read(uint8_t*out,unsigned n)override{if(n>data.size()-pos)return false;std::memcpy(out,data.data()+pos,n);pos+=n;return true;}
};
struct Sink:BackgroundTransport {
 bool enabled=false;std::vector<uint8_t> pixels_;std::vector<uint32_t> colors;
 void enable(bool v)override{enabled=v;}
 void palette(uint32_t v)override{colors.push_back(v);}
 bool pixels(uint32_t a,const uint8_t*p,unsigned n)override{assert(a==0x200000+pixels_.size());pixels_.insert(pixels_.end(),p,p+n);return true;}
 void progress(unsigned,unsigned)override{}
};
std::vector<uint8_t> load(const char*path){std::ifstream in(path,std::ios::binary);assert(in);return {std::istreambuf_iterator<char>(in),{}};}
int main(int argc,char**argv){
 assert(argc==3);Source original;original.data=load(argv[1]);auto packed=load(argv[2]);
 Source encoded;encoded.data=packed;CompressedBackground decoded(encoded);
 assert(decoded.size()==original.size());
 std::vector<uint8_t> restored(original.size());
 for(unsigned offset=0;offset<restored.size();){unsigned n=std::min<unsigned>(1+offset%757,restored.size()-offset);assert(decoded.read(restored.data()+offset,n));offset+=n;}
 assert(restored==original.data);uint8_t extra;assert(!decoded.read(&extra,1));
 encoded.pos=0;CompressedBackground image(encoded);Sink compressed,plain;
 assert(upload_background(image,compressed)==BackgroundResult::Ready&&compressed.enabled);
 assert(upload_background(original,plain)==BackgroundResult::Ready&&plain.enabled);
 assert(compressed.pixels_==plain.pixels_&&compressed.colors==plain.colors);
 // Broken token, truncation and trailing data must never enable the image.
 for(unsigned mode=0;mode<3;mode++){
  encoded.data=packed;encoded.pos=0;
  if(mode==0){encoded.data[16]=1;encoded.data[17]=encoded.data[18]=0;}
  if(mode==1)encoded.data.pop_back();
  if(mode==2)encoded.data.push_back(0);
  CompressedBackground bad(encoded);Sink sink;
  assert(upload_background(bad,sink)!=BackgroundResult::Ready&&!sink.enabled);
  if(mode==0)assert(!std::strcmp(bad.failure_reason(),"token"));
 }
 encoded.data=packed;encoded.pos=0;encoded.data[8]^=1;CompressedBackground header(encoded);
 assert(header.size()==0);
 // A valid compressed stream with changed pixels still fails artwork CRC.
 encoded.data=packed;encoded.pos=0;
 bool changed=false;unsigned input=16,output=0;
 while(input<encoded.data.size()&&!changed){
  unsigned flags=encoded.data[input++];
  for(unsigned bit=0;bit<8&&input<encoded.data.size();bit++){
   if(flags&(1u<<bit)){output+=(encoded.data[input]&15)+3;input+=2;}
   else{if(output>=800){encoded.data[input]^=1;changed=true;break;}++input;++output;}
  }
 }
 assert(changed);CompressedBackground corrupt(encoded);Sink sink;
 assert(upload_background(corrupt,sink)!=BackgroundResult::Ready&&!sink.enabled);
 return 0;
}
