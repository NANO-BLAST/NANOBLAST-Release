#include "persistent_core.h"
#include <cassert>
#include <vector>
#include <cstring>
struct Device:nanoblast::BootFlashIO {
 std::vector<uint8_t> input=std::vector<uint8_t>(907418),flash=std::vector<uint8_t>(0x800000,0xa5);
 unsigned erases=0,pages=0;bool source_error=false,erase_error=false,page_error=false,read_error=false,corrupt=false;
 unsigned read_bytes=0,verify_progress=0;
 unsigned failures=0;nanoblast::BootFlashFailure last_failure=nanoblast::BootFlashFailure::Length;uint32_t failure_value=0;
 void failure(nanoblast::BootFlashFailure why,uint32_t value)override{++failures;last_failure=why;failure_value=value;}
 void progress(unsigned,unsigned,bool verify)override{if(verify)++verify_progress;}
 Device(){for(unsigned i=0;i<input.size();i++)input[i]=(i*17)^(i>>8);}
 bool source(uint32_t a,uint8_t*p,unsigned n)override{if(source_error)return false;assert(a+n<=input.size());memcpy(p,input.data()+a,n);return true;}
 bool read(uint32_t a,uint8_t*p,unsigned n)override{read_bytes+=n;if(read_error)return false;assert(a+n<=input.size());memcpy(p,flash.data()+a,n);if(corrupt)p[0]^=1;return true;}
 bool erase64k(uint32_t a)override{assert(a%65536==0&&a<0x100000);++erases;if(erase_error)return false;memset(flash.data()+a,255,65536);return true;}
 bool page(uint32_t a,const uint8_t*p,unsigned n)override{assert(n<=256&&(a&255)+n<=256&&a+n<=input.size());++pages;if(page_error)return false;for(unsigned i=0;i<n;i++)flash[a+i]&=p[i];return true;}
 uint32_t checksum(){uint32_t c=~0u;for(uint8_t b:input){c^=b;for(unsigned i=0;i<8;i++)c=(c>>1)^((c&1)?0xedb88320:0);}return c^~0u;}
};
int main(){
 Device d;assert(nanoblast::persist_core(d,d.input.size(),d.checksum()));assert(d.erases==14&&d.pages==3545);
 assert(!memcmp(d.flash.data(),d.input.data(),d.input.size()));
 assert(d.read_bytes==d.input.size()&&d.verify_progress);
 Device unchecked;unchecked.read_error=true;
 assert(nanoblast::persist_core(unchecked,907418,unchecked.checksum(),false)&&!unchecked.read_bytes&&!unchecked.verify_progress);
 assert(!memcmp(unchecked.flash.data(),unchecked.input.data(),unchecked.input.size()));
 Device unchecked_bad;assert(!nanoblast::persist_core(unchecked_bad,907418,0,false)&&!unchecked_bad.erases);
 Device unchecked_page;unchecked_page.page_error=true;
 assert(!nanoblast::persist_core(unchecked_page,907418,unchecked_page.checksum(),false));
 for(unsigned i=14*65536;i<d.flash.size();i++)assert(d.flash[i]==0xa5);
 Device bad;assert(!nanoblast::persist_core(bad,907418,bad.checksum()^1)&&!bad.erases);
 assert(bad.failures==1&&bad.last_failure==nanoblast::BootFlashFailure::SourceCRC&&bad.failure_value==bad.checksum());
 bad.source_error=true;assert(!nanoblast::persist_core(bad,907418,bad.checksum())&&!bad.erases);
 assert(bad.last_failure==nanoblast::BootFlashFailure::SourceRead&&bad.failure_value==0);
 Device erase;erase.erase_error=true;assert(!nanoblast::persist_core(erase,907418,erase.checksum()));
 assert(erase.last_failure==nanoblast::BootFlashFailure::Erase&&erase.failure_value==0);
 Device page;page.page_error=true;assert(!nanoblast::persist_core(page,907418,page.checksum()));
 assert(page.last_failure==nanoblast::BootFlashFailure::Program&&page.failure_value==0);
 Device read;read.read_error=true;assert(!nanoblast::persist_core(read,907418,read.checksum()));
 assert(read.last_failure==nanoblast::BootFlashFailure::VerifyRead&&read.failure_value==0);
 Device corrupt;corrupt.corrupt=true;assert(!nanoblast::persist_core(corrupt,907418,corrupt.checksum()));
 assert(corrupt.last_failure==nanoblast::BootFlashFailure::VerifyCRC);
 assert(!nanoblast::persist_core(d,0,0)&&!nanoblast::persist_core(d,0x100000,0));
}
