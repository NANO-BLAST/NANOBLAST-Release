#include "rom_file.h"
#include "zip_rom.h"
#include "tinf/tinf_stream.h"
#include "ff.h"
#include <algorithm>
#include <cstring>
#include <new>
#include <string>

struct RomFile::Impl: nanoblast::ZipIO {
 FIL file{};bool opened=false,zip=false,failed=false;
 nanoblast::ZipMember member{};
 std::string filename;
 const char*message="ROM read failed";
 tinf_reader*decoder=nullptr;
 uint32_t logical=0,decoded=0,input_offset=0,remaining=0;
 uint8_t input[512]{},prefix[512]{};
 unsigned input_position=0,input_length=0,prefix_length=0;
 ~Impl(){if(decoder)tinf_reader_close(decoder);if(opened)f_close(&file);}
 uint32_t size()const override{return opened?f_size(&file):0;}
 bool read(uint32_t offset,uint8_t*data,unsigned n)override{
  if(!opened||f_lseek(&file,offset)!=FR_OK)return false;
  // The bundled SDK's modified FatFs can reuse the previous cluster for the
  // tail of an unaligned multi-sector read. ZIP payloads need not be aligned.
  while(n){UINT got=0;unsigned length=std::min(512u,n);if(f_read(&file,data,length,&got)!=FR_OK||got!=length)return false;data+=length;n-=length;}
  return true;
 }
 // Metadata inspection never opens or writes an extracted destination.
 bool begin(const char*,uint32_t,uint32_t)override{return false;}
 bool write(const uint8_t*,unsigned)override{return false;}
 bool finish()override{return false;}
 void abort()override{}
 static int byte(void*context){
  auto&self=*static_cast<Impl*>(context);
  if(self.input_position==self.input_length){
   if(!self.remaining)return -1;unsigned n=std::min<uint32_t>(512,self.remaining);
   if(!self.read(self.input_offset,self.input,n)){self.failed=true;return -1;}
   self.input_offset+=n;self.remaining-=n;self.input_position=0;self.input_length=n;
  }
  return self.input[self.input_position++];
 }
 bool restart(){
  if(decoder){tinf_reader_close(decoder);decoder=nullptr;}
  decoded=0;remaining=member.packed;input_offset=member.data;input_position=input_length=0;
  if(member.method==8){decoder=tinf_reader_open(this,byte,member.unpacked);if(!decoder){message="Not enough ZIP decode memory";return false;}}
  return true;
 }
 bool decode(uint8_t*data,unsigned n){
  if(n>member.unpacked-decoded)return false;
  if(member.method==8){if(tinf_reader_read(decoder,data,n)!=int(n)){message=failed?"ZIP SD read failed":"Invalid ZIP data";failed=true;return false;}}
  else if(!read(member.data+decoded,data,n)){failed=true;return false;}
  if(decoded<sizeof prefix){unsigned count=std::min<unsigned>(n,sizeof prefix-decoded);std::memcpy(prefix+decoded,data,count);prefix_length=std::max<unsigned>(prefix_length,decoded+count);}
  decoded+=n;return true;
 }
 bool move_decoder(uint32_t position){
  if(position<decoded&&!restart())return false;
  uint8_t scratch[512];
  while(decoded<position){unsigned n=std::min<uint32_t>(sizeof scratch,position-decoded);if(!decode(scratch,n))return false;}
  return true;
 }
};
RomFile::~RomFile(){close();delete impl_;}
int RomFile::open(const char*path,unsigned core){
 close();delete impl_;impl_=new(std::nothrow) Impl;if(!impl_)return FR_NOT_ENOUGH_CORE;
 auto&s=*impl_;s.zip=nanoblast::zip_rom_path(path);s.filename=path;
 auto result=f_open(&s.file,path,FA_READ);if(result!=FR_OK)return result;s.opened=true;
 if(!s.zip)return FR_OK;
 const auto inspected=nanoblast::inspect_zip_rom(s,core,s.member);
 if(inspected!=nanoblast::ZipResult::Ok){s.message=nanoblast::zip_rom_error(inspected);return FR_INVALID_OBJECT;}
 const char*base=std::strrchr(s.member.name,'/');s.filename=base?base+1:s.member.name;
 return s.restart()?FR_OK:FR_NOT_ENOUGH_CORE;
}
int RomFile::read(void*data,unsigned length,unsigned*got){
 *got=0;if(!impl_||!impl_->opened)return FR_INVALID_OBJECT;auto&s=*impl_;
 if(!s.zip)return f_read(&s.file,data,length,got);
 if(s.failed)return FR_DISK_ERR;
 length=std::min<uint32_t>(length,s.member.unpacked-s.logical);auto*out=static_cast<uint8_t*>(data);
 if(s.logical<s.prefix_length){unsigned n=std::min<uint32_t>(length,s.prefix_length-s.logical);std::memcpy(out,s.prefix+s.logical,n);s.logical+=n;*got=n;out+=n;length-=n;}
 if(length){if(!s.move_decoder(s.logical)||!s.decode(out,length))return FR_DISK_ERR;s.logical+=length;*got+=length;}
 return FR_OK;
}
int RomFile::seek(uint32_t position){
 if(!impl_||!impl_->opened)return FR_INVALID_OBJECT;auto&s=*impl_;
 if(!s.zip)return f_lseek(&s.file,position);
 if(position>s.member.unpacked)return FR_INVALID_PARAMETER;s.logical=position;return FR_OK;
}
int RomFile::close(){
 if(!impl_||!impl_->opened)return FR_OK;auto&s=*impl_;int result=FR_OK;
 if(s.zip&&s.decoder){
  // Validate Deflate framing at EOF, without an additional CRC scan/pass.
  if(s.decoded==s.member.unpacked&&
     (tinf_reader_finish(s.decoder)!=0||s.remaining||s.input_position!=s.input_length))result=FR_INVALID_OBJECT;
  tinf_reader_close(s.decoder);s.decoder=nullptr;
 }
 if(s.failed)result=FR_DISK_ERR;
 auto closed=f_close(&s.file);s.opened=false;return result==FR_OK?closed:result;
}
uint32_t RomFile::size()const{return impl_?(impl_->zip?impl_->member.unpacked:impl_->size()):0;}
const char*RomFile::name()const{return impl_?impl_->filename.c_str():"";}
const char*RomFile::error()const{return impl_?impl_->message:"Not enough ROM memory";}
bool RomFile::is_zip()const{return impl_&&impl_->zip;}
