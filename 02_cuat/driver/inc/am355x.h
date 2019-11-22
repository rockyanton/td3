//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++ McSPI Registers ++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define MCSPI0_BASE     0x48030000
#define MCSPI0_LENGTH   0x1000
#define MCSPI_REVISION  0x0
#define MCSPI_SYSCONFIG 0x110
  #define MCSPI_SYSCONFIG_SET         0x110, 0x0000031B , 0x308 // xx 11 xxx 01 x 0 0
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
  #define MCSPI_IRQSTATUS_CH0_CLEAR           0x118, 0x0002777F, 0xFFFFF
  #define MCSPI_IRQSTATUS_CH0_GET             0x118, 0x0002777F
  #define MCSPI_IRQSTATUS_RX0_FULL_STATUS     0x118, 0x04
  #define MCSPI_IRQSTATUS_RX0_FULL_CLEAR      0x118, 0x04, 0xFFFFF
  #define MCSPI_IRQSTATUS_RX0_FULL_SET        0x4
  #define MCSPI_IRQSTATUS_TX0_EMPTY_CLEAR     0x118, 0x01, 0xFFFFF
  #define MCSPI_IRQSTATUS_TX0_EMPTY_SET       0x1
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit//     Field     //                                      Description                                    //                  Set                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 17 //     EOW       // End of word (EOW) count event when a channel is enabled using the FIFO buffer and   // Default                                 //
    //    //               // the channel has sent the number of McSPI words defined by the MCSPI_XFERLEVEL[WCNT].// Default                                 //
    // 14 //    RX3_FULL   // Receiver register full or almost full                                               // Default                                 //
    // 13 // TX3_UNDERFLOW // Transmitter register underflow (Channel 3).                                         // Default                                 //
    // 12 //    TX3_EMPTY  // Transmitter register empty or almost empty (Channel 3).                             // Default                                 //
    // 10 //    RX2_FULL   // Receiver register full or almost full (Channel 2).                                  // Default                                 //
    //  9 // TX2_UNDERFLOW // Transmitter register underflow (Channel 2).                                         // Default                                 //
    //  8 //    TX2_EMPTY  // Transmitter register empty or almost empty (Channel 2).                             // Default                                 //
    //  6 //    RX1_FULL   // Receiver register full or almost full (Channel 1).                                  // Default                                 //
    //  5 // TX1_UNDERFLOW // Transmitter register underflow (Channel 1).                                         // Default                                 //
    //  4 //   TX1_EMPTY   // Transmitter register empty or almost empty (Channel 1).                             // Default                                 //
    //  3 // RX0_OVERFLOW  // Receiver register overflow (slave mode only) (Channel 0).                           // 0h (W) = Event status bit is unchanged. //
    //  2 //    RX0_FULL   // Receiver register full or almost full (Channel 0).                                  // 0h (W) = Event status bit is unchanged. //
    //  1 // TX0_UNDERFLOW // Transmitter register underflow (Channel 0).                                         // 0h (W) = Event status bit is unchanged. //
    //  0 //    TX0_EMPTY  // Transmitter register empty or almost empty (Channel 0).                             // 0h (W) = Event status bit is unchanged. //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_IRQENABLE 0x11C
  #define MCSPI_IRQENABLE_RX0_FULL    0x11C, 0x0002777F, 0x4
  #define MCSPI_IRQENABLE_DISABLE_ALL 0x11C, 0x0002777F, 0x0
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit//         Field         //                                      Description                                    //           Set               //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 17 //         EOWKE         // End of word count interrupt enable                                                  // 0h = Interrupt is disabled. //
    // 14 //    RX3_FULL__ENABLE   // MCSPI_RX3 receiver register full or almost full interrupt enable (channel 3).       // 0h = Interrupt is disabled. //
    // 13 // TX3_UNDERFLOW__ENABLE // MCSPI_TX3 transmitter register underflow interrupt enable (channel 3).              // 0h = Interrupt is disabled. //
    // 12 //    TX3_EMPTY__ENABLE  // MCSPI_TX3 transmitter register empty or almost empty interrupt enable (channel 3).  // 0h = Interrupt is disabled. //
    // 10 //    RX2_FULL__ENABLE   // MCSPI_RX2 receiver register full or almost full interrupt enable (channel 2).       // 0h = Interrupt is disabled. //
    //  9 // TX2_UNDERFLOW__ENABLE // MCSPI_TX2 transmitter register underflow interrupt enable (channel 2).              // 0h = Interrupt is disabled. //
    //  8 //    TX2_EMPTY__ENABLE  // MCSPI_TX2 transmitter register empty or almost empty interrupt enable (channel 2).  // 0h = Interrupt is disabled. //
    //  6 //    RX1_FULL__ENABLE   // MCSPI_RX1 receiver register full or almost full interrupt enable (channel 1).       // 0h = Interrupt is disabled. //
    //  5 // TX1_UNDERFLOW__ENABLE // MCSPI_TX1 transmitter register underflow interrupt enable (channel 1).              // 0h = Interrupt is disabled. //
    //  4 //   TX1_EMPTY__ENABLE   // MCSPI_TX1 transmitter register empty or almost empty interrupt enable (channel 1).  // 0h = Interrupt is disabled. //
    //  3 // RX0_OVERFLOW__ENABLE  // MCSPI_RX0 receivier register overflow interrupt enable (channel 0).                 // 0h = Interrupt is disabled. //
    //  2 //    RX0_FULL__ENABLE   // MCSPI_RX0 receiver register full or almost full interrupt enable (channel 0).       // 0h = Interrupt is disabled. //
    //  1 // TX0_UNDERFLOW__ENABLE // MCSPI_TX0 transmitter register underflow interrupt enable (channel 0).              // 0h = Interrupt is disabled. //
    //  0 //    TX0_EMPTY__ENABLE  // MCSPI_TX0 transmitter register empty or almost empty interrupt enable (channel 0).  // 0h = Interrupt is disabled. //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_SYST      0x124
#define MCSPI_MODULCTRL 0x128
  #define MCSPI_MODULCTRL_SET         0x128, 0x000001FF, 0x01
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //    Field    //                                                    Description                                                              //                             Set                                   //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  8  //     FDA     // FIFO DMA Address 256 bit aligned                                                                                            // 0h = FIFO data managed by MCSPI_TX(i) and MCSPI_RX(i) registers.  //
    //  7  //     MOA     // It allows the system to perform multiple SPI word access for a single 32 bit OCP word access.                               // 0h = Multiple word access disabled                                //
    // 6-4 //   INITDLY   // The controller waits for a delay to transmit the first SPI word after channel enabled and corresponding TX register filled. // 0h = No delay for first SPI transfer                              //
    //  3  // SYSTEM_TEST // Enables the system test mode                                                                                                // 0h = Functional mode                                              //
    //  2  //      MS     // Master/ Slave                                                                                                               // 0h = Master - The module generates the SPICLK and SPIEN[3:0]      //
    //  1  //    PIN34    // Pin mode selection.                                                                                                         // 0h = SPIEN is used as a chip select.                              //
    //  0  //   SINGLE    // Single channel / Multi Channel (master mode only).                                                                          // 1h = Only one channel will be used in master mode.                //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define MCSPI_CH0CONF    0x12C
  #define MCSPI_CH0CONF_STANDBY   0x12C, 0x3FFFFFFF, 0x000107DF // FORCE 0 EPOL1
  #define MCSPI_CH0CONF_SENDING   0x12C, 0x3FFFFFFF, 0x001107DF // FORCE 1 EPOL1
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //    Field    //                               Description                                  //                                    Set                                       //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //   29  //   CLKG   // Clock divider granularity.                                                  // 0h = Clock granularity of power of 2.                                        //
    //   28  //   FFER   // FIFO enabled for receive.                                                   // 0h = The buffer is not used to receive data.                                 //
    //   27  //   FFEW   // FIFO enabled for transmit.                                                  // 0h = The buffer is not used to transmit data.                                //
    // 26-25 //    TCS   // Chip select time control.                                                   // 0h = 0.5 clock cycles.                                                       //
    //   24  //   SBPOL  // Start bit polarity.                                                         // 0h = Start bit polarity is held to 0 during SPI transfer.                    //
    //   23  //    SBE   // Start bit enable for SPI transfer.                                          // 0h = Default SPI transfer lenght as specified by WL bit field.               //
    // 22-21 // SPIENSLV // Channel 0 only and slave mode only: SPI slave select signal detection.      // 0h = Detection enabled only on SPIEN[0].                                     //
    //   20  //   FORCE  // Manual SPIEN assertion.                                                     // 0h = Drives high SPIEN line (EPOL=1) // 1h = Drives low SPIEN line (EPOL=1)  //
    //   19  //   TURBO  // Turbo mode.                                                                 // 0h = Turbo mode is deactivated.                                              //
    //   18  //    IS    // Input select.                                                               // 0h = SPIDAT[0] (21) selected for reception.                                  //
    //   17  //   DPE1   // Transmission enable for data line 1 (SPIDATAGZEN[1]).                       // 0h = SPIDAT[1] (18) selected for transmission.                               //
    //   16  //   DPE0   // Transmission enable for data line 0 (SPIDATAGZEN[0]).                       // 1h = No data transmission  on SPIDAT[0] (21).                                //
    //   15  //   DMAR   // DMA read request.                                                           // 0h = DMA read request is disabled.                                           //
    //   14  //   DMAW   // DMA write request.                                                          // 0h = DMA write request is disabled.                                          //
    // 13-12 //   TRM    // Transmit/receive modes.                                                     // 0h = Transmit and receive mode.                                              //
    // 11-7  //    WL    // SPI word length.                                                            // 0Fh = The SPI word is 16-bits long.                                          //
    //   6   //   EPOL   // SPIEN polarity.                                                             // 1h = SPIEN is held low during the active state.                              //
    //  5-2  //   CLKD   // Frequency divider for SPICLK (only when the module is a Master SPI device). // 7h = Divide by 128.                                                          //
    //   1   //    POL   // SPICLK polarity.                                                            // 1h = SPICLK is held low during the active state.                             //
    //   0   //    PHA   // SPICLK phase.                                                               // 1h = Data are latched on even numbered edges of SPICLK.                      //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MCSPI_CH0STAT    0x130
  #define MCSPI_CH0STAT_RXS    0x130, 0x1
  #define MCSPI_CH0STAT_TXS    0x130, 0x2
  #define MCSPI_CH0STAT_EOT    0x130, 0x4
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit// Field //             Description           //                                    Set                                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 6 // RXFFF // FIFO receive buffer full status.   // 0h = FIFO receive buffer is not full.                                     //
    // 5 // RXFFE // FIFO receive buffer empty status.  // 0h = FIFO receive buffer is not empty.                                    //
    // 4 // TXFFF // FIFO transmit buffer full status.  // 0h = FIFO transmit buffer is not full.                                    //
    // 3 // TXFFE // FIFO transmit buffer empty status. // 0h = FIFO transmit buffer is not empty.                                   //
    // 2 //  EOT  // end-of-transfer status.            // 1h = This flag is automatically set to one at the end of an SPI transfer. //
    // 1 //  TXS  // transmitter register status.       // 0h = Register is full.                                                    //
    // 0 //  RXS  // receiver register status.          // 0h = Register is empty.                                                   //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
  #define CONTROL_MODULE_SPI0_SCLK_RX_PULLUP  0x950,  0x0000003F,  0x30   // Slow slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, Primary Mode
#define CONTROL_MODULE_SPI0_D0              0x954
  #define CONTROL_MODULE_SPI0_D0_RX_PULLDOWN  0x954,  0x0000003F,  0x20   // Slow slew rate, Receiver enabled, Pulldown selected, Pullup/pulldown enabled, Primary Mode
#define CONTROL_MODULE_SPI0_D1              0x958
  #define CONTROL_MODULE_SPI0_D1_RX_PULLUP    0x958,  0x0000003F,  0x30   // Slow slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, Primary Mode
#define CONTROL_MODULE_SPI0_CS0             0x95C
  #define CONTROL_MODULE_SPI0_CS0_RX_PULLUP   0x95C,  0x0000003F,  0x30   // Slow slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, Primary Mode
#define CONTROL_MODULE_SPI0_CS1             0x960
  #define CONTROL_MODULE_SPI0_CS1_RX_PULLUP   0x960,  0x0000003F,  0x30   // Slow slew rate, Receiver enabled, Pullup selected, Pullup/pulldown enabled, Primary Mode


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Bit //    Field    //                Description                 //                    Set                      //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  6  //   SLEWCTRL  // Select between faster or slower slew rate. // 0: Fast              // 1: Slow             //
    //  5  //   RXACTIVE  // Input enable value for the PAD.            // 0: Receiver disabled // 1: Receiver enabled //
    //  4  // PULLTYPESEL // Pad pullup/pulldown type selection.        // 0: Pulldown          // 1: Pullup           //
    //  3  //  PULLUDEN   // Pad pullup/pulldown enable.                // 0: enabled           // 1: Disabled         //
    // 2-0 //   MUXMODE   // Pad functional signal mux select.          // 0: Primary Mode = Mode 0                    //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++ Functions ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// Generales para editar registros
void      set_registers (volatile void *base, uint32_t offset, uint32_t mask, uint32_t value);
uint32_t  get_registers (volatile void *base, uint32_t offset, uint32_t mask);

// Registros de estado SPI
void get_spi_transfer_status (void);
uint32_t spi_data_is_sent (void);
uint32_t spi_data_to_read (void);
uint32_t spi_data_eot (void);
