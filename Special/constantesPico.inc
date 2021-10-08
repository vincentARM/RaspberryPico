/*********************************************/
/*           CONSTANTES                      */
/********************************************/
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
.equ SIOBASE_CPUID,   0
.equ SIOBASE_GPIO_IN,   4
.equ SIOBASE_GPIO_HI_IN,   8  @  TODO: à compléter
.equ SIOBASE_FIF0_ST,     0x50
.equ SIOBASE_FIF0_WR,     0x54
.equ SIOBASE_FIF0_RD,     0x58

.equ IO_BANK0_BASE, 0x40014000
.equ PADS_BANK0_BASE, 0x4001C000
.equ GPIO0,   4
.equ GPIO0_CTRL,  4



.equ LED_PIN, 25
.equ GPIO_OUT, 1
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

.equ CHARPOS,    '@'
.equ HEAPSIZE,   2000
