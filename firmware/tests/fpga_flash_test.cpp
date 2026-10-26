#define NANOBLAST_FLASH_HOST_TEST
#include "../storage/fpga_flash.cpp"
#include <cassert>
#include <vector>
bool sem=false,drop=false,malformed=false,wrong_sequence=false;
unsigned need=0,cmd=0,packets=0;std::vector<uint8_t> outgoing;
SemaphoreHandle_t xSemaphoreCreateBinary(){return &sem;}
int xSemaphoreTake(SemaphoreHandle_t s,unsigned){if(*s){*s=false;return pdTRUE;}return 0;}
void xSemaphoreGive(SemaphoreHandle_t s){*s=true;}
void response(){
 ++packets;if(drop)return;
 if(cmd==22){fpga_flash_reply_begin(22,5);unsigned i=0;for(uint8_t v:{'N','B','F','1'})fpga_flash_reply_byte(i++,v);return;}
 unsigned n=outgoing.size()-2;
 fpga_flash_reply_begin(cmd,n+2+(malformed?1:0));
 fpga_flash_reply_byte(0,outgoing[1]^(wrong_sequence?1:0));
 for(unsigned i=0;i<n;i++)fpga_flash_reply_byte(i+1,outgoing[i+2]^0x5a);
}
void fpga_tx_header(int command,int length){cmd=command;need=length-1;outgoing.clear();if(!need)response();}
void fpga_tx_byte(uint8_t v){outgoing.push_back(v);if(outgoing.size()==need)response();}
int main(){
 fpga_flash_register();assert(fpga_flash_available());
 uint8_t tx[260],rx[260];for(unsigned i=0;i<260;i++)tx[i]=i;
 unsigned before=packets;assert(fpga_flash_transfer(false,tx,rx,260)&&packets==before+9);
 for(unsigned i=0;i<260;i++)assert(rx[i]==uint8_t(tx[i]^0x5a));
 assert(fpga_flash_transfer(true,nullptr,nullptr,0));
 malformed=true;assert(!fpga_flash_transfer(false,tx,rx,1));malformed=false;
 // A failed exchange blocks further writes until a fresh bridge handshake.
 before=packets;assert(!fpga_flash_transfer(false,tx,rx,1)&&packets==before);
 assert(fpga_flash_available());
 wrong_sequence=true;assert(!fpga_flash_transfer(false,tx,rx,1));wrong_sequence=false;
 assert(fpga_flash_available()&&fpga_flash_transfer(false,tx,rx,1));
 drop=true;assert(!fpga_flash_available());drop=false;
 assert(fpga_flash_available());
 // Stale/unexpected replies cannot satisfy a future request.
 fpga_flash_reply_begin(21,3);fpga_flash_reply_byte(0,sequence);fpga_flash_reply_byte(1,0);
 assert(!sem);
}
