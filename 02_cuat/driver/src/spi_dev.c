//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++ INCLUDES ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "../inc/spi_dev.h"

#include "spi_fops.c"
#include "spi_probe.c"
#include "spi_irq.c"
#include "reg.c"
#include "adxl345.c"
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ MODULE DEFINE ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Rodrigo Anton");
MODULE_DESCRIPTION("Driver SPI TD3");

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ VARIABLES ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static dev_t spi_dev_t; // Declaro la variable tipo estructura. Debe ser declarada como global y static (para que no la toquen de afuera)
static struct cdev* spi_cdev; // Declaro el puntero a la estructura necesaria para hacer el cdev_alloc();
static struct class * spi_class;
static struct device * spi_device;

static struct of_device_id spi_of_device_ids[] = {
	{
		.compatible = COMPATIBLE,
	}, { }
};

MODULE_DEVICE_TABLE(of, spi_of_device_ids);

static struct platform_driver spi_platform_driver = {
	.probe = spi_probe,
	.remove = spi_remove,
	.driver = {
		.name = COMPATIBLE,
		.of_match_table = of_match_ptr(spi_of_device_ids)
	},
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ INIT ++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_init(void) {

	int result;

	printk(KERN_INFO "SPI_DRIVER: dev_init: Inializating module\n");

	result = platform_driver_register(&spi_platform_driver);
	if (result < 0) {
		 printk(KERN_ERR "SPI_DRIVER: dev_init: Couldn't register platform driver\n");
		 platform_driver_unregister(&spi_platform_driver);
		 return result;
	}

	printk(KERN_INFO "SPI_DRIVER: dev_init: Inicialization complete\n");

  return 0;
}

static int register_device (void){

	 int result;

	//Primer paso es conseguir el número mayor y en este caso 1 número menor (un solo inodo)
  result = alloc_chrdev_region(&spi_dev_t, FIRST_MINOR, COUNT_MINOR, COMPATIBLE); //Returns zero or a negative rror code

  if (result < 0) {
		printk(KERN_ERR "SPI_DRIVER: dev_init: Couldn't allocate region\n");
    return result;
  }

	spi_class = class_create(THIS_MODULE, "TD3");
	if (spi_class == NULL){
		printk(KERN_ERR "SPI_DRIVER: dev_init: Couldn't create class\n");
		unregister_chrdev_region(spi_dev_t, COUNT_MINOR);
		return -1;
	}

	spi_device = device_create(spi_class, NULL, spi_dev_t, NULL, COMPATIBLE);
	if (spi_device == NULL){
		printk(KERN_ERR "SPI_DRIVER: dev_init: Couldn't create device\n");
		class_destroy(spi_class);
		unregister_chrdev_region(spi_dev_t, COUNT_MINOR);
		return -1;
	}

	spi_cdev = cdev_alloc();

	spi_cdev->ops = &spi_file_operations;
	spi_cdev->owner = THIS_MODULE;
	spi_cdev->dev = spi_dev_t;

	result = cdev_add(spi_cdev, spi_dev_t, COUNT_MINOR);
	if (result < 0) {
		 printk(KERN_ERR "SPI_DRIVER: dev_init: Couldn't add class\n");
		 device_destroy(spi_class, spi_dev_t);
		 class_destroy(spi_class);
		 unregister_chrdev_region(spi_dev_t, COUNT_MINOR);
		 return result;
	}

	printk(KERN_INFO "SPI_DRIVER: dev_init: Device created with major number: %d\n", MAJOR(spi_dev_t));

	return 0;

}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++ REMOVE ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static void spi_exit(void) {
	printk(KERN_INFO "SPI_DRIVER: dev_init: Exiting module\n");
	cdev_del(spi_cdev);
  device_destroy(spi_class, spi_dev_t);
	class_destroy(spi_class);
  unregister_chrdev_region(spi_dev_t, COUNT_MINOR); //Misma cantidad de menores que el alloc
	platform_driver_unregister(&spi_platform_driver);
  printk(KERN_DEBUG "SPI_DRIVER: dev_exit: Device unregistered\n");
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ MODULE ADD +++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

module_init(spi_init);
module_exit(spi_exit);
