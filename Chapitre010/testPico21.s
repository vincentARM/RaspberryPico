/* Programme assembleur ARM Raspberry pico */
/* Clignonement LED et variation */
/*  SANS UTILISATION DE LA STDLIB    */
/* merci à  Matthias Koch et Robert Clausecker pour leurs exemples de programmation */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/

.equ LED_PIN, 25
.equ GPIO_FUNC_SIO,   5

.equ GPIO_25_STATUS,  IO_BANK0_BASE + 8 * 24
.equ GPIO_25_CTRL,    IO_BANK0_BASE + 8 * 25 + 4

.equ IO_BANK0_BASE,   0x40014000

.equ RESETS_BASE,       0x4000c000
.equ RESETS_RESET,      0
.equ RESETS_WDSEL,      4
.equ RESETS_RESET_DONE, 8


.equ PLL_USB_BASE,    0x4002c000
.equ RESETS_RESET_IO_QSPI_BITS,     0x00000040    @ ces sous systèmes ne doivent pas être réinitialiser
.equ RESETS_RESET_PADS_QSPI_BITS,   0x00000200
.equ RESETS_RESET_PLL_USB_BITS,     0x00002000
.equ RESETS_RESET_PLL_SYS_BITS,     0x00001000

.equ CLOCKS_BASE, 0x40008000
.equ CLK_REF_CTRL,      0x30     @ Clock control, can be changed on-the-fly
.equ CLK_PERI_CTRL,     0x48     @ Clock control, can be changed on-the-fly
.equ CLK_ADC_CTRL,      0x60
.equ CLK_ADC_SELECTED,   0x68
.equ CLK_SYS_RESUS_CTRL, 0x78


@ -----------------------------------------------------------------------------
@ Crystal Oscillator
@ -----------------------------------------------------------------------------

.equ XOSC_BASE, 0x40024000

.equ XOSC_CTRL,         0x00     @ Crystal Oscillator Control
.equ XOSC_STATUS,       0x04     @ Crystal Oscillator Status
.equ XOSC_DORMANT,      0x08     @ Crystal Oscillator pause control
.equ XOSC_STARTUP,      0x0c     @ Controls the startup delay
.equ XOSC_COUNT,        0x1c     @ A down counter running at the XOSC frequency
                                 @ which counts to zero and stops.

.equ XOSC_ENABLE_12MHZ, 0xfabaa0
.equ XOSC_DELAY,        47       @ ceil((f_crystal * t_stable) / 256)

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



/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data


.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                                 @ début programme
    ldr r0,iAdrResetBaseClr           @ reset général sauf 4 sous systèmes 
    ldr r1,iparReset
    mvns r1,r1                        @ inversion des bits 
    str r1,[r0,RESETS_RESET]
    
    ldr r2,iAdrResetBase
1:
    ldr r3,[r2,#RESETS_RESET_DONE]    @ boucle attente reset ok
    tst r3,r1
    beq 1b
    
    movs r1,0
    ldr r4,iAdrClocks                 @ adresse de base des horloges
    str  r1, [r4, #CLK_SYS_RESUS_CTRL]
    
    ldr r6,iAdrOscBase                @ activation de l'oscillateur xOSC
    ldr r5,iParamDel
    str  r5, [r6, #XOSC_STARTUP]      @ A value of 47 for XOSC_DELAY would suffice,
                                      @ but writing 0x301 to is saves one opcode.
    ldr r3,iParamOsc
    str  r3, [r6, #XOSC_CTRL]         @ Activate XOSC. r3 = XOSC_ENABLE_12MHZ

2:  ldr  r0, [r6, #XOSC_STATUS]       @ Wait for stable flag (in MSB)
    asrs r0, r0, 31
    bpl  2b
    
    movs r1,#2
    str  r1, [r4, #CLK_REF_CTRL]      @ Select XOSC as source for clk_ref,
                                      @ which is the clock source of
                                      @ everything in reset configuration.
                                      @ r1 = 2, r4 = CLOCKS_BASE


    ldr  r1, iAdrGPIO_25_CTRL         @ init fonction GPIO
    movs r0,  GPIO_FUNC_SIO
    str  r0, [r1]                     @ fonction 5 pour le pin 25 = LED

    ldr  r1,iAdrSIO_BASE
    movs r0,1
    lsls r0,LED_PIN
    str  r0, [r1, #GPIO_OE_SET]       @ sortie pour le pin 25

    movs r0,2                         
    bl ledEclats
    
    movs r0,5
    bl variaLED
    
    movs r0,10
    bl ledEclats
    

100:                            @ boucle pour fin de programme standard  
    b 100b
.align 2
iAdrResetBase:        .int RESETS_BASE
iAdrResetBaseClr:     .int RESETS_BASE + 0x3000
iparReset:            .int (RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS| RESETS_RESET_PLL_USB_BITS |  RESETS_RESET_PLL_SYS_BITS) 
/************************************/
iAdrClocks:         .int CLOCKS_BASE
iAdrOscBase:        .int XOSC_BASE
iParamOsc:          .int XOSC_ENABLE_12MHZ
iParamDel:          .int 0x301
iAdrGPIO_25_CTRL:   .int GPIO_25_CTRL

/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.thumb_func
ledEclats:
    push {r1-r4,lr}
    movs r4,r0
    movs r2,#1
    lsls r2,#LED_PIN
    ldr  r3,iAdrSIO_BASE
1:
    str r2,[r3,GPIO_OUT_SET]
    movs r0, #250
    bl attendre
    str r2,[r3,GPIO_OUT_CLR]
    movs r0, #250
    bl attendre 
    subs r4,1
    bgt 1b 
    
    pop {r1-r4,pc}
    
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
/* r1 non sauvegardé */
.thumb_func
attendre:
    lsls r0,r0,13             @ approximatif
1:
    subs r0,r0, 1
    bne 1b
    bx lr
    
/************************************/
/*       LED  variation             */
/***********************************/
/* r0 contient le nombre de variation    */
.thumb_func
variaLED:
    push {r1-r7,lr}
    mov r4,r0                    @ save nombre de variations
    movs r2,#1
    lsls r2,#LED_PIN
    ldr  r3,iAdrSIO_BASE
    movs r6, 1
    lsls r6, r6, 9               @ X valeur initiale 512
    movs r5,#0                   @ init Y
1:
    movs r7,#128
2:                               @ debut de boucle
                                 @ algorithme du cercle de Minsky
    asrs r1, r5, 5               @ -dx = y >> 5
    subs r6, r1                  @  x += dx
    asrs r1, r6, 5               @  dy = x >> 5
    adds r5, r1                  @  y += dy
    
    movs r0,1                    @ calcul temps d'allumage
    lsls r0,9
    adds r0,r6                   @ ajout de 512 pour être tj positif
    movs r1,1
    lsls r1,10                   @ calcul temps d'extinction (1024 - temps d'allumage)
    adds r1,#1
    subs r1,r1,r0
 
    str  r2,[r3,GPIO_OUT_SET]   @ allumage Led
    
    lsls r0,#6                  @ approximatif 
3:                              @ boucle temps d'allumage
    subs r0,r0, 1
    bne 3b
 
    str  r2,[r3,GPIO_OUT_CLR]   @ extinction Led

    lsls r1,#6                  @ approximatif 
4:                              @ boucle temps d'extinction 
    subs r1,r1, 1
    bne 4b 

    subs r7,1                   @ décrement durée 
    bgt 2b                      @ et boucle
    
    subs r4,1                   @ decrément nombre de variations
    bge 1b                      @ et boucle
    
    pop {r1-r7,pc}
.align 2
iAdrSIO_BASE:      .int SIO_BASE
