#include "../inc/adxl345.h"

int is_initializated = 0;

void adxl345_init(void){
  if (!is_initializated){
    iowrite32(0xA2, mcspi0_base + MCSPI_TX0);
    iowrite32(0xA2, mcspi0_base + MCSPI_TX0);
    iowrite32(0xA2, mcspi0_base + MCSPI_TX0);
    iowrite32(0xA2, mcspi0_base + MCSPI_TX0);
    iowrite32(0xA2, mcspi0_base + MCSPI_TX0);
  }
  return;
}
