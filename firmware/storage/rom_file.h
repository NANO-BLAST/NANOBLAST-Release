// A read-only ROM file, raw or streamed from a ZIP member. GPL-3.0.
#pragma once
#include <cstdint>
#if (defined(NANOBLAST_NES_LOADER_HOST_TEST) || defined(NANOBLAST_SMS_LOADER_HOST_TEST) || defined(NANOBLAST_GB_LOADER_HOST_TEST) || defined(NANOBLAST_SNES_LOADER_HOST_TEST)) && !defined(NANOBLAST_ROM_READER_INTEGRATION)
#include "../tests/rom_reader_platform.h"
#else
class RomFile {
 struct Impl;Impl *impl_=nullptr;
public:
 RomFile()=default;
 ~RomFile();
 RomFile(const RomFile&)=delete;RomFile&operator=(const RomFile&)=delete;
 int open(const char *path,unsigned core);
 int read(void *data,unsigned length,unsigned *got);
 int seek(uint32_t position);
 int close();
 uint32_t size()const;
 const char *name()const;
 const char *error()const;
 bool is_zip()const;
};
#endif
