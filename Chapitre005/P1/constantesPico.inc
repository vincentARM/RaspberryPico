/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ XOSC_BASE,      0x40024000
.equ XOSC_BASE_AND,  0x40026000
.equ TIMER_BASE,     0x40054000
.equ WATCHDOG_BASE,  0x40058000
.equ TIMELR,    0xC
.equ TIMEHR,    0x8
.equ WATCHDOG_CTRL,  0
.equ WATCHDOG_LOAD,  4
.equ WATCHDOG_TICK,  0x2C
.equ WATCHDOG_TICK_ENABLE_BITS,   0x00000200

.equ XOSC_CTRL_FREQ_RANGE_VALUE_1_15MHZ,    0xaa0
.equ XOSC_CTRL_ENABLE_VALUE_ENABLE,         0xfab
.equ XOSC_CTRL_ENABLE_LSB,                  12
.equ XOSC_STATUS_STABLE_BITS,               0x80000000
.equ STARTUP,      0xC
.equ STATUS,       4

