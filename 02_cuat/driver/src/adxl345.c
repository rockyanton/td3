#include "../inc/adxl345.h"

/*
PINES:
GND -> 1/2 (GND)
VCC -> 3/4 (3.3v)
SCL -> 22
SDA -> 18
SD0 -> 21
CS  -> 1/2 (GND)
*/
static struct timer_list timeout_timer;
static uint8_t is_initializated = 0, timeout;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++ ADXL345 Inicalization +++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uint8_t adxl345_init(void){
  uint8_t init_success1=0, init_success2=0;

  if (!is_initializated){ // Si ninca se inializó, lo inicializo

    //printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: Setting DATA_FORMAT\n");
    init_success1 = adxl345_write (DATA_FORMAT, FULL_4W);
    //printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: Setting POWER_CTL\n");
    init_success2 = adxl345_write (POWER_CTL, MEASURE);

    if (init_success1 && init_success2) { // Si salio todo bien
      printk(KERN_INFO "SPI_DRIVER: adxl345_init: ADXL345 inicializated\n");
      is_initializated = 1;
      return 1; // Inicializado :1
    } else {
      printk(KERN_ERR "SPI_DRIVER: adxl345_init: ADXL345 timeout\n");
      return 0;
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
  uint32_t received;
  received = ioread32 (mcspi0_base + MCSPI_RX0);
  received &= 0xFF;
  return ((uint8_t) received); // Manda de a 1 bytes
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ ADXL345 FOPS +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uint8_t adxl345_write (uint8_t register_write, uint8_t register_content){
  uint8_t response;
  uint16_t command_to_send;
  timeout = 0;

  command_to_send = (register_write << 8) | (register_content & 0xFF);

  printk(KERN_DEBUG "SPI_DRIVER: adxl345_write: Command sent: %x\n", command_to_send);

  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
  ndelay(10);
  adxl345_set_register (command_to_send);
  start_timeout();
  while (!spi_data_is_sent() && !timeout){} // Espero a que se cargue el registro
  stop_timeout();
  start_timeout();
  while (!spi_data_eot() && !timeout){}     // Espero a que termine la transferencia
  stop_timeout();
  start_timeout();
  while (!spi_data_to_read() && !timeout){} // Espero a que se me cargue el buffer con la basura mientras envié
  stop_timeout();
  ndelay(10);
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir
  response = adxl345_read_register();

  return (!timeout); // Si no hubo timeout esta bien (timeout=0 => 1)
}

uint8_t adxl345_read (uint8_t register_read){
  uint8_t response;
  timeout = 0;
  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
  ndelay(10);
  adxl345_get_register (register_read << 8);
  start_timeout();
  while (!spi_data_is_sent() && !timeout){} // Espero a que se cargue el registro
  stop_timeout();
  start_timeout();
  while (!spi_data_eot() && !timeout){}     // Espero a que termine la transferencia
  stop_timeout();
  start_timeout();
  while (!spi_data_to_read() && !timeout){} // Espero a que se me cargue el buffer con la basura mientras envié
  stop_timeout();
  ndelay(10);
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir
  ndelay(10);
  response = adxl345_read_register();

  if (!timeout){
    return response;
  } else {
    return 0xFF;
  }
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Timer related functions +++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void is_timeout( unsigned long data ) {
  timeout = 1;
}

void start_timeout(void) {
  // Le digo al timer que llame a is_timeout cuando termine de contar
  setup_timer(&timeout_timer, is_timeout, 0);
  // Le digo que arranque a contar 100ms
  mod_timer(&timeout_timer, jiffies + msecs_to_jiffies(50));
  return;
}

void stop_timeout(void) {
  // Borro el timer
  del_timer(&timeout_timer);
  return;
}
