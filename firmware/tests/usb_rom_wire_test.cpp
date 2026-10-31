// Native protocol peer for cross-language client/service integration tests.
#define main service_unit_tests
#include "usb_rom_service_test.cpp"
#undef main
#include <iostream>
int main(){
 Memory files;Service service(files);
 for(;;){uint8_t h[16];if(!std::cin.read(reinterpret_cast<char*>(h),16))break;
 unsigned n=unsigned(h[6])|(unsigned(h[7])<<8);if(n>1024||std::memcmp(h,"NBR1",4))return 2;
 uint8_t data[1024],out[1024];if(!std::cin.read(reinterpret_cast<char*>(data),n))return 3;
 auto crc=nanoblast::crc32_update(0xffffffff,h,12);crc=nanoblast::crc32_update(crc,data,n);if((crc^0xffffffff)!=get32(h+12))return 4;
 uint8_t status;unsigned len=service.request(h[4],data,n,out,status);h[5]=status;h[6]=uint8_t(len);h[7]=uint8_t(len>>8);
 crc=nanoblast::crc32_update(0xffffffff,h,12);crc=nanoblast::crc32_update(crc,out,len);put32(h+12,crc^0xffffffff);
 std::cout.write(reinterpret_cast<char*>(h),16);std::cout.write(reinterpret_cast<char*>(out),len);std::cout.flush();
 }
}
