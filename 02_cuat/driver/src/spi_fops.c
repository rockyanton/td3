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

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ FILE OPERATIONS +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_open (struct inode * my_inode, struct file * my_file) {
	printk(KERN_DEBUG "SPI_DRIVER: Open requested\n");
	adxl345_init(); //Inicializo el módulo
	return 1;
}

static int spi_close(struct inode * my_inode, struct file * my_file) {
		return 0;
}

static ssize_t spi_write (struct file * my_file, const char __user * my_user, size_t my_sizet, loff_t * my_loff_t) {
	static ssize_t write_size = 0;

	return write_size;
}

static ssize_t spi_read (struct file * my_file, char __user * my_user, size_t my_sizet, loff_t * my_loff_t) {
	static ssize_t read_size=0;
	return read_size;
}

static long spi_ioctl(struct file * my_file, unsigned int my_uint, unsigned long my_ulong){
	return 0;
}
