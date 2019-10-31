#include "../inc/am355x.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ PROBE +++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static volatile void *mcspi0_base, *cm_per_base, *control_module_base;

static int spi_probe(struct platform_device * spi_platform_device) {

	printk(KERN_INFO "[LOG] SPI DRIVER: Running Probe\n");

	// Mapeo el registro CM_PER
	printk(KERN_INFO "[LOG] SPI DRIVER: Mapping CM_PER_BASE\n");
	if((cm_per_base = ioremap(CM_PER_BASE, CM_PER_LENGTH)) == NULL)	{
		 printk(KERN_ERR "[ERROR] SPI DRIVER: Couldn't map CM_PER\n");
		 return 1;
	}

	// Habilito el clock
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting CM_PER_SPI0_CLKCTRL_MODULEMODE_ENABLED\n");
	set_registers(cm_per_base, CM_PER_SPI0_CLKCTRL_MODULEMODE_ENABLED);

	// Espero un ratito hasta que se habilite
	msleep(10);

	// Mapeo el registro CONTROL MODULE
	printk(KERN_INFO "[LOG] SPI DRIVER: Mapping CONTROL_MODULE_BASE\n");
	if((control_module_base = ioremap(CONTROL_MODULE_BASE, CONTROL_MODULE_LENGTH)) == NULL) {
		 printk(KERN_ERR "[ERROR] SPI DRIVER: Couldn't map CONTROL MODULE\n");
		 iounmap(cm_per_base);
		 return 1;
	}

	// Seteo los pines
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting CONTROL_MODULE_SPI0_SCLK_ENABLE\n");
	set_registers(cm_per_base, CONTROL_MODULE_SPI0_SCLK_ENABLE);
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting CONTROL_MODULE_SPI0_D0_ENABLE\n");
	set_registers(cm_per_base, CONTROL_MODULE_SPI0_D0_ENABLE);
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting CONTROL_MODULE_SPI0_D1_ENABLE\n");
	set_registers(cm_per_base, CONTROL_MODULE_SPI0_D1_ENABLE);

	// Mapeo el registro McSPI0
	printk(KERN_INFO "[LOG] SPI DRIVER: Mapping MCSPI0_BASE\n");
	if((mcspi0_base = ioremap(MCSPI0_BASE, MCSPI0_LENGTH)) == NULL) {
		 printk(KERN_ERR "[ERROR] SPI DRIVER: Couldn't map CONTROL MODULE\n");
		 iounmap(cm_per_base);
		 iounmap(control_module_base);
		 return 1;
	}

	// Espero un ratito más hasta que se habilite
	msleep(10);

	// Chequeo si se inicializó o no
	printk(KERN_INFO "[LOG] SPI DRIVER: Reading MCSPI_SYSSTATUS_RESETDONE\n");
	if (!get_registers(mcspi0_base, MCSPI_SYSSTATUS_RESETDONE)) {
		printk(KERN_ERR "[ERROR] SPI DRIVER: Internal module reset is on-going\n");
		iounmap(cm_per_base);
		iounmap(control_module_base);
		iounmap(mcspi0_base);
		return 1;
	}

	printk(KERN_INFO "[LOG] SPI DRIVER: Reset al SPI0 OK\n");

	//Configuro el módulo sin Chip Select, Multiple channel
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting MCSPI_SYSCONFIG\n");
	set_registers(mcspi0_base, MCSPI_SYSCONFIG_SET);
	//iowrite32 (0x308, mcspi0_base + MCSPI_SYSCONFIG);
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting MCSPI_MODULCTRL\n");
	set_registers(mcspi0_base, MCSPI_MODULCTRL_SET);
	//iowrite32 (2, mcspi0_base + MCSPI_MODULCTRL);
	//Configuro el canal 0, modo TX-RX (4-wire), D0->RX (MISO), D1->TX (MOSI) 16 bits
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting MCSPI_C0CONF\n");
	iowrite32 (0x1079F, mcspi0_base + MCSPI_C0CONF);
	//Dejo desactivado el canal 0 y seteo el divisor (sin valor)
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting MCSPI_C0CTRL\n");
	iowrite32 (0, mcspi0_base + MCSPI_C0CTRL);

	//Activo el canal 0
	printk(KERN_INFO "[LOG] SPI DRIVER: Setting MCSPI_C0CTRL\n");
	iowrite32 (1, mcspi0_base + MCSPI_C0CTRL);
	//aux = ioread32 ( mcspi0_base + MCSPI_RX0);
	//iowrite32 (spi_data.registro_lectura , mcspi0_base + MCSPI_TX0);


  printk(KERN_INFO "|PROBE| [LOG] td3_i2c : Probe OK\n");

	return 0;
}

static int spi_remove(struct platform_device * my_platform_device)
{
	printk(KERN_INFO "[LOG] SPI DRIVER: Probe remove OK\n");
	return 0;
}
