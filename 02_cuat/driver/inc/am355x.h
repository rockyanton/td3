//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ McSPI Registers ++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define MCSPI0_BASE     0x48030000
#define MCSPI0_LENGTH   0x1000
#define MCSPI_REVISION  0x0
#define MCSPI_SYSCONFIG 0x110
  #define MCSPI_SYSCONFIG_SET         0x110, 0x0000031B , 0x308 // xx 11 xxx 01 x 0 0
  //#define MCSPI_SYSCONFIG_SET         0x110, 0x0000031B , 0x30
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //      Field     //                 Description                 //                                      Set                                                   //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 9-8 //  CLOCKACTIVITY // Clocks activity during wake-up mode period. // 3h = OCP and Functional clocks are maintained.                                             //
    // 4-3 //   SLIDEMODE    // Power management.                           // 1h = If an idle request is detected, the request is ignored and keeps on behaving normally //
    //  1  //   SOFTRESET    // Software reset.                             // 0h = (write) Normal mode.                                                                  //
    //  0  //    AUTOIDLE    // Internal OCP Clock gating strategy.         // 0h = OCP clock is free-running.                                                            //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_SYSSTATUS 0x114
  #define MCSPI_SYSSTATUS_RESETDONE   0x114,  0x00000001 // 1
    /////////////////////////////////////////////////////////////////////////////////////
    // Bit //   Field   //              Description            //        Set           //
    /////////////////////////////////////////////////////////////////////////////////////
    //  0  // RESETDONE // Internal OCP Clock gating strategy. // 1h = Reset completed //
    /////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_IRQSTATUS 0x118
#define MCSPI_IRQENABLE 0x11C
#define MCSPI_SYST      0x124
#define MCSPI_MODULCTRL 0x128
  #define MCSPI_MODULCTRL_SET         0x128, 0x000001FF, 0x2 // xxx 0 0 000 0 0 1 0
  //#define MCSPI_MODULCTRL_SET         0x128, 0x000001FF, 0x1
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //    Field    //                                                    Description                                                              //                                      Set                                                //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  8  //     FDA     // FIFO DMA Address 256 bit aligned                                                                                            // 0h = FIFO data managed by MCSPI_TX(i) and MCSPI_RX(i) registers.                        //
    //  7  //     MOA     // It allows the system to perform multiple SPI word access for a single 32 bit OCP word access.                               // 0h = Multiple word access disabled                                                      //
    // 6-4 //   INITDLY   // The controller waits for a delay to transmit the first SPI word after channel enabled and corresponding TX register filled. // 0h = No delay for first SPI transfer                                                    //
    //  3  // SYSTEM_TEST // Enables the system test mode                                                                                                // 0h = Functional mode                                                                    //
    //  2  //      MS     // Master/ Slave                                                                                                               // 0h = Master - The module generates the SPICLK and SPIEN[3:0]                            //
    //  1  //    PIN34    // Pin mode selection.                                                                                                         // 1h = SPIEN is not used. In this mode all related option to chip select have no meaning. //
    //  0  //   SINGLE    // Single channel / Multi Channel (master mode only).                                                                          // 0h = More than one channel will be used in master mode.                                 //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define MCSPI_CH0CONF    0x12C
  #define MCSPI_CH0CONF_SET            0x12C, 0x3FFFFFFF, 0x0001079F // Opcion Guido xx
  //#define MCSPI_CH0CONF_SET            0x12C, 0x3FFFFFFF, 0x031007EB // Opcion A
  //#define MCSPI_CH0CONF_SET            0x12C, 0x3FFFFFFF, 0x011603F3 // Opcion B
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //    Field    //                                                    Description                                                              //                                      Set                                                //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //   29  //    CLKG   // Clock divider granularity.
    //   28  //   FFER    // FIFO enabled for receive.
    //   27  //   FFEW    // FIFO enabled for transmit.
    // 26-25 //    TCS    // Chip select time control.
    //   24  //   SBPOL   // Start bit polarity.
    //   23  //    SBE    // Start bit enable for SPI transfer.
    // 22-21 // SPIENSLV  // Channel 0 only and slave mode only: SPI slave select signal detection.
    //   20  //   FORCE   // Manual SPIEN assertion to keep SPIEN active between SPI words (single channel master mode only).
    //   19  //   TURBO   // Turbo mode.
    //   18  //     IS    // Input select
    //   17  //    DPE1   // Transmission enable for data line 1 (SPIDATAGZEN[1])
    //   16  //    DPE0   // Transmission enable for data line 0 (SPIDATAGZEN[0])
    //   15  //    DMAR   // DMA read request.
    //   14  //    DMAW   // DMA write request.
    // 13-12 //     TRM   // Transmit/receive modes.
    // 11-7  //     WL    // SPI word length.
    //   6   //    EPOL   // SPIEN polarity
    //  5-2  //    CLKD   // Frequency divider for SPICLK (only when the module is a Master SPI device).
    //   1   //     POL   // SPICLK polarity
    //   0   //     PHA   // SPICLK phase
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#define MCSPI_CH0STAT    0x130
#define MCSPI_CH0CTRL    0x134
  #define MCSPI_CH0CTRL_SET_CLOCK      0x134, 0x0000FF01, 0x0  // 00000000 xxxxxxx 0
  #define MCSPI_CH0CTRL_ENABLE         0x134, 0x00000001, 0x1  // 00000000 xxxxxxx 1
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit  //  Field  //    Description         //                        Set                            //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 15-8 // EXTCLK // Clock ratio extension. // 0h = Clock ratio is CLKD + 1                           //
    //   0  //   EN   // Channel 0 enable.      // 0h = Channel 0 is not active.1h = Channel 0 is active. //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_TX0       0x138
#define MCSPI_RX0       0x13C
#define MCSPI_CH1CONF    0x140
#define MCSPI_CH1STAT    0x144
#define MCSPI_CH1CTRL    0x148
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

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Control Module Registers ++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define CONTROL_MODULE_BASE                 0x44E10000
#define CONTROL_MODULE_LENGTH               0x2000

#define CONTROL_MODULE_SPI0_SCLK            0x950
  #define CONTROL_MODULE_SPI0_SCLK_ENABLE   0x950,  0x0000003F,  0x30   // Slowe slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_D0              0x954
  #define CONTROL_MODULE_SPI0_D0_ENABLE     0x954,  0x0000003F,  0x20   // Slowe slew rate, Receiver disabled, Pulldown selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_D1              0x958
  #define CONTROL_MODULE_SPI0_D1_ENABLE     0x958,  0x0000003F,  0x30   // Slowe slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, mux select 0
#define CONTROL_MODULE_SPI0_CS0             0x95C
#define CONTROL_MODULE_SPI0_CS1             0x960


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++ Functions ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// void set_registers(uint32_t *base, uint32_t offset, uint32_t mask, uint32_t value) {
void      set_registers (volatile void *, uint32_t, uint32_t, uint32_t);
// uint32_t get_registers(uint32_t *base, uint32_t offset, uint32_t mask) {
uint32_t  get_registers (volatile void *, uint32_t, uint32_t);
