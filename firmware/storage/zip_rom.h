// ZIP ROM reader. GPL-3.0; see COPYING.NANOBLAST.
#pragma once
#include <cstdint>
namespace nanoblast {
constexpr uint32_t ZipRomLimit=64u*1024*1024;
enum class ZipResult { Ok, NoRom, MultipleRoms, Unsupported, Corrupt, Io, TooLarge };
struct ZipIO {
 virtual ~ZipIO()=default;
 virtual uint32_t size()const=0;
 virtual bool read(uint32_t offset,uint8_t *data,unsigned length)=0;
 virtual bool begin(const char *name,uint32_t length,uint32_t crc)=0;
 virtual bool write(const uint8_t *data,unsigned length)=0;
 virtual bool finish()=0;
 virtual void abort()=0;
 virtual void progress(uint32_t,uint32_t){}
};
struct ZipMember {
 char name[256]{};
 uint32_t local=0,data=0,packed=0,unpacked=0,crc=0;
 uint16_t flags=0,method=0;
};
ZipResult inspect_zip_rom(ZipIO&,unsigned core,ZipMember&);
bool zip_rom_path(const char*);
ZipResult extract_zip_rom(ZipIO&,unsigned core);
const char *zip_rom_error(ZipResult);
}
