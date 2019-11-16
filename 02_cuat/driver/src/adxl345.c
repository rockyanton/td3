#include "../inc/adxl345.h"

/*
PINES:
GND -> 1/2
VCC -> 3/4 (3.3v)
SCL -> 22
SDA -> 21
SD0 -> 18
CS  -> 17
*/
int is_initializated = 0;

void adxl345_init(void){
  if (!is_initializated){
    iowrite32(0x2D08, mcspi0_base + MCSPI_TX0);
    //msleep(10);
    //iowrite32(0x2C0A, mcspi0_base + MCSPI_TX0);
    iowrite32(0x3148, mcspi0_base + MCSPI_TX0);
    //msleep(10);
    is_initializated = 1;
  }
  return;
}
