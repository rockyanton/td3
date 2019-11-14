//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++ INCLUDES ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//#include <asm-generic/errno.h>
//#include <asm-generic/errno-base.h>

#include <linux/cdev.h>             // Char device: File operation struct,
#include <linux/fs.h>               // Header for the Linux file system support (alloc_chrdev_region y unregister_chrdev_region)
#include <linux/module.h>           // Core header for loading LKMs into the kernel
//#include <linux/uaccess.h>          // copy_to_user - copy_from_user
#include <linux/of_address.h>       // of_iomap
#include <linux/platform_device.h>  // platform_device
#include <linux/of.h>               // of_match_ptr
#include <linux/io.h>               // ioremap
#include <linux/interrupt.h>        // request_irq
#include <linux/delay.h>            // msleep
//#include <linux/types.h>            // atomic_t
#include <linux/init.h>             // Macros used to mark up functions e.g. __init __exit
//#include <linux/kdev_t.h>
#include <linux/device.h>
//#include <linux/version.h>
//#include <linux/kernel.h>
//#include <linux/of_platform.h>
//#include <linux/wait.h>             // Para la queue
#include <linux/semaphore.h>

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ DEFINES DRIVER +++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define FIRST_MINOR 0
#define COUNT_MINOR 1
#define COMPATIBLE "td3-spi"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++ FUNCTIONS ++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

static int spi_init(void);
static void spi_exit(void);

//Primitivas de las funciones de file_operations
static int spi_open (struct inode *, struct file *);
static int spi_close(struct inode *, struct file *);
static ssize_t spi_read (struct file *, char __user *, size_t, loff_t *);
static ssize_t spi_write (struct file *, const char __user *, size_t, loff_t *);
static long spi_ioctl(struct file *, unsigned int, unsigned long);

static int spi_probe (struct platform_device *);
static int spi_remove (struct platform_device *);

static irqreturn_t spi_irq_handler(int, void *, struct pt_regs *);
