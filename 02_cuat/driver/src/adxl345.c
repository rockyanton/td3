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
static uint32_t is_initializated = 0, timeout;

uint32_t adxl345_init(void){
  uint32_t init_recv;
  if (!is_initializated){ // Si ninca se inializó, lo inicializo
    timeout = 0;

    init_recv = adxl345_write (DATA_FORMAT_4W_FULL);
    printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: rcv %x: %x\n", DATA_FORMAT_4W_FULL, init_recv);

    init_recv = adxl345_write (POWER_CTL_MEASURE);
    printk(KERN_DEBUG "SPI_DRIVER: adxl345_init: rcv %x: %x\n", POWER_CTL_MEASURE, init_recv);

    //if (!timeout) {  // Si no hubo timeout en ninguno (Se envió y recibió correctamente)
      printk(KERN_INFO "SPI_DRIVER: adxl345_init: ADXL345 inicializated\n");
      is_initializated = 1;
      return 1;
    //} else {  // Si hubo timeout devuelvo 0 (error)
    //  printk(KERN_ERR "SPI_DRIVER: adxl345_init: ADXL345 timeout\n");
    //  return 0;
  //  }
  } else {
    return 2; // Si ya estaba inicializado, respondo 2
  }
}

void adxl345_set_register (uint32_t command_to_send){
  command_to_send &= 0x3FFF;  // Como es escritura, primer byte en 0. MB=0
  iowrite32(command_to_send, mcspi0_base + MCSPI_TX0);
}

void adxl345_get_register (uint32_t query_to_send){
  query_to_send &= 0x3F00;  // MB=0
  query_to_send |= 0x8000;  // Como es lectura, primer byte en 1.

  iowrite32(query_to_send, mcspi0_base + MCSPI_TX0);
}

uint32_t adxl345_read_register (void){
  uint32_t received;
  received = ioread32 (mcspi0_base + MCSPI_RX0);
  received &= 0xFF;
  return received; // Manda de a 1 bytes
}

uint32_t adxl345_write (uint32_t command_to_send){
  uint32_t response;
  timeout = 0;

  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
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
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir
  response = adxl345_read_register();

  return !timeout; // Si no hubo timeout esta bien (timeout=0 => 1)

}

uint32_t adxl345_read (uint32_t register_to_read){
  uint32_t response;
  timeout = 0;
  set_registers(mcspi0_base, MCSPI_CH0CONF_SENDING); // Bajo CS
  msleep(1);
  adxl345_get_register (register_to_read);
  start_timeout();
  while (!spi_data_is_sent() && !timeout){} // Espero a que se cargue el registro
  stop_timeout();
  start_timeout();
  while (!spi_data_eot() && !timeout){}     // Espero a que termine la transferencia
  stop_timeout();
  start_timeout();
  while (!spi_data_to_read() && !timeout){} // Espero a que se me cargue el buffer con la basura mientras envié
  stop_timeout();
  msleep(1);
  set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY); // Lo vuelvo a subir
  response = adxl345_read_register();

  if (!timeout){
    return response;
  } else {
    return 0xFFFFFFFF;
  }
}

void is_timeout( unsigned long data ) {
  timeout = 1;
}

void start_timeout(void) {
  // Le digo al timer que llame a is_timeout cuando termine de contar
  setup_timer(&timeout_timer, is_timeout, 0);
  // Le digo que arranque a contar 100ms
  mod_timer(&timeout_timer, jiffies + msecs_to_jiffies(100));
  return;
}

void stop_timeout(void) {
  // Borro el timer
  del_timer(&timeout_timer);
  return;
}
