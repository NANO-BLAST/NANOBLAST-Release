// Add the compressed artwork without replacing existing SD files. GPL-3.0.
#pragma once
#include <cstdint>
namespace nanoblast {
enum class BackgroundInstallResult {Exists,NotApplicable,Installed,Failed};
struct BackgroundInstallIO {
 virtual ~BackgroundInstallIO()=default;
 virtual bool exists()=0;
 virtual bool matches_original(const uint8_t*,unsigned)=0;
 virtual bool begin()=0;
 virtual bool write(const uint8_t*,unsigned)=0;
 virtual bool finish()=0;
 virtual bool open_readback()=0;
 virtual bool readback(uint8_t*,unsigned)=0;
 virtual bool commit()=0;
 virtual void cancel()=0;
 virtual void progress(unsigned,unsigned){}
 virtual void mismatch(unsigned,uint8_t,uint8_t){}
};
BackgroundInstallResult install_background(BackgroundInstallIO&,const uint8_t *header,unsigned header_size,const uint8_t *data,unsigned size);
}
