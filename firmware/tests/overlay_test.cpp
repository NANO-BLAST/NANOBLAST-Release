#define NANOBLAST_OVERLAY_HOST_TEST
#include "../ui/overlay.cpp"
#include <cassert>
#include <vector>
struct Packet{int command;std::vector<uint8_t> data;};
std::vector<Packet> packets;
void fpga_tx_header(int command,int){packets.push_back({command,{}});}
void fpga_tx_byte(uint8_t value){packets.back().data.push_back(value);}
void delay(int){}
void get_joypad_states(uint16_t*,uint16_t*,uint16_t*,uint16_t*){}
int main(){
 overlay_game_loading(true);
 overlay_status("Loading SMS %u/%uK",16,512);
 assert(packets.size()==2&&packets[0].command==4);
 assert(packets[0].data==std::vector<uint8_t>({0,14}));
 assert(packets[1].data.size()==32);
 const std::string first(packets[1].data.begin(),packets[1].data.end());
 assert(first.find("Loading SMS 16/512K")==6);
 packets.clear();overlay_status("Done\nnot another row");
 assert(packets[1].data.size()==32);
 assert(std::string(packets[1].data.begin(),packets[1].data.end())=="              Done              ");
 packets.clear();overlay_status("%s","1234567890123456789012345678901234567890");
 assert(packets[1].data.size()==32);
 assert(std::string(packets[1].data.begin(),packets[1].data.end()).substr(3,26)=="12345678901234567890123456");
 overlay_game_loading(false);packets.clear();overlay_status("SD ready");
 assert(packets[0].data==std::vector<uint8_t>({1,27}));
 puts("PASS loading banner: centred progress row, stale text cleared, bounded text, normal status restored");
}
