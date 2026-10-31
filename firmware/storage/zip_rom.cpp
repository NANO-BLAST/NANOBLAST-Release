#include "zip_rom.h"
#include "crc32.h"
#include "tinf/tinf_stream.h"
#include <algorithm>
#include <cstring>
#include <cctype>
namespace nanoblast {
namespace {
uint16_t u16(const uint8_t*p){return uint16_t(p[0])|uint16_t(p[1])<<8;}
uint32_t u32(const uint8_t*p){return uint32_t(u16(p))|uint32_t(u16(p+2))<<16;}
bool suffix(const char*s,const char*ext){auto n=std::strlen(s),m=std::strlen(ext);if(n<m)return false;for(unsigned i=0;i<m;++i)if(std::tolower(static_cast<unsigned char>(s[n-m+i]))!=ext[i])return false;return true;}
bool matching(const char*s,unsigned core){return core==1?suffix(s,".nes"):core==5?(suffix(s,".sms")||suffix(s,".gg")):core==7?(suffix(s,".gb")||suffix(s,".gbc")):core==2?(suffix(s,".sfc")||suffix(s,".smc")):false;}
bool safe_name(const char*s){
 if(!*s||*s=='/'||*s=='\\')return false;
 const char*part=s;
 for(const char*p=s;;++p){unsigned char c=*p;
  if(!c||c=='/'){auto n=p-part;if(!n||part[0]=='.'||part[n-1]=='.'||part[n-1]==' ')return false;if(!c)break;part=p+1;}
  else if(c<32||c>=127||std::strchr("\\:*?\"<>|",c))return false;
 }return true;
}
struct Stream {
 ZipIO&io;uint32_t offset,remaining,produced=0,wanted,crc=~0u;bool failed=false;uint8_t input[512]{};unsigned index=0,available=0;
 static int read(void*ptr){auto&s=*static_cast<Stream*>(ptr);if(s.index==s.available){if(!s.remaining)return -1;unsigned n=std::min<uint32_t>(512,s.remaining);if(!s.io.read(s.offset,s.input,n)){s.failed=true;return -1;}s.offset+=n;s.remaining-=n;s.index=0;s.available=n;}return s.input[s.index++];}
 static int write(void*ptr,const unsigned char*data,unsigned n){auto&s=*static_cast<Stream*>(ptr);if(n>s.wanted-s.produced||!s.io.write(data,n)){s.failed=true;return 0;}s.crc=crc32_update(s.crc,data,n);s.produced+=n;s.io.progress(s.produced,s.wanted);return 1;}
};
}
bool zip_rom_path(const char*path){return suffix(path,".zip");}
const char *zip_rom_error(ZipResult result){switch(result){
 case ZipResult::NoRom:return "ZIP has no matching ROM";
 case ZipResult::MultipleRoms:return "ZIP contains multiple ROMs";
 case ZipResult::Unsupported:return "Unsupported/encrypted ZIP";
 case ZipResult::Corrupt:return "ZIP is damaged or CRC failed";
 case ZipResult::Io:return "ZIP SD read failed";
 case ZipResult::TooLarge:return "ZIP ROM exceeds 64 MiB";
 default:return "";
}}
ZipResult inspect_zip_rom(ZipIO&io,unsigned core,ZipMember&selected){
 const uint32_t size=io.size();if(size<22)return ZipResult::Corrupt;if(size>ZipRomLimit)return ZipResult::TooLarge;
 uint8_t block[533];uint32_t eocd=0;bool found=false;const uint32_t minimum=size>65557?size-65557:0;
 for(uint32_t end=size;;){uint32_t start=end>533?end-533:0;start=std::max(start,minimum);unsigned n=end-start;if(!io.read(start,block,n))return ZipResult::Io;
  for(int i=int(n)-22;i>=0;--i)if(u32(block+i)==0x06054b50&&uint32_t(i)+22+u16(block+i+20)==size-start){eocd=start+i;found=true;break;}
  if(found||start==minimum)break;end=start+21;
 }
 if(!found)return ZipResult::Corrupt;
 uint8_t end[22];if(!io.read(eocd,end,sizeof end))return ZipResult::Io;
 const unsigned count=u16(end+10);const uint32_t bytes=u32(end+12),directory=u32(end+16);
 if(u16(end+4)||u16(end+6)||u16(end+8)!=count||count==65535||count>4096||directory==0xffffffffu||bytes==0xffffffffu)return ZipResult::Unsupported;
 if(directory>eocd||bytes>eocd-directory||directory+bytes!=eocd)return ZipResult::Corrupt;
 selected=ZipMember{};unsigned matches=0;uint32_t position=directory;
 for(unsigned i=0;i<count;++i){
  uint8_t h[46];if(position>eocd||eocd-position<46)return ZipResult::Corrupt;if(!io.read(position,h,sizeof h))return ZipResult::Io;if(u32(h)!=0x02014b50)return ZipResult::Corrupt;
  const unsigned name_length=u16(h+28),extra=u16(h+30),comment=u16(h+32);uint32_t length=46u+name_length+extra+comment;
  if(!name_length||length>eocd-position)return ZipResult::Corrupt;
  if(name_length<sizeof selected.name){char name[256]{};if(!io.read(position+46,reinterpret_cast<uint8_t*>(name),name_length))return ZipResult::Io;
   if(std::memchr(name,0,name_length))return ZipResult::Corrupt;
   const char*base=std::strrchr(name,'/');base=base?base+1:name;
   if(*base&&*base!='.'&&std::strncmp(name,"__MACOSX/",9)&&matching(base,core)){
    if(!safe_name(name)||(u32(h+38)>>16&0170000)==0120000)return ZipResult::Unsupported;
    if(++matches>1)return ZipResult::MultipleRoms;
    std::strcpy(selected.name,name);selected.flags=u16(h+8);selected.method=u16(h+10);selected.crc=u32(h+16);selected.packed=u32(h+20);selected.unpacked=u32(h+24);selected.local=u32(h+42);
    if(u16(h+34)||selected.flags&~uint16_t(0x080e)|| (selected.method!=0&&selected.method!=8))return ZipResult::Unsupported;
    if(!selected.unpacked||selected.unpacked>ZipRomLimit||selected.packed==0xffffffffu)return ZipResult::TooLarge;
   }
  }else return ZipResult::Unsupported;
  position+=length;
 }
 if(position!=eocd)return ZipResult::Corrupt;if(!matches)return ZipResult::NoRom;
 uint8_t local[30];if(selected.local>directory||directory-selected.local<30)return ZipResult::Corrupt;
 if(!io.read(selected.local,local,sizeof local))return ZipResult::Io;
 const unsigned name_length=u16(local+26),extra=u16(local+28);const uint32_t header=30u+name_length+extra;
 if(u32(local)!=0x04034b50||u16(local+6)!=selected.flags||u16(local+8)!=selected.method||header>directory-selected.local||name_length!=std::strlen(selected.name))return ZipResult::Corrupt;
 char name[256];if(!io.read(selected.local+30,reinterpret_cast<uint8_t*>(name),name_length))return ZipResult::Io;
 if(std::memcmp(name,selected.name,name_length))return ZipResult::Corrupt;
 if(!(selected.flags&8)&&(u32(local+14)!=selected.crc||u32(local+18)!=selected.packed||u32(local+22)!=selected.unpacked))return ZipResult::Corrupt;
 uint32_t data=selected.local+header;if(selected.packed>directory-data)return ZipResult::Corrupt;
 if(!selected.method&&selected.packed!=selected.unpacked)return ZipResult::Corrupt;
 selected.data=data;return ZipResult::Ok;
}
ZipResult extract_zip_rom(ZipIO&io,unsigned core){
 ZipMember selected;const auto inspected=inspect_zip_rom(io,core,selected);if(inspected!=ZipResult::Ok)return inspected;
 uint8_t block[512];const uint32_t data=selected.data;
 const char*base=std::strrchr(selected.name,'/');base=base?base+1:selected.name;
 if(!io.begin(base,selected.unpacked,selected.crc))return ZipResult::Io;
 Stream stream{io,data,selected.packed,0,selected.unpacked};bool ok=true;
 if(selected.method==8)ok=tinf_stream(&stream,Stream::read,Stream::write,selected.unpacked)==0;
 else for(uint32_t offset=0;offset<selected.unpacked&&ok;){unsigned n=std::min<uint32_t>(512,selected.unpacked-offset);if(!io.read(data+offset,block,n)){stream.failed=true;ok=false;}else ok=Stream::write(&stream,block,n);offset+=n;}
 if(stream.failed){io.abort();return ZipResult::Io;}
 if(!ok||stream.produced!=selected.unpacked||(stream.crc^~0u)!=selected.crc||(selected.method==8&&(stream.remaining||stream.index!=stream.available))){io.abort();return ZipResult::Corrupt;}
 if(!io.finish()){io.abort();return ZipResult::Io;}
 return ZipResult::Ok;
}
}
