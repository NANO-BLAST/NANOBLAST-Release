// Small artwork tiles for SNES button hints. GPL-3.0.
#pragma once
#include "background_upload.h"
#include <cstdint>
namespace nanoblast {
#include "background_helpers.inc"
inline bool upload_button_helpers(BackgroundTransport &transport,bool visible){
 const uint8_t *tiles[]={visible?helper_0_visible:helper_0_plain,visible?helper_1_visible:helper_1_plain};
 const unsigned left[]={448,688};
 for(unsigned tile=0;tile<2;tile++)for(unsigned row=0;row<33;row++)
  if(!transport.pixels((670+row)*1280+left[tile],tiles[tile]+row*33,33))return false;
 return true;
}
}
