// Horizon palette contract shared by the menu and embedded indexed artwork.
#pragma once
#include <cstdint>
namespace nanoblast { namespace horizon {
constexpr unsigned FirstRow=15, LastRow=26, FirstChoice=17, FirstPalette=224;
constexpr unsigned HelperPalette=240, HelperColorCount=7;
constexpr uint32_t FooterBackground=0x06152e;
constexpr uint32_t HelperColors[]={0xe53935,0xf4c942,0xffffff,0x172139,0x10213c,0xff8371,0xffed92};
constexpr uint32_t Navy=0x0b2145, Blue=0x175d9f, Red=0xeb3327;
constexpr uint32_t row_color(unsigned row,bool selected){return selected?Red:row==FirstRow?Blue:Navy;}
}}
