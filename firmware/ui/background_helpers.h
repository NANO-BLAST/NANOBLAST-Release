// Small artwork tiles for SNES button hints. GPL-3.0.
#pragma once
#include "background_upload.h"
#include <cstdint>
#include <initializer_list>
namespace nanoblast {
#include "background_helpers.inc"
inline bool upload_button_helpers(BackgroundTransport &transport,bool visible){
 const uint8_t *tiles[]={visible?helper_0_visible:helper_0_plain,visible?helper_1_visible:helper_1_plain,visible?helper_2_visible:helper_2_plain,visible?helper_3_visible:helper_3_plain};
 const unsigned left[]={552,792,264,344};
 const unsigned width[]={36,36,80,64};
 transport.pause_scanout();
 for(uint32_t color:{0xf7b5b9c6u,0xf8e5e6edu,0xf9444b5bu})transport.palette(color);
 for(unsigned tile=0;tile<4;tile++)for(unsigned row=0;row<33;row++)
  if(!transport.pixels(0x00200000u+(670+row)*1280+left[tile],tiles[tile]+row*width[tile],width[tile])){transport.enable(true);return false;}
 transport.enable(true);
 return true;
}
}
