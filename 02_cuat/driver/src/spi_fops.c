#include "../inc/adxl345.h"
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ VARIABLES ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static struct file_operations spi_file_operations = {
	.owner = THIS_MODULE,
	.open = spi_open,
	.release = spi_close,
	.read = spi_read,
	.write = spi_write,
	.unlocked_ioctl = spi_ioctl
};

volatile int command_sent=0;
static uint32_t show = 0;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ FILE OPERATIONS +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_open (struct inode * device_inode, struct file * device_descriptor) {
	uint32_t init_success;
	//printk(KERN_DEBUG "SPI_DRIVER: Open requested\n");
	init_success = adxl345_init(); //Inicializo el módulo
	//printk(KERN_DEBUG "SPI_DRIVER: Exiting Open\n");

	if (init_success){
		return 0;
	}

	return -ETIMEDOUT;
}

static int spi_close(struct inode * device_inode, struct file * device_descriptor) {
		return 0;
}

static ssize_t spi_write (struct file * device_descriptor, const char __user * user_buffer, size_t write_count, loff_t * my_loff_t) {
	//static ssize_t write_size = 0;
	return -EPERM;
}

static ssize_t spi_read (struct file * device_descriptor, char __user * user_buffer, size_t read_count, loff_t * my_loff_t) {
	char * measurement;
	uint8_t query;
	unsigned long result;

	measurement = kmalloc (7, GFP_KERNEL);	// Pido 6 bytes

	if (read_count > 7) // Si es mayor a 6 lo limito;
		read_count = 7;

	query = adxl345_read(0x32); // DATAX0
	measurement[0] = (query & 0xFF);
	query = adxl345_read(0x33); // DATAX1
	measurement[1] = (query & 0xFF);
	query = adxl345_read(0x34); // DATAY0
	measurement[2] = (query & 0xFF);
	query = adxl345_read(0x35); // DATAX1
	measurement[3] = (query & 0xFF);
	query = adxl345_read(0x36); // DATAZ0
	measurement[4] = (query & 0xFF);
	query = adxl345_read(0x37); // DATAZ1
	measurement[5] = (query & 0xFF);
	query = adxl345_read(0x00); // DEVID
	measurement[6] = (query & 0xFF);

	result = copy_to_user(user_buffer, measurement, read_count);

	show %= 100; // Cada 100 pedidos muestro
	/*if (!show)
		printk(KERN_DEBUG "device ID= 0x%x // X= 0x%x%x // Y= 0x%x%x // Z= 0x%x%x\n", measurement[6], measurement[1], measurement[0], measurement[3], measurement[2], measurement[5], measurement[4]);
*/

	kfree(measurement);

	return (ssize_t)read_count;
}

static long spi_ioctl(struct file * my_file, unsigned int my_uint, unsigned long my_ulong){
	return 0;
}
