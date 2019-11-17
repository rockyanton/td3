#include "../inc/am355x.h"
#include <linux/io.h>

void set_registers (volatile void *base, uint32_t offset, uint32_t mask, uint32_t value) {
  uint32_t old_value = ioread32 (base + offset); // Traigo los datos del registro
  old_value &= ~(mask); // Borro los datos a escribir
  value &= mask;        // Me quedo con los bytes que van
  value |= old_value;   // Agrego los datos nuevos

  iowrite32 (value, base + offset);
  return;
}


uint32_t get_registers (volatile void *base, uint32_t offset, uint32_t mask) {
  uint32_t ret = ioread32 (base + offset);
  return (ret & mask);
}

void get_spi_transfer_status () {
  uint32_t register_value;
  register_value = ioread32 (mcspi0_base + MCSPI_CH0STAT);

  switch (register_value) {
    case 0x7:
      printk(KERN_INFO "MCSPI_CH0STAT: Data received\n");
      break;
    case 0x6:
      printk(KERN_INFO "MCSPI_CH0STAT: Normal\n");
      break;
    case 0x4:
      printk(KERN_INFO "MCSPI_CH0STAT: Ready to send\n");
      break;
    case 0x2:
      printk(KERN_INFO "MCSPI_CH0STAT: Sending data\n");
      break;
    default:
      printk(KERN_INFO "MCSPI_CH0STAT: Unknown code: %x\n", register_value);
  }
}

uint32_t spi_data_is_sent (){
  return(get_registers(mcspi0_base, MCSPI_CH0STAT_TXS));
}

uint32_t spi_data_to_read (){
  return (get_registers(mcspi0_base, MCSPI_CH0STAT_RXS));
}

uint32_t spi_data_eot (){
  return(get_registers(mcspi0_base, MCSPI_CH0STAT_EOT));
}
