cmake_minimum_required(VERSION 3.15)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CONFIG_FREERTOS 1)
set(CONFIG_CHERRYUSB 1)
set(CONFIG_CHERRYUSB_HOST 1)
set(CONFIG_BSP_SDH_SDCARD 0)
set(CONFIG_FATFS 1)
set(CONFIG_FATFS_USBH 1)
set(CONFIG_FATFS_SDH_SDCARD 0)

if(TANG_BOARD STREQUAL "mega60k")
    add_definitions(-DTANG_MEGA60K)
elseif(TANG_BOARD STREQUAL "mega138k")
    add_definitions(-DTANG_MEGA138K)
elseif(TANG_BOARD STREQUAL "console60k") 
    add_definitions(-DTANG_CONSOLE60K)
elseif(TANG_BOARD STREQUAL "console138k")
    add_definitions(-DTANG_CONSOLE138K)
elseif(TANG_BOARD STREQUAL "primer25k")
    add_definitions(-DTANG_PRIMER25K)
elseif(TANG_BOARD STREQUAL "nano20k")
    add_definitions(-DTANG_NANO20K)
endif()

find_package(bouffalo_sdk REQUIRED HINTS $ENV{BL_SDK_BASE})

# Add include directories
sdk_add_include_directories(
    . usb fpga ui core utils storage
)

# Add source files, including the SD clock and battery-save services
file(GLOB_RECURSE MY_SOURCES
    "usb/*.cpp"
    "fpga/*.cpp"
    "ui/*.cpp"
    "core/*.cpp"
    "utils/*.cpp"
    "storage/*.cpp"
)

target_sources(app PRIVATE ${MY_SOURCES}
    storage/xz/xz_crc32.c storage/xz/xz_dec_lzma2.c storage/xz/xz_dec_stream.c
    storage/tinf/tinflate.c storage/tinf/tinfzlib.c storage/tinf/adler32.c
)
sdk_set_main_file(main.cpp)

project(tangcore CXX)
