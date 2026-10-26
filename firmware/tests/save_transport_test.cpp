#define NANOBLAST_GB_TRANSPORT_HOST_TEST
#include "../storage/gb_save_transport.cpp"
#include <cassert>
#include <vector>
#include <iostream>
std::vector<uint8_t> sent;
unsigned command=0,frame_length=0,result_bytes=0;
bool bad_crc=false,bad_sequence=false,error_status=false,truncate=false;
SemaphoreHandle_t xSemaphoreCreateBinary(){static Semaphore sem;return &sem;}
void xSemaphoreGive(SemaphoreHandle_t sem){sem->count++;}
void fpga_tx_header(unsigned cmd,unsigned len){command=cmd;frame_length=len;sent.clear();}
void fpga_tx_byte(uint8_t v){sent.push_back(v);}
int xSemaphoreTake(SemaphoreHandle_t sem,unsigned timeout){
 if(sem->count){sem->count--;return pdTRUE;}if(!timeout)return 0;
 assert(command==0x18&&sent.size()+1==frame_length);
 const unsigned n=sent.size();const auto crc=nanoblast::crc32_update(~0u,sent.data(),n-4)^~0u;
 assert(crc==(uint32_t(sent[n-4])<<24|uint32_t(sent[n-3])<<16|uint32_t(sent[n-2])<<8|sent[n-1]));
 std::vector<uint8_t> response={sent[1],uint8_t(sent[2]+bad_sequence),uint8_t(error_status)};
 for(unsigned i=0;i<result_bytes;i++)response.push_back(i);
 const auto rcrc=(nanoblast::crc32_update(~0u,response.data(),response.size())^~0u)^bad_crc;
 for(unsigned i=0;i<4;i++)response.push_back(rcrc>>(24-8*i));
 gb_save_reply_begin(response.size()+1);
 for(unsigned i=0;i<response.size()-truncate;i++)gb_save_reply_byte(i,response[i]);
 if(sem->count){sem->count--;return pdTRUE;}return 0;
}
int main(){
 uint8_t out[256],data[256];for(unsigned i=0;i<256;i++)data[i]=255-i;
 result_bytes=256;assert(gb_save_request(2,0,256,nullptr,out,256));for(unsigned i=0;i<256;i++)assert(out[i]==i);
 result_bytes=0;assert(gb_save_request(3,0,256,data,nullptr,0));assert(sent.size()==268&&sent[8]==255&&sent[263]==0);
 bad_crc=true;assert(!gb_save_request(5,0,0,nullptr,nullptr,0));bad_crc=false;
 bad_sequence=true;assert(!gb_save_request(5,0,0,nullptr,nullptr,0));bad_sequence=false;
 error_status=true;assert(!gb_save_request(5,0,0,nullptr,nullptr,0));error_status=false;
 truncate=true;assert(!gb_save_request(5,0,0,nullptr,nullptr,0));truncate=false;
 assert(gb_save_request(5,0,0,nullptr,nullptr,0));
 result_bytes=12;assert(!gb_save_request(1,0,0,nullptr,out,8));assert(gb_save_request(1,0,0,nullptr,out,12));
 assert(!gb_save_request(2,0,257,nullptr,out,256));
 std::cout<<"PASS save UART client: full pages, CRC, sequence, timeout, status and reply bounds\n";
}
