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

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++ FILE OPERATIONS +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_open (struct inode * device_inode, struct file * device_descriptor) {
	int init_success;

	init_success = adxl345_init(); //Inicializo el módulo

	if (init_success > 0)
		return 0;
	return init_success;
}

static int spi_close(struct inode * device_inode, struct file * device_descriptor) {
		return 0;
}

static ssize_t spi_write (struct file * device_descriptor, const char __user * user_buffer, size_t write_count, loff_t * my_loff_t) {
	// DEEVUELVO SIEMPRE ERROR, NO SE PUEDE ESCRIBIR
	return -EPERM;
}

static ssize_t spi_read (struct file * device_descriptor, char __user * user_buffer, size_t read_count, loff_t * my_loff_t) {
	// DEVUELVO: DEVID - DATAX0 - DATA X1 - DATAY0 - DATAY1 - DATAZ0 - DATAZ1
	char * measurement;
	uint8_t i;
	int query;
	unsigned long result;

	measurement = kmalloc (7, GFP_KERNEL);	// Pido 7 bytes

	if (read_count > 7) // Si es mayor a 6 lo limito;
		read_count = 7;

	for (i=0; i<6 ; i++){
		query = adxl345_read(0x32+i);
		if (query < 0)	// Si me devuelve error corto antes
			break;
		measurement[i+1] = (char)(query & 0xFF);
	}

	if (query < 0){ 	// Si hubo error retorno -1 bytes copiados
		return (ssize_t)query;
	}

	if ((query = adxl345_read(0x00)) < 0){ 	// Si hubo error retorno -1 bytes copiados
		return (ssize_t)query;
	}

	measurement[0] = (char)(query & 0xFF);

	result = copy_to_user(user_buffer, measurement, read_count);

	kfree(measurement);
	if (!result) // Si todo sale bien, devuelve 0. Yo devuelvo la cant. de bytes copiados
		return (ssize_t)read_count;
	return 0;	//	Sino, devuelvo 0
}

static long spi_ioctl(struct file * my_file, unsigned int my_uint, unsigned long my_ulong){
	return 0;
}
