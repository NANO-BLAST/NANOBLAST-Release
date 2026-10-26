#include "../storage/background_install.h"
#include <vector>
#include <cassert>
#include <cstring>
using namespace nanoblast;
struct IO:BackgroundInstallIO {
 bool present=false,match=true,temp_exists=false,active=false,committed=false,cancelled=false;
 bool write_ok=true,finish_ok=true,read_ok=true,commit_ok=true,corrupt=false;
 unsigned begin_count=0,pos=0;
 unsigned bad_offset=0;uint8_t wanted=0,found=0;bool mismatch_seen=false;
 std::vector<uint8_t> temporary,final;
 bool exists()override{return present;}
 bool matches_original(const uint8_t*,unsigned)override{return match;}
 bool begin()override{++begin_count;if(temp_exists)return false;active=true;return true;}
 bool write(const uint8_t*p,unsigned n)override{if(!write_ok)return false;temporary.insert(temporary.end(),p,p+n);return true;}
 bool finish()override{return finish_ok;}
 bool open_readback()override{pos=0;if(corrupt)temporary.back()^=1;return true;}
 bool readback(uint8_t*p,unsigned n)override{if(!read_ok)return false;assert(pos+n<=temporary.size());std::memcpy(p,temporary.data()+pos,n);pos+=n;return true;}
 bool commit()override{if(!commit_ok)return false;final=temporary;temporary.clear();committed=true;active=false;return true;}
 void cancel()override{assert(active);temporary.clear();active=false;cancelled=true;}
 void mismatch(unsigned offset,uint8_t expected,uint8_t actual)override{mismatch_seen=true;bad_offset=offset;wanted=expected;found=actual;}
};
int main(){
 uint8_t header[32]={};std::vector<uint8_t> data(405883);for(unsigned i=0;i<data.size();i++)data[i]=i*13;
 auto run=[&](IO&io){return install_background(io,header,sizeof header,data.data(),data.size());};
 IO ok;assert(run(ok)==BackgroundInstallResult::Installed&&ok.committed&&ok.final==data);
 IO exists;exists.present=true;exists.final={1,2,3};assert(run(exists)==BackgroundInstallResult::Exists&&!exists.begin_count&&exists.final==std::vector<uint8_t>({1,2,3}));
 IO custom;custom.match=false;assert(run(custom)==BackgroundInstallResult::NotApplicable&&!custom.begin_count);
 IO foreign;foreign.temp_exists=true;foreign.temporary={7,8};assert(run(foreign)==BackgroundInstallResult::Failed&&!foreign.cancelled&&foreign.temporary==std::vector<uint8_t>({7,8}));
 for(unsigned failure=0;failure<5;failure++){
  IO broken;if(failure==0)broken.write_ok=false;if(failure==1)broken.finish_ok=false;if(failure==2)broken.read_ok=false;if(failure==3)broken.corrupt=true;if(failure==4)broken.commit_ok=false;
  assert(run(broken)==BackgroundInstallResult::Failed&&broken.cancelled&&!broken.committed&&broken.final.empty()&&broken.temporary.empty());
  if(failure==3)assert(broken.mismatch_seen&&broken.bad_offset==data.size()-1&&broken.wanted==data.back()&&broken.found==(data.back()^1));
 }
 return 0;
}
