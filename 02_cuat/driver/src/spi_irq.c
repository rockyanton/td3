extern uint32_t read_buffer;
extern struct semaphore rw_sem;

irqreturn_t spi_irq_handler(int irq, void *dev_id, struct pt_regs *regs) {
  uint32_t received;

  // Traigo los flags y me fijo si son los que me interesan
  uint32_t flag_irq = get_registers(mcspi0_base, MCSPI_IRQSTATUS_CH0_GET);

  if (flag_irq & MCSPI_IRQSTATUS_RX0_FULL_SET){   // Me fijo si es por el flag de RX FULL

    received = ioread32 (mcspi0_base + MCSPI_RX0);

    if (down_trylock(&rw_sem)) // Pregunto si puede tomar el semaforo (Si es 1 es porque no, lo tomó el write, el dato que me develve es el que quiero)
      read_buffer = received;
    up(&rw_sem);  // Lo devuelvo

    set_registers(mcspi0_base, MCSPI_IRQSTATUS_RX0_FULL_CLEAR); // Bajo el flag de rx para que no entre de nuevo
  }

  return IRQ_HANDLED;
}
