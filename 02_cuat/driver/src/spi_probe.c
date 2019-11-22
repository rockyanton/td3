#include "../inc/am355x.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ PROBE +++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static volatile void *td3_spi_base, *mcspi0_base, *cm_per_base, *control_module_base;
volatile int virq;

static int spi_probe(struct platform_device * spi_platform_device) {

	int result;

	td3_spi_base = of_iomap(spi_platform_device->dev.of_node, 0);


	// Mapeo el registro CM_PER
	if((cm_per_base = ioremap(CM_PER_BASE, CM_PER_LENGTH)) == NULL)	{
		 printk(KERN_ERR "SPI_DRIVER: probe: Couldn't map CM_PER\n");
		 iounmap(td3_spi_base);
		 return 1;
	}

	// Habilito el clock del SPI
	set_registers(cm_per_base, CM_PER_SPI0_CLKCTRL_MODULEMODE_ENABLED);

	// Espero un ratito hasta que se habilite
	msleep(10);

	// Mapeo el registro CONTROL MODULE
	if((control_module_base = ioremap(CONTROL_MODULE_BASE, CONTROL_MODULE_LENGTH)) == NULL) {
		 printk(KERN_ERR "SPI_DRIVER: probe: Couldn't map CONTROL MODULE\n");
		 iounmap(td3_spi_base);
		 iounmap(cm_per_base);
		 return 1;
	}

	// Seteo la configuracion de los pines del BB
	set_registers(control_module_base, CONTROL_MODULE_SPI0_SCLK_RX_PULLUP);
	set_registers(control_module_base, CONTROL_MODULE_SPI0_D0_RX_PULLDOWN);
	set_registers(control_module_base, CONTROL_MODULE_SPI0_D1_RX_PULLUP);
	set_registers(control_module_base, CONTROL_MODULE_SPI0_CS0_RX_PULLUP);

	// Mapeo el registro McSPI0
	if((mcspi0_base = ioremap(MCSPI0_BASE, MCSPI0_LENGTH)) == NULL) {
		 printk(KERN_ERR "SPI_DRIVER: probe: Couldn't map CONTROL MODULE\n");
		 iounmap(td3_spi_base);
		 iounmap(cm_per_base);
		 iounmap(control_module_base);
		 return 1;
	}

	// Espero un ratito más hasta que se habilite
	msleep(10);

	// Chequeo si se inicializó o no
	if (!get_registers(mcspi0_base, MCSPI_SYSSTATUS_RESETDONE)) {
		printk(KERN_ERR "SPI_DRIVER: probe: Internal module reset is on-going\n");
		iounmap(td3_spi_base);
		iounmap(cm_per_base);
		iounmap(control_module_base);
		iounmap(mcspi0_base);
		return 1;
	}

	// Seteo la configuración de SPI (modo)
	set_registers(mcspi0_base, MCSPI_SYSCONFIG_SET);
	set_registers(mcspi0_base, MCSPI_MODULCTRL_SET);
	set_registers(mcspi0_base, MCSPI_CH0CONF_STANDBY);
	set_registers(mcspi0_base, MCSPI_CH0CTRL_SET_CLOCK);
	set_registers(mcspi0_base, MCSPI_CH0CTRL_ENABLE);


	// Deshabilito todas las interrupciones
	set_registers(mcspi0_base, MCSPI_IRQENABLE_DISABLE_ALL);

	// Limpio todos los flags
	set_registers(mcspi0_base, MCSPI_IRQSTATUS_CH0_CLEAR);

	// Pido un número de interrupcion
	virq = platform_get_irq(spi_platform_device, 0);
	if(virq < 0) {
		printk(KERN_ERR "SPI_DRIVER: probe: Can't get irq number\n");
		iounmap(td3_spi_base);
 		iounmap(cm_per_base);
 		iounmap(control_module_base);
 		iounmap(mcspi0_base);
		return 1;
	}

	// Lo asigno a mi handler
	if(request_irq(virq, (irq_handler_t) spi_irq_handler, IRQF_TRIGGER_RISING, COMPATIBLE, NULL)) {
		printk(KERN_ERR "SPI_DRIVER: probe: Can't bind irq to handler\n");
		iounmap(td3_spi_base);
  	iounmap(cm_per_base);
  	iounmap(control_module_base);
  	iounmap(mcspi0_base);
		return 1;
	}
	printk(KERN_INFO "SPI_DRIVER: probe: Device IRQ number: %d\n", virq);

	// Registro el char device
	result = register_device();

	return result;	// Si hubo algún error, me devuelve <0, sino 0
}

static int spi_remove(struct platform_device * my_platform_device)
{
	iounmap(td3_spi_base);
	iounmap(cm_per_base);
	iounmap(control_module_base);
	iounmap(mcspi0_base);
	free_irq(virq, NULL);
	return 0;
}
