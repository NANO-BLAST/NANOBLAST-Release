#include "save_journal.h"
#include "crc32.h"
#ifdef NANOBLAST_SAVE_HOST_TEST
#include "../tests/save_platform.h"
#else
#include "ff.h"
#endif
#include <cstring>
#include <algorithm>
namespace nanoblast {
namespace {
uint32_t word(const uint8_t*p){return uint32_t(p[0])|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
void put(uint8_t*p,uint32_t v){for(unsigned i=0;i<4;i++)p[i]=v>>(8*i);}
std::string file(const std::string&p,unsigned slot){return p+(slot?".1":".0");}
bool inspect(const std::string &path,uint32_t kind,uint32_t identity,uint32_t size,unsigned bytes,SaveRecord &record){
 FIL f;uint8_t h[64],buffer[512];UINT got=0;
 if(f_open(&f,path.c_str(),FA_READ)!=FR_OK)return false;
 bool ok=f_size(&f)==64+bytes&&f_read(&f,h,64,&got)==FR_OK&&got==64;
 ok=ok&&!std::memcmp(h,"NBSAVE01",8)&&word(h+8)==1&&word(h+12)==kind&&word(h+20)==identity&&word(h+24)==size&&word(h+28)==bytes&&word(h+52)==(crc32_update(~0u,h,52)^~0u);
 for(unsigned i=56;i<64&&ok;i++)ok=h[i]==0;
 uint32_t crc=~0u;
 for(unsigned off=0;off<bytes&&ok;){unsigned n=std::min(512u,bytes-off);ok=f_read(&f,buffer,n,&got)==FR_OK&&got==n;if(ok)crc=crc32_update(crc,buffer,n);off+=n;}
 ok=ok&&(crc^~0u)==word(h+32);
 if(ok){record.sequence=word(h+16);std::memcpy(record.auxiliary,h+36,16);}
 if(f_close(&f)!=FR_OK)ok=false;return ok;
}
}
bool save_directory(const std::string&p){FILINFO i;if(f_stat(p.c_str(),&i)==FR_OK)return (i.fattrib&AM_DIR)!=0;return f_mkdir(p.c_str())==FR_OK;}
SaveScan save_scan(const std::string&p,uint32_t kind,uint32_t identity,uint32_t size,unsigned bytes,SaveRecord&r){
 bool exists=false,valid=false;
 for(unsigned slot=0;slot<2;slot++){
  FILINFO info;const auto name=file(p,slot);auto result=f_stat(name.c_str(),&info);
  if(result==FR_NO_FILE||result==FR_NO_PATH)continue;
  exists=true;if(result!=FR_OK)continue;
  SaveRecord candidate;candidate.slot=slot;
  if(inspect(name,kind,identity,size,bytes,candidate)&&(!valid||int32_t(candidate.sequence-r.sequence)>0)){r=candidate;valid=true;}
 }
 return valid?SaveScan::Valid:exists?SaveScan::Damaged:SaveScan::Missing;
}
bool save_read(const std::string&p,const SaveRecord&r,uint8_t*data,unsigned bytes){
 FIL f;UINT got=0;if(f_open(&f,file(p,r.slot).c_str(),FA_READ)!=FR_OK)return false;
 bool ok=f_lseek(&f,64)==FR_OK;
 for(unsigned off=0;off<bytes&&ok;){unsigned n=std::min(1024u,bytes-off);ok=f_read(&f,data+off,n,&got)==FR_OK&&got==n;off+=n;}
 return f_close(&f)==FR_OK&&ok;
}
bool save_commit(const std::string&p,uint32_t kind,uint32_t identity,uint32_t size,const uint8_t aux[16],const uint8_t*data,unsigned bytes,SaveRecord&r,bool existing){
 const unsigned slot=existing?(r.slot^1u):0;const uint32_t sequence=existing?r.sequence+1:1;
 uint8_t h[64]={};std::memcpy(h,"NBSAVE01",8);put(h+8,1);put(h+12,kind);put(h+16,sequence);put(h+20,identity);put(h+24,size);put(h+28,bytes);put(h+32,crc32_update(~0u,data,bytes)^~0u);std::memcpy(h+36,aux,16);put(h+52,crc32_update(~0u,h,52)^~0u);
 FIL f;UINT got=0;const auto name=file(p,slot);if(f_open(&f,name.c_str(),FA_WRITE|FA_CREATE_ALWAYS)!=FR_OK)return false;
 bool ok=f_write(&f,h,64,&got)==FR_OK&&got==64;
 for(unsigned off=0;off<bytes&&ok;){unsigned n=std::min(1024u,bytes-off);ok=f_write(&f,data+off,n,&got)==FR_OK&&got==n;off+=n;}
 if(ok)ok=f_sync(&f)==FR_OK;if(f_close(&f)!=FR_OK)ok=false;
 SaveRecord verified;verified.slot=slot;
 if(!ok||!inspect(name,kind,identity,size,bytes,verified)||verified.sequence!=sequence||std::memcmp(verified.auxiliary,aux,16))return false;
 r=verified;return true;
}
}
