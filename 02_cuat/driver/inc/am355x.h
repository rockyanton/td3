//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ McSPI Registers ++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define MCSPI0_BASE     0x48030000
#define MCSPI1_BASE     0x481A0000
#define MCSPI0_LENGTH   0x1000
#define MCSPI_REVISION  0x0
#define MCSPI_SYSCONFIG 0x110
  #define MCSPI_SYSCONFIG_SET   0x110, 0x00000F1B , 0x308 // CLOCKACTIVITY: OCP and Functional clocks are maintained, SLIDEMODE: If an idle request is detected, the request is ignored and keeps on behaving normally, SOFTRESET: Normal mode, AUTOIDLE: OCP clock is free-running
#define MCSPI_SYSSTATUS 0x114
  #define MCSPI_SYSSTATUS_RESETDONE 0x114,  0x00000001
#define MCSPI_IRQSTATUS 0x118
#define MCSPI_IRQENABLE 0x11C
#define MCSPI_SYST      0x124
#define MCSPI_MODULCTRL 0x128
  #define MCSPI_MODULCTRL_SET    0x128, 0x000001FF, 0x2
#define MCSPI_C0CONF    0x12C
#define MCSPI_C0STAT    0x130
#define MCSPI_C0CTRL    0x134
#define MCSPI_TX0       0x138
#define MCSPI_RX0       0x13C
#define MCSPI_C1CONF    0x140
#define MCSPI_C1STAT    0x144
#define MCSPI_C1CTRL    0x148
#define MCSPI_TX1       0x14C
#define MCSPI_RX1       0x150
#define MCSPI_C2CONF    0x154
#define MCSPI_C2STAT    0x158
#define MCSPI_C2CTRL    0x15C
#define MCSPI_TX2       0x160
#define MCSPI_RX2       0x164
#define MCSPI_C3CONF    0x168
#define MCSPI_C3STAT    0x16C
#define MCSPI_C3CTRL    0x170
#define MCSPI_TX3       0x174
#define MCSPI_RX3       0x178
#define MCSPI_XFERLEVEL 0x17C
#define MCSPI_DAFTX     0x180
#define MCSPI_DAFRX     0x1A0

0011 0000 1000

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ CM_PER Registers +++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define CM_PER_BASE                                   0x44E00000
#define CM_PER_LENGTH                                 0x400

#define CM_PER_SPI0_CLKCTRL                           0x4C
  #define CM_PER_SPI0_CLKCTRL_MODULEMODE              0x4C, 0x00000003
    #define CM_PER_SPI0_CLKCTRL_MODULEMODE_DISABLED   0x4C, 0x00000003,  0x0
    #define CM_PER_SPI0_CLKCTRL_MODULEMODE_ENABLED    0x4C, 0x00000003,  0x2
  #define CM_PER_SPI0_CLKCTRL_IDLEST                  0x4C, 0x00030000
#define CM_PER_SPI1_CLKCTRL                           0x50
  #define CM_PER_SPI1_CLKCTRL_MODULEMODE              0x50, 0x00000003
    #define CM_PER_SPI1_CLKCTRL_MODULEMODE_DISABLED   0x50, 0x00000003,  0x0
    #define CM_PER_SPI1_CLKCTRL_MODULEMODE_ENABLED    0x50, 0x00000003,  0x2
  #define CM_PER_SPI1_CLKCTRL_IDLEST                  0x50, 0x00030000

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Control Module Registers ++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define CONTROL_MODULE_BASE                 0x44E10000
#define CONTROL_MODULE_LENGTH               0x2000

#define CONTROL_MODULE_SPI0_SCLK            0x950
  #define CONTROL_MODULE_SPI0_SCLK_ENABLE   0x950,  0x0000003F,  0x30   // Slowe slew rate, Receiver enabled, Pulldown selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_D0              0x954
  #define CONTROL_MODULE_SPI0_D0_ENABLE     0x954,  0x0000003F,  0x20   // Slowe slew rate, Receiver disabled, Pulldown selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_D1              0x958
  #define CONTROL_MODULE_SPI0_D1_ENABLE     0x958,  0x0000003F,  0x30   // Slowe slew rate, Receiver enabled, Pulldown selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_CS0             0x95C
#define CONTROL_MODULE_SPI0_CS1             0x960


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++ Functions ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// void set_registers(uint32_t *base, uint32_t offset, uint32_t mask, uint32_t value) {
void      set_registers (volatile void *, uint32_t, uint32_t, uint32_t);
// uint32_t get_registers(uint32_t *base, uint32_t offset, uint32_t mask) {
uint32_t  get_registers (volatile void *, uint32_t, uint32_t);
