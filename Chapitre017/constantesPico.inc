/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ   FALSE, 0
.equ   TRUE,  1
.equ   PICO_OK,              0
.equ   PICO_ERROR_NONE,      0
.equ   PICO_ERROR_TIMEOUT,  -1
.equ   PICO_ERROR_GENERIC,  -2
.equ   PICO_ERROR_NO_DATA,  -3

.equ XOSC_BASE,      0x40024000
.equ XOSC_BASE_AND,  0x40026000
.equ TIMER_BASE,     0x40054000
.equ TIMER_TIMEHW,    0
.equ TIMER_TIMELW,    4
.equ TIMER_TIMEHR,    0x8
.equ TIMER_TIMELR,    0xC
.equ TIMER_ALARM0,    0x10
.equ TIMER_ALARM1,    0x14
.equ TIMER_ALARM2,    0x18
.equ TIMER_ALARM3,    0x1C
.equ TIMER_ARMED,     0x20
.equ TIMER_TIMERAWH,   0x24
.equ TIMER_TIMERAWL,    0x28
.equ TIMER_DBGPAUSE,    0x2c
.equ TIMER_PAUSE,       0x30
.equ TIMER_INTR,        0x34
.equ TIMER_INTE,        0x38
.equ TIMER_INTF,        0x3c
.equ TIMER_INTS,        0x40

.equ WATCHDOG_BASE,  0x40058000
.equ WATCHDOG_CTRL,  0
.equ WATCHDOG_LOAD,  4
.equ WATCHDOG_REASON,  8
.equ WATCHDOG_SCRATCH0,  0x0C
.equ WATCHDOG_SCRATCH1,  0x10
.equ WATCHDOG_SCRATCH2,  0x14
.equ WATCHDOG_SCRATCH3,  0x18
.equ WATCHDOG_SCRATCH4,  0x1C
.equ WATCHDOG_SCRATCH5,  0x20
.equ WATCHDOG_SCRATCH6,  0x24
.equ WATCHDOG_SCRATCH7,  0x28
.equ WATCHDOG_TICK,  0x2C
.equ WATCHDOG_TICK_ENABLE_BITS,   0x00000200

.equ XOSC_BASE,      0x40024000
.equ XOSC_BASE_AND,  0x40026000
.equ XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ,    0xaa0
.equ XOSC_CTRL_ENABLE_VALUE_ENABLE,         0xfab
.equ XOSC_CTRL_ENABLE_LSB,                  12
.equ XOSC_STATUS_STABLE_BITS,               0x80000000
.equ STARTUP,      0xC
.equ STATUS,       4

.equ RESETS_BASE,       0x4000c000
.equ RESETS_RESET,      0
.equ RESETS_WDSEL,      4
.equ RESETS_RESET_DONE, 8

.equ ADC_BASE,          0x4004c000
.equ ADC_CS,          0
.equ ADC_RESULT,      4
.equ ADC_FCS,         8
.equ ADC_FIFO,        0xC
.equ ADC_DIV,        0x10
.equ ADC_INTR,        0x14
.equ ADC_INTE,        0x18
.equ ADC_INTF,        0x1C
.equ ADC_INTS,        0x20

.equ PSM_BASE,  0x40010000
.equ PSM_FRCE_ON,   0
.equ PSM_FRCE_OFF,   4
.equ PSM_WDSEL,      8
.equ PSM_DONE,       0xC

.equ PSM_WDSEL_BITS,   0x0001ffff
.equ PSM_WDSEL_ROSC_BITS,   0x00000001
.equ PSM_WDSEL_XOSC_BITS,   0x00000002

.equ SIO_BASE,        0xD0000000


.equ SIOBASE_CPUID          , 0x000 @ Processor core identifier
.equ GPIO_IN        , 0x004 @ Input value for GPIO pins
.equ GPIO_HI_IN     , 0x008 @ Input value for QSPI pins
.equ GPIO_OUT       , 0x010 @ GPIO output value
.equ GPIO_OUT_SET   , 0x014 @ GPIO output value set
.equ GPIO_OUT_CLR   , 0x018 @ GPIO output value clear
.equ GPIO_OUT_XOR   , 0x01c @ GPIO output value XOR
.equ GPIO_OE        , 0x020 @ GPIO output enable
.equ GPIO_OE_SET    , 0x024 @ GPIO output enable set
.equ GPIO_OE_CLR    , 0x028 @ GPIO output enable clear
.equ GPIO_OE_XOR    , 0x02c @ GPIO output enable XOR
.equ GPIO_HI_OUT    , 0x030 @ QSPI output value
.equ GPIO_HI_OUT_SET, 0x034 @ QSPI output value set
.equ GPIO_HI_OUT_CLR, 0x038 @ QSPI output value clear
.equ GPIO_HI_OUT_XOR, 0x03c @ QSPI output value XOR
.equ GPIO_HI_OE     , 0x040 @ QSPI output enable
.equ GPIO_HI_OE_SET , 0x044 @ QSPI output enable set
.equ GPIO_HI_OE_CLR , 0x048 @ QSPI output enable clear
.equ GPIO_HI_OE_XOR , 0x04c @ QSPI output enable XOR


.equ SIOBASE_FIF0_ST,     0x50
.equ SIOBASE_FIF0_WR,     0x54
.equ SIOBASE_FIF0_RD,     0x58

.equ SIO_DIV_UDIVIDEND_OFFSET, 0x00000060
.equ SIO_DIV_UDIVISOR_OFFSET,  0x00000064
.equ SIO_DIV_QUOTIENT_OFFSET,  0x00000070
.equ SIO_DIV_REMAINDER_OFFSET, 0x00000074
.equ SIO_DIV_CSR_OFFSET,       0x00000078

.equ IO_BANK0_BASE, 0x40014000
.equ PADS_BANK0_BASE, 0x4001C000
.equ GPIO0,   4
.equ GPIO0_CTRL,  4



//.equ LED_PIN, 25
//.equ GPIO_OUT, 1
//.equ GPIO_IN,  0

.equ GPIO_FUNC_XIP,   0
.equ GPIO_FUNC_SPI,   1
.equ GPIO_FUNC_UART,  2
.equ GPIO_FUNC_I2C,   3
.equ GPIO_FUNC_PWM,   4
.equ GPIO_FUNC_SIO,   5
.equ GPIO_FUNC_PIO0,  6
.equ GPIO_FUNC_PIO1,  7
.equ GPIO_FUNC_GPCK,  8
.equ GPIO_FUNC_USB,   9
.equ GPIO_FUNC_NULL,  0xf

.equ PLL_USB_BASE,    0x4002c000

.equ USBCTRL_REGS_BASE,  0x50110000
.equ USB_ADDR_ENDP,       0
.equ USB_MAIN_CTRL,      0x40
.equ USB_SOF_WR,         0x44
.equ USB_SOF_RD,         0x48
.equ USB_SIE_CTRL,       0x4C
.equ USB_SIE_STATUS,     0x50
.equ USB_INT_EP_CTRL,    0x54
.equ USB_BUFF_STATUS,    0x58
.equ USB_BUFF_CPU,       0x5C
.equ USB_EP_ABORT,       0x60
.equ USB_EP_ABT_DONE,    0x64
.equ USB_EP_STALL_ARM,    0x68
.equ USB_NAK_POLL,       0x6C
.equ USB_EP_STATUS,      0x70
.equ USB_MUXING,         0x74
.equ USB_PWR,            0x78
.equ USB_USBPHY_DIRECT,   0x7C
.equ USB_USBPHY_DIR_OV,  0x80
.equ USB_PHY_TRIM,       0x84
.equ USB_INTR,           0x8C
.equ USB_INTE,           0x90
.equ USB_INTF,           0x94
.equ USB_INTS,           0x98

.equ RTC_BASE,           0x4005c000
.equ RTC_CLKDIV_M1,      0
.equ RTC_SETUP_0,        4
.equ RTC_SETUP_1,        8
.equ RTC_CTRL,           0xC
.equ RTC_IRQ_SETUP_0,    0x10
.equ RTC_IRQ_SETUP_1,    0x14
.equ RTC_RTC_1,          0x18
.equ RTC_RTC_0,          0x1C
.equ RTC_INTR,           0x20
.equ RTC_INTE,           0x24
.equ RTC_INTF,           0x28
.equ RTC_INTS,           0x2C

.equ SIO_FIFO_ST_RDY_BITS,   0x00000002
.equ SIO_FIFO_ST_VLD_BITS,   0x00000001

.equ PPB_BASE,   0xe0000000
.equ PPB_CPUID,  0xed00
.equ PPB_VTOR,   0xed08
.equ M0PLUS_NVIC_ISER_OFFSET, 0x0000e100
.equ M0PLUS_NVIC_ICPR_OFFSET, 0x0000e280
.equ M0PLUS_NVIC_ICER_OFFSET, 0x0000e180


.equ RESETS_BASE,     0x4000C000 
.equ RESET_RESET,     0
.equ RESET_DONE,      8
.equ RESETS_RESET_USBCTRL_BITS,   0x01000000
.equ RESETS_RESET_IO_QSPI_BITS,     0x00000040    @ ces sous systèmes ne doivent pas être réinitialiser
.equ RESETS_RESET_PADS_QSPI_BITS,   0x00000200
.equ RESETS_RESET_PLL_USB_BITS,     0x00002000
.equ RESETS_RESET_PLL_SYS_BITS,     0x00001000

.equ CLOCKS_BASE, 0x40008000
.equ CLK_REF_CTRL,      0x30
.equ CLK_SYS_CTRL,      0x3C
.equ CLK_PERI_CTRL,     0x48
.equ CLK_USB_CTRL,      0x54                    @ usb horloge
.equ CLK_USB_DIV,       0x58
.equ CLK_USB_SELECTED,   0x5C
.equ CLK_SYS_RESUS_CTRL, 0x78


@ -----------------------------------------------------------------------------
@ Crystal Oscillator
@ -----------------------------------------------------------------------------

.equ XOSC_BASE,         0x40024000

.equ XOSC_CTRL,         0x00     @ Crystal Oscillator Control
.equ XOSC_STATUS,       0x04     @ Crystal Oscillator Status
.equ XOSC_DORMANT,      0x08     @ Crystal Oscillator pause control
.equ XOSC_STARTUP,      0x0c     @ Controls the startup delay
.equ XOSC_COUNT,        0x1c     @ A down counter running at the XOSC frequency
                                 @ which counts to zero and stops.

.equ XOSC_ENABLE_12MHZ, 0xfabaa0
.equ XOSC_DELAY,        47       @ ceil((f_crystal * t_stable) / 256)


.equ CHARPOS,    '@'
.equ HEAPSIZE,   2000

.equ CLOCKS_BASE,    0x40008000
.equ FC0_REF_KHZ,    0x80
.equ FC0_MIN_KHZ,    0x84
.equ FC0_MAX_KHZ,    0x88
.equ FC0_DELAY,      0x8C
.equ FC0_INTERVAL,   0x90
.equ FC0_SRC,        0x94
.equ FC0_STATUS,     0x98
.equ FC0_RESULT,     0x9c

.equ CLOCKS_FC0_STATUS_RUNNING_BITS,   0x00000100
.equ CLOCKS_FC0_STATUS_DONE_BITS,      0x00000010
.equ CLOCKS_FC0_RESULT_KHZ_LSB,        5

.equ TIMER_BASE,     0x40054000
.equ WATCHDOG_BASE,  0x40058000
.equ TIMELR,    0xC
.equ TIMEHR,    0x8
.equ PPB_BASE,       0xE0000000
.equ SYST_CSR,       0xE010        // systick
.equ SYST_RVR,       0xE014
.equ SYST_CVR,       0xE018
