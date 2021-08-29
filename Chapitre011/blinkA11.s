/* Programme assembleur ARM Raspberry pico */
/* clignotement LED */
.syntax unified
.cpu cortex-m0plus
.thumb

.equ IO_BANK0_BASE,     0x40014000
.equ GPIO_25_CTRL,      IO_BANK0_BASE + 8 * 25 + 4
.equ LED_PIN,           25

.equ GPIO_FUNC_SIO,     5

.equ SIO_BASE,          0xD0000000

.equ CPUID          , 0x000 @ Processor core identifier
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

.equ RESETS_BASE,       0x4000c000
.equ RESETS_RESET,      0
.equ RESETS_WDSEL,      4
.equ RESETS_RESET_DONE, 8

.equ RESETS_RESET_IO_QSPI_BITS,     0x00000040    @ ces sous systèmes ne doivent pas être réinitialiser
.equ RESETS_RESET_PADS_QSPI_BITS,   0x00000200
.equ RESETS_RESET_PLL_USB_BITS,     0x00002000
.equ RESETS_RESET_PLL_SYS_BITS,     0x00001000

.equ CLOCKS_BASE, 0x40008000
.equ CLK_REF_CTRL,      0x30
.equ CLK_PERI_CTRL,     0x48
.equ CLK_ADC_CTRL,      0x60
.equ CLK_ADC_SELECTED,   0x68
.equ CLK_SYS_RESUS_CTRL, 0x78

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global principal
.thumb_func
principal:
    adr r0,zConstantes
    ldm  r0!, {r1-r4}               @ r1 RESETS_BASE + CLEAR
                                    @ r2 Paramètres
                                    @ r3 CLOCKS_BASE
                                    @ r4 GPIO_25_CTRL
    str r2,[r1,RESETS_RESET]        @ reset général sauf 4 sous systèmes 
    
    movs r1,#0
    str  r1, [r3, #CLK_REF_CTRL]    @ Select  source for clk_ref,
    
                                    @ initialisation GPIO
    movs r2,0xD             
    lsls r2,28                      @ calcul de l'adresse SIO_BASE
    movs r0, GPIO_FUNC_SIO
    str  r0, [r4]                   @ maj fonction gpio
    movs r3,1                       @ 
    lsls r3,25                      @ pin 25 = LED
    str  r3, [r2,GPIO_OE_SET]       @ sortie pour le pin 25

1:
    movs r0,5                       @ nombre d'éclats
    bl ledEclats


    movs r0,6                       @ attente  pour environ 30 secondes
    bl attendre
    b 1b                            @ et boucle 

/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.thumb_func
ledEclats:
    push {r1-r4,lr}
    movs r4,r0
    movs r2,#1
    lsls r2,#LED_PIN               @ pin 25 = LED
    movs r3,0xD             
    lsls r3,28                     @ calcul de l'adresse SIO_BASE
1:
    str r2,[r3,GPIO_OUT_SET]       @ allumage LED
    movs r0, #1
    bl attendre
    str r2,[r3,GPIO_OUT_CLR]       @ extinction LED
    movs r0, #2
    bl attendre 
    subs r4,1
    bgt 1b 
    
    pop {r1-r4,pc}
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur attente   */
.thumb_func
attendre:
    movs r1,100
    lsls r1,r0
    lsls r1,r1,11             @ compteur attente
1:
    subs r1,r1, 1
    bne 1b
    bx lr
.align 2
zConstantes:
iAdrResetBaseClr:       .int RESETS_BASE + 0x3000
iparReset:              .int ~(RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS| RESETS_RESET_PLL_USB_BITS |  RESETS_RESET_PLL_SYS_BITS) 
iAdrClocks:             .int CLOCKS_BASE 
iAdrPin25:              .int GPIO_25_CTRL



 