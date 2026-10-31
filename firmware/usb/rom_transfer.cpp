// GPL-3.0; CDC descriptor layout follows CherryUSB (Apache-2.0).
#include "rom_transfer.h"
#include "usb_rom_service.h"
#include "usb_rom_fatfs.h"
#include "crc32.h"
#include "utils.h"
extern "C" {
#include "usbd_core.h"
#include "usbd_cdc.h"
#include "usbh_core.h"
#include "hardware/usb_v2_reg.h"
#include "hardware/pds_reg.h"
}
#include <cstring>
#include <new>
using namespace nanoblast::usbrom;
namespace {
// Development-only IDs. A distributed release requires allocated USB VID/PID.
const uint8_t descriptors[]={
 USB_DEVICE_DESCRIPTOR_INIT(USB_2_0,0xEF,0x02,0x01,0xFFFF,0x4E42,0x0100,0x01),
 USB_CONFIG_DESCRIPTOR_INIT((9+CDC_ACM_DESCRIPTOR_LEN),0x02,0x01,USB_CONFIG_BUS_POWERED,100),
 CDC_ACM_DESCRIPTOR_INIT(0,0x83,0x02,0x81,64,0x02),
 USB_LANGID_INIT(1033),
20, USB_DESCRIPTOR_TYPE_STRING, 78, 0, 97, 0, 110, 0, 111, 0, 66, 0, 108, 0, 97, 0, 115, 0, 116, 0,
46, USB_DESCRIPTOR_TYPE_STRING, 78, 0, 97, 0, 110, 0, 111, 0, 66, 0, 108, 0, 97, 0, 115, 0, 116, 0, 32, 0, 82, 0, 79, 0, 77, 0, 32, 0, 84, 0, 114, 0, 97, 0, 110, 0, 115, 0, 102, 0, 101, 0, 114, 0,
18, USB_DESCRIPTOR_TYPE_STRING, 78, 0, 66, 0, 82, 0, 79, 0, 77, 0, 48, 0, 48, 0, 49, 0,
 0};
USB_NOCACHE_RAM_SECTION USB_MEM_ALIGNX uint8_t rx[64];
USB_NOCACHE_RAM_SECTION USB_MEM_ALIGNX uint8_t tx[MaxPayload+16];
volatile unsigned ready=0;volatile bool configured=false,tx_busy=false,reset=false;
void received(uint8_t,uint32_t n){if(n)ready=n;else usbd_ep_start_read(0x02,rx,sizeof rx);}
void sent(uint8_t,uint32_t n){if(n&&n%64==0)usbd_ep_start_write(0x81,nullptr,0);else tx_busy=false;}
usbd_endpoint out_ep={0x02,received},in_ep={0x81,sent};
usbd_interface intf0,intf1;
bool send(uint8_t op,uint32_t seq,uint8_t status,const uint8_t*payload,unsigned n){
 std::memcpy(tx,"NBR1",4);tx[4]=op;tx[5]=status;tx[6]=uint8_t(n);tx[7]=uint8_t(n>>8);put32(tx+8,seq);
 std::memcpy(tx+16,payload,n);uint32_t crc=nanoblast::crc32_update(0xffffffff,tx,12);crc=nanoblast::crc32_update(crc,tx+16,n);put32(tx+12,crc^0xffffffff);
 tx_busy=true;if(usbd_ep_start_write(0x81,tx,n+16)<0){tx_busy=false;return false;}
 auto started=bflb_mtimer_get_time_ms();while(tx_busy&&configured&&!reset){if(bflb_mtimer_get_time_ms()-started>5000)return false;delay(1);}return configured&&!reset;
}
}
extern "C" void usbd_event_handler(uint8_t event){
 if(event==USBD_EVENT_CONFIGURED){configured=true;ready=0;usbd_ep_start_read(0x02,rx,sizeof rx);}
 if(event==USBD_EVENT_RESET||event==USBD_EVENT_DISCONNECTED){configured=false;reset=true;ready=0;tx_busy=false;}
}
void nanoblast_usb_rom_transfer(){
 // Called synchronously from the menu task only after save flushing. The menu,
 // game loading and periodic save/clock services cannot run until reboot.
 usbh_deinitialize();
 // The BL616 SDK host initialization clears IDDIG and requests the A-device
 // bus. usb_dc_init() does not undo either setting. Release host ownership and
 // explicitly select the B-device role before starting CDC on this controller.
 bflb_irq_disable(37);
 constexpr uintptr_t UsbBase=0x20072000,PdsBase=0x2000e000;
 auto bus=getreg32(UsbBase+USB_OTG_CSR_OFFSET);
 putreg32((bus|USB_A_BUS_DROP_HOV)&~USB_A_BUS_REQ_HOV,UsbBase+USB_OTG_CSR_OFFSET);
 auto control=getreg32(PdsBase+PDS_USB_CTL_OFFSET);
 putreg32(control|PDS_REG_USB_IDDIG_MSK,PdsBase+PDS_USB_CTL_OFFSET);
 delay(100);
 usbd_desc_register(descriptors);usbd_add_interface(usbd_cdc_acm_init_intf(&intf0));usbd_add_interface(usbd_cdc_acm_init_intf(&intf1));
 usbd_add_endpoint(&out_ep);usbd_add_endpoint(&in_ep);usbd_initialize();
 alignas(FatFiles) static uint8_t storage[sizeof(FatFiles)];
 auto &files=*new(storage) FatFiles;Service service(files);static uint8_t frame[MaxPayload+16],reply[MaxPayload];
 unsigned used=0;uint64_t last=bflb_mtimer_get_time_ms();
 for(;;){
  if(reset||bflb_mtimer_get_time_ms()-last>60000){service.disconnect();used=0;reset=false;last=bflb_mtimer_get_time_ms();}
  if(!configured||!ready){delay(1);continue;}
  unsigned count=ready;
  for(unsigned i=0;i<count;i++){
   if(reset||!configured)break;
   frame[used++]=rx[i];last=bflb_mtimer_get_time_ms();
   if(used<=4&&frame[used-1]!=uint8_t("NBR1"[used-1])){used=0;continue;}
   if(used<16)continue;
   unsigned n=unsigned(frame[6])|(unsigned(frame[7])<<8);
   if(n>MaxPayload||frame[5]){service.disconnect();used=0;continue;}
   if(used!=16+n)continue;
   uint32_t crc=nanoblast::crc32_update(0xffffffff,frame,12);crc=nanoblast::crc32_update(crc,frame+16,n);
   uint8_t status=0;unsigned len=0;
   if((crc^0xffffffff)!=get32(frame+12)){status=4;service.disconnect();}
   else len=service.request(frame[4],frame+16,n,reply,status);
   if(!send(frame[4],get32(frame+8),status,reply,len)){service.disconnect();usbd_deinitialize();for(;;)delay(100);}
   used=0;
  }
  ready=0;if(configured&&!reset)usbd_ep_start_read(0x02,rx,sizeof rx);
 }
}
