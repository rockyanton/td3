//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ PROBE +++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_probe(struct platform_device * my_platform_device)
{
	printk(KERN_INFO "[LOG] SPI DRIVER: Probe OK\n");
	return 0;
}

static int spi_remove(struct platform_device * my_platform_device)
{
	printk(KERN_INFO "[LOG] SPI DRIVER: Probe remove OK\n");
	return 0;
}
