// NANOBLAST artwork streaming from MCU to FPGA. GPL-3.0.
#pragma once
#include <cstdint>
#include <cstddef>
namespace nanoblast {
struct AssetSource {virtual ~AssetSource()=default;virtual uint32_t size()=0;virtual bool read(uint8_t*,unsigned)=0;};
struct BackgroundTransport {
 virtual ~BackgroundTransport()=default;
 virtual void enable(bool)=0;
 virtual void palette(uint32_t)=0;
 virtual bool pixels(uint32_t address,const uint8_t *data,unsigned size)=0;
 virtual void progress(unsigned,unsigned)=0;
};
enum class BackgroundResult {Ready,Invalid,ReadError,TransportError};
BackgroundResult upload_background(AssetSource&,BackgroundTransport&);
}
