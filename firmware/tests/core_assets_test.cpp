#define TANG_NANO20K
#define NANOBLAST_CORE_ASSETS_HOST_TEST
#include "../ui/core_assets.cpp"
#include <cassert>
#include <vector>
#include <map>
#include <set>
const char *drv="sd:";
std::map<std::string,std::vector<uint8_t>> files;
std::set<std::string> directories;
std::vector<uint8_t> flash(0x400000,255);
unsigned reads=0,writes=0;bool short_write=false,bad_rename=false,flash_error=false;
FRESULT f_open(FIL*f,const char*n,unsigned mode){
 if(mode&FA_CREATE_NEW){if(files.count(n))return FR_EXIST;files[n]={};}
 else if(!files.count(n))return FR_NO_FILE;
 f->path=n;f->position=0;return FR_OK;
}
FRESULT f_close(FIL*){return FR_OK;}
FRESULT f_stat(const char*n,FILINFO*i){if(!files.count(n))return FR_NO_FILE;i->fsize=files[n].size();return FR_OK;}
FRESULT f_read(FIL*f,void*p,unsigned n,UINT*got){auto &v=files[f->path];*got=std::min(n,unsigned(v.size()-f->position));std::memcpy(p,v.data()+f->position,*got);f->position+=*got;reads+=*got;return FR_OK;}
FRESULT f_write(FIL*f,const void*p,unsigned n,UINT*got){auto &v=files[f->path];*got=short_write?n-1:n;v.insert(v.end(),static_cast<const uint8_t*>(p),static_cast<const uint8_t*>(p)+*got);writes+=*got;return FR_OK;}
FRESULT f_sync(FIL*){return FR_OK;}
FRESULT f_mkdir(const char*n){return directories.insert(n).second?FR_OK:FR_EXIST;}
FRESULT f_rename(const char*a,const char*b){if(bad_rename||files.count(b)||!files.count(a))return FR_DISK_ERR;files[b]=files[a];files.erase(a);return FR_OK;}
FRESULT f_unlink(const char*n){return files.erase(n)?FR_OK:FR_NO_FILE;}
uint32_t f_size(FIL*f){return files[f->path].size();}
uint32_t bflb_flash_get_size(){return flash.size();}
int bflb_flash_read(uint32_t a,void*p,unsigned n){if(flash_error||a+n>flash.size())return 1;std::memcpy(p,flash.data()+a,n);return 0;}
void overlay_clear(){}void overlay_status(const char*,...){}
void put32(unsigned a,uint32_t v){for(unsigned i=0;i<4;i++)flash[a+i]=v>>(8*i);}
void seed(unsigned index){unsigned base=slots[index];std::memcpy(flash.data()+base,"NBCORE01",8);put32(base+8,ids[index]);put32(base+12,907418);put32(base+20,0x4b30324e);
 for(unsigned i=0;i<907418;i++)flash[base+4096+i]=uint8_t((i*13)^(i>>8)^ids[index]);
 put32(base+16,crc(0xffffffffu,flash.data()+base+4096,907418)^0xffffffffu);
}
int main(){
 assert(std::string(nanoblast_core_setup_status())=="Core images unavailable");
 seed(0);seed(1);seed(2);
 assert(std::string(nanoblast_core_setup_status())=="NES/SMS/SNES images present"&&files.empty());
 flash.assign(0x400000,255);
 assert((crc(0xffffffffu,reinterpret_cast<const uint8_t*>("123456789"),9)^0xffffffffu)==0xcbf43926);
 nanoblast_prepare_cores();assert(!nanoblast_core_path(1)&&!nanoblast_core_path(5)&&files.empty());
 seed(0);seed(1);auto original_flash=flash;files["sd:my-games/keep.sms"]={7,8,9};
 nanoblast_prepare_cores();assert(nanoblast_core_path(1)&&nanoblast_core_path(5));
 auto nes=std::string(nanoblast_core_path(1)),sms=std::string(nanoblast_core_path(5));
 assert(files[nes].size()==907418&&files[sms].size()==907418&&files["sd:my-games/keep.sms"]==std::vector<uint8_t>({7,8,9}));
 reads=0;writes=0;nanoblast_prepare_cores();assert(reads==48&&writes==0); // markers avoid 1.8MiB SD reads on every boot
 flash[slots[1]+4096]^=1;nanoblast_prepare_cores();assert(nanoblast_core_path(1)&&!nanoblast_core_path(5));flash=original_flash;
 files.clear();directories.clear();files["sd:unrelated.tmp"]={99};short_write=true;
 nanoblast_prepare_cores();assert(!nanoblast_core_path(1)&&!nanoblast_core_path(5)&&files.size()==1&&files.begin()->second[0]==99);
 short_write=false;bad_rename=true;nanoblast_prepare_cores();assert(files.size()==1&&!nanoblast_core_path(5));bad_rename=false;
 nanoblast_prepare_cores();assert(nanoblast_core_path(1)&&nanoblast_core_path(5));
 flash_error=true;nanoblast_prepare_cores();assert(!nanoblast_core_path(1)&&!nanoblast_core_path(5));flash_error=false;
 // Availability never writes SD or provisions a core. Only the explicit
 // selection prepares that one image and its original diagnostic ROM.
 files.clear();directories.clear();writes=0;
 assert(nanoblast_core_asset_available(1)&&nanoblast_core_asset_available(5)&&!nanoblast_core_asset_available(9)&&writes==0);
 assert(nanoblast_prepare_core(5)&&nanoblast_core_path(5));
 assert(files["sd:sms/NANOBLAST-Test.sms"]==std::vector<uint8_t>(sms_test_rom,sms_test_rom+sizeof sms_test_rom));
 assert(!files.count("sd:cores/nano20k/nes-"));
 files["sd:sms/NANOBLAST-Test.sms"]={42};
 assert(nanoblast_prepare_core(5)&&files["sd:sms/NANOBLAST-Test.sms"]==std::vector<uint8_t>({42}));
 assert(std::string(nanoblast_core_setup_status())=="SMS ready; test ROM copy failed");
 assert(flash==original_flash); // asset provisioning is flash-read-only
 // The user-file transfer is idle when blank and copies only on explicit Games.
 files.clear();writes=0;assert(nanoblast_import_game()&&writes==0);
 const unsigned transfer=0x1df000,payload=transfer+4096;
 std::memcpy(flash.data()+transfer,"NBFILE01",8);
 put32(transfer+8,131072);
 std::memset(flash.data()+transfer+16,0,96);
 std::strcpy(reinterpret_cast<char*>(flash.data()+transfer+16),"sms/Alex Kidd in Miracle World (USA) (Rev-A).sms");
 for(unsigned i=0;i<131072;i++)flash[payload+i]=uint8_t(i^(i>>10));
 put32(transfer+12,crc(0xffffffffu,flash.data()+payload,131072)^0xffffffffu);
 auto transfer_flash=flash;const std::string game="sd:sms/Alex Kidd in Miracle World (USA) (Rev-A).sms";
 assert(nanoblast_import_game());
 assert(files[game]==std::vector<uint8_t>(flash.begin()+payload,flash.begin()+payload+131072));
 writes=0;assert(nanoblast_import_game()&&writes==0); // verified existing copy
 files[game]={99};assert(!nanoblast_import_game()&&files[game]==std::vector<uint8_t>({99}));
 files.clear();short_write=true;assert(!nanoblast_import_game()&&files.empty());short_write=false;
 bad_rename=true;assert(!nanoblast_import_game()&&files.empty());bad_rename=false;
 flash[payload]^=1;assert(!nanoblast_import_game()&&files.empty());flash=transfer_flash;
 std::strcpy(reinterpret_cast<char*>(flash.data()+transfer+16),"sms/../keep.sms");
 assert(!nanoblast_import_game()&&files.empty());flash=transfer_flash;
 std::memset(flash.data()+transfer+16,'x',96);assert(!nanoblast_import_game()&&files.empty());flash=transfer_flash;
 put32(transfer+8,131073);assert(!nanoblast_import_game()&&files.empty());flash=transfer_flash;
 flash_error=true;assert(!nanoblast_import_game());flash_error=false;
 assert(flash==transfer_flash); // transfer never writes BL616 flash
 // SNES provisioning is explicit and uses its own immutable flash slot.
 seed(2);const auto with_snes=flash;files.clear();writes=0;
 assert(nanoblast_core_asset_available(2)&&writes==0);
 assert(nanoblast_prepare_core(2)&&nanoblast_core_path(2));
 const std::string snes=nanoblast_core_path(2);
 assert(snes.find("/snes-")!=std::string::npos&&files[snes].size()==907418&&flash==with_snes);
 assert(!files.count("sd:sms/NANOBLAST-Test.sms"));
 files.clear();writes=0;const auto before_gb=flash;
 files["sd:gb/NANOBLAST Test.gb"]={42,43};
 assert(nanoblast_prepare_gb_game()&&files["sd:gb/NANOBLAST DMG Test.gb"].size()==32768&&flash==before_gb);
 assert(files["sd:gb/NANOBLAST Test.gb"]==std::vector<uint8_t>({42,43}));
 const auto installed=files["sd:gb/NANOBLAST DMG Test.gb"];assert(installed[0x104]==0xce&&installed[0x133]==0x3e);unsigned old_writes=writes;
 assert(nanoblast_prepare_gb_game()&&files["sd:gb/NANOBLAST DMG Test.gb"]==installed&&writes==old_writes);
 files["sd:gb/NANOBLAST DMG Test.gb"]={1,2,3};assert(nanoblast_prepare_gb_game()&&files["sd:gb/NANOBLAST DMG Test.gb"]==std::vector<uint8_t>({1,2,3}));
 files.clear();short_write=true;assert(!nanoblast_prepare_gb_game()&&!files.count("sd:gb/NANOBLAST DMG Test.gb"));short_write=false;
 return 0;
}
