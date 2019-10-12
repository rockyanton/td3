obj-m := src/spi_dev.o
KERNEL_DIR = /home/rodrigo/kernel_beagle/
all:
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_DIR) M=$(PWD) modules
clean:
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNEL_DIR) M=$(PWD) clean
