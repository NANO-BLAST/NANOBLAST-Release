// The runner inserts the actual production joy_choice function below.
#include <cassert>
#include <cstdint>
#include <string>
#include <vector>
uint16_t buttons=0;int enabled=1;unsigned hid_updates=0,wait_ms=0,status_writes=0,cursor_writes=0;
std::vector<std::string> glyphs;
void get_joypad_states(uint16_t*a,uint16_t*b,uint16_t*c,uint16_t*d){*a=buttons;*b=*c=*d=0;}
void overlay_status(const char*,...){++status_writes;}
int overlay_on(){return enabled;}
void overlay(int value){enabled=value;}
void delay(int ms){wait_ms+=ms;}
void send_hid_to_core(){++hid_updates;}
void overlay_cursor(int,int){++cursor_writes;}
void overlay_printf(const char *value){glyphs.emplace_back(value);}
// JOY_CHOICE_UNDER_TEST
int main(){
 int active=0;buttons=0x20;
 assert(joy_choice(3,3,&active,0x84,false)==0&&active==1&&wait_ms==0);
 assert(cursor_writes==0&&glyphs.empty());
 buttons=0;assert(joy_choice(3,3,&active,0x84,false)==0&&glyphs.empty());
 buttons=0x100;assert(joy_choice(3,3,&active,0x84,false)==4);
 buttons=1;assert(joy_choice(3,3,&active,0x84,false)==1);
 buttons=0x80;assert(joy_choice(3,3,&active,0x84,false)==2);
 buttons=0x40;assert(joy_choice(3,3,&active,0x84,false)==3);
 assert(cursor_writes==0&&glyphs.empty());
 buttons=0x10;assert(joy_choice(3,3,&active,0x84,true)==0&&active==0);
 assert(cursor_writes==2&&glyphs.size()==2&&glyphs[0]==">"&&glyphs[1]==" ");
 assert(wait_ms==100);
 cursor_writes=0;glyphs.clear();buttons=0x84;
 assert(joy_choice(3,3,&active,0x84,false)==0&&!enabled&&hid_updates==1);
 assert(!status_writes&&!cursor_writes&&glyphs.empty());
 buttons=0;assert(joy_choice(3,3,&active,0x84,false)==0&&hid_updates==2);
 return 0;
}
