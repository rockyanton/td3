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
static uint32_t is_initializated = 0, init_timeout=0;

uint32_t adxl345_init(void){
  uint32_t init_recv;
  if (!is_initializated){ // Si ninca se inializó, lo inicializo
    init_timeout = 0;

    adxl345_set_register (DATA_FORMAT_4W_FULL);
    start_timeout();
    while (!spi_data_is_sent() & !init_timeout){} // Espero a que se cargue el registro
    stop_timeout();
    start_timeout();
    while (!spi_data_eot() & !init_timeout){}     // Espero a que termine la transferencia
    stop_timeout();
    start_timeout();
    while (!spi_data_to_read() & !init_timeout){} // Espero a que se me cargue el buffer con la basura mientras envié
    stop_timeout();
    init_recv = adxl345_data_read();

    adxl345_set_register (POWER_CTL_MEASURE);
    start_timeout();
    while (!spi_data_is_sent() & !init_timeout){} // Espero a que se cargue el registro
    stop_timeout();
    start_timeout();
    while (!spi_data_eot() & !init_timeout){}     // Espero a que termine la transferencia
    stop_timeout();
    start_timeout();
    while (!spi_data_to_read() & !init_timeout){} // Espero a que se me cargue el buffer con la basura mientras envié
    stop_timeout();
    init_recv = adxl345_data_read();

    if (!init_timeout) {  // Si no hubo timeout en ninguno (Se envió y recibió correctamente)
      printk(KERN_INFO "SPI_DRIVER: adxl345_init: ADXL345 inicializated\n");
      is_initializated = 1;
      return 1;
    } else {  // Si hubo timeout devuelvo 0 (error)
      printk(KERN_ERR "SPI_DRIVER: adxl345_init: ADXL345 timeout\n");
      return 0;
    }
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

uint32_t adxl345_data_read (void){
  uint32_t received;
  received = ioread32 (mcspi0_base + MCSPI_RX0);
  return (received & 0xFF); // Manda de a 1 bytes
}

void is_timeout( unsigned long data ) {
  init_timeout = 1;
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
