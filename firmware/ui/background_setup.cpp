// Embedded artwork provider. GPL-3.0.
#include "background_setup.h"
#include "background_asset.h"
namespace {
#if defined(TANG_NANO20K)
#include "background_seed.inc"
static_assert(sizeof background_seed_header==32,"Invalid embedded artwork header");
#endif
}
const uint8_t *nanoblast_builtin_background(unsigned &length){
#if defined(TANG_NANO20K)
 length=sizeof background_seed;return background_seed;
#else
 length=0;return nullptr;
#endif
}
const char *nanoblast_background_setup_status(){return "Artwork source: BL616 flash";}
const char *nanoblast_background_setup_diagnostic(){return "";}
// Retained for older callers; embedded artwork needs no filesystem setup.
void nanoblast_prepare_background(){}
