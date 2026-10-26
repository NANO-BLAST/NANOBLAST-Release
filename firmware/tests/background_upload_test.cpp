#include "background_upload.h"
#include <vector>
#include <fstream>
#include <cassert>
#include <cstring>
using namespace nanoblast;
struct File:AssetSource{
 std::vector<uint8_t>data;unsigned pos=0,fail_at=0xffffffff;
 uint32_t size()override{return data.size();}
 bool read(uint8_t*out,unsigned n)override{if(pos>=fail_at||pos+n>data.size())return false;std::memcpy(out,data.data()+pos,n);pos+=n;return true;}
};
struct Transport:BackgroundTransport{
 bool enabled=false,fail=false;unsigned palettes=0,progress_steps=0,packets=0,last_progress=0;
 std::vector<uint8_t>frame;
 void enable(bool v)override{enabled=v;}
 void palette(uint32_t)override{palettes++;}
 bool pixels(uint32_t address,const uint8_t*data,unsigned n)override{
  assert(address==0x200000+frame.size()&&n==1024);
  ++packets;if(fail)return false;
  frame.insert(frame.end(),data,data+n);return true;
 }
 void progress(unsigned n,unsigned size)override{assert(size==921600&&n<=size);assert(n>last_progress);last_progress=n;progress_steps++;}
};
int main(int argc,char**argv){assert(argc==2);std::ifstream in(argv[1],std::ios::binary);File source;source.data.assign(std::istreambuf_iterator<char>(in),{});assert(source.data.size()==922400);
 Transport t;assert(upload_background(source,t)==BackgroundResult::Ready&&t.enabled&&t.palettes==256&&t.progress_steps==26);assert(t.packets==900&&t.last_progress==921600);assert(t.frame.size()==921600&&!std::memcmp(t.frame.data(),source.data.data()+800,921600));
 source.pos=0;source.data.back()^=1;Transport corrupt;assert(upload_background(source,corrupt)==BackgroundResult::Invalid&&!corrupt.enabled);source.data.back()^=1;
 source.pos=0;source.fail_at=800;Transport read_failure;assert(upload_background(source,read_failure)==BackgroundResult::ReadError&&!read_failure.enabled);
 source.pos=0;source.fail_at=0xffffffff;Transport write_failure;write_failure.fail=true;assert(upload_background(source,write_failure)==BackgroundResult::TransportError&&!write_failure.enabled);
 source.pos=0;source.data[0]='X';Transport bad_header;assert(upload_background(source,bad_header)==BackgroundResult::Invalid&&bad_header.palettes==0);
}
