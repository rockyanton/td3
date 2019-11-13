irqreturn_t spi_irq_handler(int irq, void *dev_id, struct pt_regs *regs) {
  // Traigo los flags y me fijo si son los que me interesan
  uint32_t flag_irq = get_registers(mcspi0_base, MCSPI_IRQSTATUS_CH0_GET);
  if (flag_irq) {

    if (flag_irq & MCSPI_IRQSTATUS_RX0_OVERFLOW_SET){
      printk(KERN_INFO "[LOG] SPI DRIVER: New interrupt RX0_OVERFLOW\n");
      set_registers(mcspi0_base, MCSPI_IRQSTATUS_RX0_OVERFLOW_CLEAR);
    }

    if (flag_irq & MCSPI_IRQSTATUS_RX0_FULL_SET){
      printk(KERN_INFO "[LOG] SPI DRIVER: New interrupt RX0_FULL\n");
      set_registers(mcspi0_base, MCSPI_IRQSTATUS_RX0_FULL_CLEAR);
    }

    if (flag_irq & MCSPI_IRQSTATUS_TX0_UNDERFLOW_SET){
      printk(KERN_INFO "[LOG] SPI DRIVER: New interrupt TX0_UNDERFLOW\n");
      set_registers(mcspi0_base, MCSPI_IRQSTATUS_TX0_UNDERFLOW_CLEAR);
    }

    if (flag_irq & MCSPI_IRQSTATUS_TX0_EMPTY_SET){
      printk(KERN_INFO "[LOG] SPI DRIVER: New interrupt TX0_EMPTY\n");
      set_registers(mcspi0_base, MCSPI_IRQSTATUS_TX0_EMPTY_CLEAR);
    }

  }

  return IRQ_HANDLED;
}
