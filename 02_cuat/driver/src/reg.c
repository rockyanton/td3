#include "../inc/am355x.h"
#include <linux/io.h>

void set_registers(volatile void *base, uint32_t offset, uint32_t mask, uint32_t value) {
  uint32_t old_value = get_registers(base, offset, mask); // Traigo los datos del registro
  old_value &= ~mask;   // Borro los datos a escribir
  value &= mask;        // Me quedo con los bytes que van
  value |= old_value;   // Agrego los datos nuevos

  iowrite32 (value, base + offset);
  return;
}


uint32_t get_registers(volatile void *base, uint32_t offset, uint32_t mask) {
  uint32_t ret = ioread32 (base + offset);
  return (ret & mask);
}
