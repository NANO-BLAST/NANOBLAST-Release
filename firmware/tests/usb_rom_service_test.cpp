#include "../storage/usb_rom_service.h"
#include "../storage/crc32.h"
#include <cassert>
#include <cstring>
#include <vector>
#include <cstdio>
using namespace nanoblast::usbrom;
struct Memory:Files {
 std::vector<uint8_t> temp,rom;bool active=false,exists=false,fail_write=false,fail_verify=false;
 bool list(const char*,uint32_t i,Entry&e,bool&end)override{end=i>0;if(!end){std::strcpy(e.name,"test.nes");e.size=rom.size();}return true;}
 bool begin(const char*,uint32_t)override{if(exists)return false;temp.clear();active=true;return true;}
 bool append(const uint8_t*d,unsigned n)override{if(fail_write)return false;temp.insert(temp.end(),d,d+n);return true;}
 bool commit(uint32_t n,uint32_t crc)override{if(fail_verify||temp.size()!=n||(nanoblast::crc32_update(0xffffffff,temp.data(),temp.size())^0xffffffff)!=crc)return false;rom=temp;exists=true;active=false;return true;}
 void abort()override{temp.clear();active=false;}
};
int main(){
 for(auto p:{"nes/a.nes","sms/sub/a.gg","gb/a.gbc","snes/a.sfc","sms/X-Men - Mojo World (Brazil).sms","sms/Regions (Brazil)/a.sms","sms/Game (USA).zip"})assert(valid_path(p,true));
 for(auto p:{"../a.nes","nes/../a.nes","gb/saves/a.gb","gb/SAVES/a.gb","nes/.hidden.nes","nes/a.gbc","nes/a.nes:evil","nes/a./a.nes","nes//a.nes","nes/a.nes/","nanoblast/a.nes","NES/a.nes"})assert(!valid_path(p,true));
 Memory f;Service s(f);uint8_t response[1024],status=0;uint8_t begin[64]{};
 assert(s.request(2,begin,4,response,status)==0&&status==2);
 assert(s.request(1,nullptr,0,response,status)==15&&!status);
 const uint8_t rom[]={1,2,3,4};put32(begin,4);put32(begin+4,nanoblast::crc32_update(0xffffffff,rom,4)^0xffffffff);std::memcpy(begin+8,"nes/a.nes",9);
 s.request(3,begin,17,response,status);assert(!status&&f.active);
 uint8_t chunk[8]{};std::memcpy(chunk+4,rom,4);put32(chunk,1);s.request(4,chunk,8,response,status);assert(status==1&&f.temp.empty());
 put32(chunk,0);s.request(4,chunk,8,response,status);assert(!status&&get32(response)==4);
 s.request(5,nullptr,0,response,status);assert(!status&&f.rom.size()==4&&!f.active);
 s.request(3,begin,17,response,status);assert(status==3&&f.rom.size()==4);
 f.exists=false;s.request(3,begin,17,response,status);s.disconnect();assert(!f.active&&f.rom.size()==4);
 s.request(1,nullptr,0,response,status);s.request(3,begin,17,response,status);s.request(5,nullptr,0,response,status);assert(status==4&&!f.active);
 s.request(3,begin,17,response,status);f.fail_write=true;s.request(4,chunk,8,response,status);assert(status==3&&!f.active);f.fail_write=false;
 s.request(3,begin,17,response,status);s.request(4,chunk,8,response,status);f.fail_verify=true;s.request(5,nullptr,0,response,status);assert(status==3&&!f.active);
 puts("USB service tests passed: path restrictions, handshake, offsets, commit, duplicates, disconnect, short upload, disk failure, readback failure");
 return 0;
}
