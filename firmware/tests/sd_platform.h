#pragma once
#include <cstdint>
using BYTE=uint8_t;
using LBA_t=uint32_t;
using UINT=unsigned;
using SemaphoreHandle_t=bool*;
constexpr int pdTRUE=1,STA_NOINIT=1,RES_OK=0,RES_NOTRDY=3,RES_ERROR=1,RES_WRPRT=2;
constexpr int RES_PARERR=4,CTRL_SYNC=0,GET_SECTOR_SIZE=2,GET_BLOCK_SIZE=3,DEV_SD=0;
struct FATFS_DiskioDriverTypeDef {
 int (*status)();int (*init)();int (*read)(BYTE*,LBA_t,UINT);
 int (*write)(const BYTE*,LBA_t,UINT);int (*ioctl)(BYTE,void*);void *unused;
};
SemaphoreHandle_t xSemaphoreCreateBinary();
int xSemaphoreTake(SemaphoreHandle_t,unsigned);
void xSemaphoreGive(SemaphoreHandle_t);
void disk_driver_callback_init(int,FATFS_DiskioDriverTypeDef*);
void fpga_tx_header(int,int);void fpga_tx_byte(uint8_t);
uint64_t bflb_mtimer_get_time_ms();void delay(unsigned);
#define pdMS_TO_TICKS(n) (n)
#define taskENTER_CRITICAL() do {} while(0)
#define taskEXIT_CRITICAL() do {} while(0)
