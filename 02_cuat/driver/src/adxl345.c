#include "../inc/adxl345.h"

static uint8_t is_initializated = 0;
uint32_t read_buffer;

DEFINE_SEMAPHORE(rw_sem);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++ ADXL345 Inicalization +++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int adxl345_init(void){
  uint8_t init_success1=0, init_success2=0;

  if (!is_initializated){ // Si ninca se inializó, lo inicializo

    //printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: Setting POWER_CTL\n");
    init_success2 = adxl345_write (POWER_CTL, MEASURE);
    ndelay(100);
    //printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: Setting DATA_FORMAT\n");
    init_success1 = adxl345_write (DATA_FORMAT, FULL_4W);
    ndelay(100);

    if (!init_success1 && !init_success2) { // Si salio todo bien ambos devuelven 0
      printk(KERN_INFO "SPI_DRIVER: adxl345_init: ADXL345 inicializated\n");
      is_initializated = 1;
      return 1; // Inicializado :1
    } else {
      printk(KERN_ERR "SPI_DRIVER: adxl345_init: ADXL345 could not be inicializated\n");
      if (init_success1)
        return init_success1; // Si fallo el primero, retorno el error del primero
      return init_success2;   // Idem segundo
    }
  }

  return 2; // Si ya estaba inicializado: 2
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ ADXL345 Registers +++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void adxl345_set_register (uint16_t command_to_send){
  command_to_send &= 0x3FFF;  // Como es escritura, primer byte en 0. MB=0
  iowrite32((uint32_t)command_to_send, mcspi0_base + MCSPI_TX0);
}

void adxl345_get_register (uint16_t query_to_send){
  query_to_send &= 0x3F00;  // MB=0
  query_to_send |= 0x8000;  // Como es lectura, primer byte en 1.

  iowrite32((uint32_t)query_to_send, mcspi0_base + MCSPI_TX0);
}

uint8_t adxl345_read_register (void){
  return ((uint8_t) read_buffer);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ ADXL345 FOPS +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int adxl345_write (uint8_t register_to_write, uint8_t register_value){

  uint16_t command_to_send;
  int sem_timeout;

  command_to_send = (register_to_write << 8) | (register_value & 0xFF);
  //printk(KERN_DEBUG "SPI_DRIVER: adxl345_write: Command sent: %x\n", command_to_send);

  set_registers(mcspi0_base, MCSPI_IRQSTATUS_RX0_FULL_CLEAR); // Bajo el flag de RX0 Full para que no entre
  set_registers(mcspi0_base, MCSPI_IRQENABLE_RX0_FULL); // Habilito la interupcion de RX0 Full

  sem_timeout = down_trylock(&rw_sem); // Libero el semáforo si llega a estar tomado
  up(&rw_sem);

  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
  ndelay(10);
  adxl345_set_register (command_to_send);
  ndelay(10);
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir

  sem_timeout = down_interruptible(&rw_sem); // Trato de tomarlo de nuevo (Se libera cuando se carga RX).
  if (sem_timeout < 0){
    printk(KERN_ERR "SPI_DRIVER: adxl345_read: Can't hold semaphore to receive\n");
  }

  set_registers(mcspi0_base, MCSPI_IRQENABLE_DISABLE_ALL); // Deshabilito las interupciones

  return (sem_timeout); // Si no hubo timeout esta bien (timeout=0 => 1)
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int adxl345_read (uint8_t register_to_read){

  int sem_timeout;

  set_registers(mcspi0_base, MCSPI_IRQSTATUS_RX0_FULL_CLEAR); // Bajo el flag de RX0 Full para que no entre
  set_registers(mcspi0_base, MCSPI_IRQENABLE_RX0_FULL); // Habilito la interupcion de RX0 Full

  sem_timeout = down_trylock(&rw_sem); // Libero el semáforo si llega a estar tomado
  up(&rw_sem);

  sem_timeout = down_interruptible(&rw_sem); // Tomo el semáforo
  if (sem_timeout < 0) {
    printk(KERN_ERR "SPI_DRIVER: adxl345_read: Can't hold semaphore to send\n");
    return sem_timeout;
  }

  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
  ndelay(10);
  adxl345_get_register (register_to_read << 8);
  ndelay(10);
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir

  sem_timeout = down_interruptible(&rw_sem); // Trato de tomarlo de nuevo (Se libera cuando se carga RX).
  if (sem_timeout < 0){
    printk(KERN_ERR "SPI_DRIVER: adxl345_read: Can't hold semaphore to receive\n");
    return sem_timeout;
  }
  up(&rw_sem);

  set_registers(mcspi0_base, MCSPI_IRQENABLE_DISABLE_ALL); // Deshabilito las interupciones

  return ((int) adxl345_read_register());

}
