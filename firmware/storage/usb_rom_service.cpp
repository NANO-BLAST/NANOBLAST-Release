#include "usb_rom_service.h"
#include "crc32.h"
#include <cstring>
#include <cctype>
namespace nanoblast::usbrom {
uint32_t get32(const uint8_t*p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
void put32(uint8_t*p,uint32_t n){for(unsigned i=0;i<4;i++)p[i]=uint8_t(n>>(8*i));}
bool valid_path(const char*p,bool rom){
 const auto n=std::strlen(p);if(n>MaxPath)return false;
 if(!n)return !rom;
 const char*slash=std::strchr(p,'/');auto first=slash?unsigned(slash-p):unsigned(n);
 bool core=(first==3&&(!std::strncmp(p,"nes",3)||!std::strncmp(p,"sms",3)))||(first==2&&!std::strncmp(p,"gb",2))||(first==4&&!std::strncmp(p,"snes",4));
 if(!core)return false;
 const char*segment=p;
 for(unsigned i=0;i<=n;i++){
  unsigned char c=p[i];
  if(c=='/'||!c){unsigned len=unsigned(p+i-segment);if(!len||segment[0]=='.'||segment[len-1]=='.'||segment[len-1]==' ')return false;
   if(len==5){char lower[6]{};for(unsigned j=0;j<5;j++)lower[j]=char(std::tolower(static_cast<unsigned char>(segment[j])));if(!std::strcmp(lower,"saves"))return false;}
   segment=p+i+1;
  }else if(!((c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9')||c==' '||c=='_'||c=='-'||c=='.'||c=='('||c==')'))return false;
 }
 if(!rom)return true;
 if(!slash)return false;const char*dot=std::strrchr(p,'.');if(!dot||std::strchr(dot,'/'))return false;
 char ext[5]{};if(std::strlen(dot)>4)return false;for(unsigned i=0;dot[i];i++)ext[i]=char(std::tolower(static_cast<unsigned char>(dot[i])));
 if(!std::strcmp(ext,".zip"))return true;
 if(first==3&&!std::strncmp(p,"nes",3))return !std::strcmp(ext,".nes");
 if(first==3)return !std::strcmp(ext,".sms")||!std::strcmp(ext,".gg");
 if(first==2)return !std::strcmp(ext,".gb")||!std::strcmp(ext,".gbc");
 return !std::strcmp(ext,".sfc")||!std::strcmp(ext,".smc");
}
void Service::disconnect(){files_.abort();hello_=upload_=false;offset_=0;}
unsigned Service::request(uint8_t op,const uint8_t*d,unsigned n,uint8_t*out,uint8_t&s){
 s=0;if(n>MaxPayload){s=1;return 0;}
 if(op==1){if(n){s=1;return 0;}disconnect();hello_=true;const char*id="NANOBLAST-ROM/1";std::memcpy(out,id,std::strlen(id));return std::strlen(id);}
 if(!hello_){s=2;return 0;}
 if(op==6){if(n){s=1;return 0;}files_.abort();upload_=false;return 0;}
 if(op==2){
  if(upload_){s=2;return 0;}if(n<4||n-4>MaxPath||std::memchr(d+4,0,n-4)){s=1;return 0;}
  char path[MaxPath+1]{};std::memcpy(path,d+4,n-4);if(!valid_path(path,false)){s=1;return 0;}
  Entry e;bool end=false;if(!files_.list(path,get32(d),e,end)){s=3;return 0;}if(end)return 0;
  auto len=std::strlen(e.name);if(len>MaxPath){s=3;return 0;}out[0]=e.directory?1:0;put32(out+1,e.size);std::memcpy(out+5,e.name,len);return len+5;
 }
 if(op==3){
  if(upload_){s=2;return 0;}if(n<9||n-8>MaxPath||std::memchr(d+8,0,n-8)){s=1;return 0;}
  char path[MaxPath+1]{};std::memcpy(path,d+8,n-8);if(!valid_path(path,true)||!get32(d)||get32(d)>MaxRom){s=1;return 0;}
  size_=get32(d);wanted_=get32(d+4);offset_=0;crc_=0xffffffff;
  if(!files_.begin(path,size_)){s=3;return 0;}upload_=true;return 0;
 }
 if(op==4){
  if(!upload_){s=2;return 0;}if(n<=4||get32(d)!=offset_||n-4>size_-offset_){s=1;return 0;}
  if(!files_.append(d+4,n-4)){files_.abort();upload_=false;s=3;return 0;}
  crc_=crc32_update(crc_,d+4,n-4);offset_+=n-4;put32(out,offset_);return 4;
 }
 if(op==5){
  if(!upload_){s=2;return 0;}if(n||offset_!=size_||(crc_^0xffffffff)!=wanted_){files_.abort();upload_=false;s=4;return 0;}
  bool ok=files_.commit(size_,wanted_);files_.abort();upload_=false;if(!ok)s=3;return 0;
 }
 s=1;return 0;
}
}
