// Include the implementation so the fake can identify its flash-backed marker.
#include "../storage/core_stage.cpp"
#include <algorithm>
#include <cassert>
#include <vector>
using namespace nanoblast;
struct Flash:StageIO {
 std::vector<uint8_t> bytes=std::vector<uint8_t>(CacheStart+CacheSize,255);
 unsigned source_reads=0,starts=0,unsafe_sources=0;
 bool damage_owner=false,damage_commit=false,fail_header_read=false;
 uint32_t flash_size()override{return bytes.size();}
 void staging_started()override{starts++;}
 bool read_source(uint8_t*p,unsigned n)override{std::fill(p,p+n,0x59);source_reads++;return true;}
 bool read_flash(uint32_t a,uint8_t*p,unsigned n)override{
  if(fail_header_read&&a==CacheStart&&starts&&n==16)return false;
  std::memcpy(p,bytes.data()+a,n);return true;
 }
 bool erase_flash(uint32_t a,unsigned n)override{std::fill(bytes.begin()+a,bytes.begin()+a+n,255);return true;}
 bool write_flash(uint32_t a,const uint8_t*p,unsigned n)override{
  // Model successful SDK writes whose XIP-backed source becomes unavailable.
  bool unsafe=p==nanoblast::owner;if(unsafe)unsafe_sources++;
  for(unsigned i=0;i<n;i++)bytes[a+i]&=unsafe?0x13:p[i];
  if(damage_owner&&a==CacheStart)bytes[a]&=0x01;
  if(damage_commit&&a==CacheStart+8)bytes[a]=0;
  return true;
 }
};
int main(){
 Flash good;assert(stage_core(good,1025)==StageResult::Ready);
 assert(!good.unsafe_sources&&good.starts==1);
 assert(!std::memcmp(good.bytes.data()+CacheStart,"NBCACHE1",8));
 Flash marker;marker.damage_owner=true;
 assert(stage_core(marker,1025)==StageResult::VerifyError);
 assert(marker.starts==0&&marker.source_reads==0);
 Flash commit;commit.damage_commit=true;
 assert(stage_core(commit,1025)==StageResult::VerifyError);
 Flash read;read.fail_header_read=true;
 assert(stage_core(read,1025)==StageResult::FlashError);
 Flash foreign;foreign.bytes[CacheStart]=0x13;
 assert(stage_core(foreign,1025)==StageResult::ForeignData&&foreign.source_reads==0);
}
