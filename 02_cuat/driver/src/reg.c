#include "../inc/am355x.h"
#include <linux/io.h>

void set_registers(uint32_t *base, uint32_t offset, uint32_t bit, uint32_t length, uint32_t value) {
  uint32_t mask, reg;
  mask = ((~(0xFFFFFFFF << length)) << bit); // Creo una mascara para escribir
  value = ((value << bit) & mask);                   // Pongo el valor en el lugar y largo indicado

  reg = ioread32 (base + offset); // Traigo los registros viejos
  reg &= (~mask);
  reg |= value;
  iowrite32 (reg, base + offset);
}

uint32_t get_registers(uint32_t *base, uint32_t offset, uint32_t bit, uint32_t length) {
  return ( ( (ioread32 (base + offset) ) >> bit) & ~(0xFFFFFFFF << length) );
}
