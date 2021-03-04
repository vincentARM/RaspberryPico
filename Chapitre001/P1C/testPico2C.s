/* Programme assembleur ARM Raspberry pico */
/*  */
/* test Clignotement LED en assembleur  */
/* tout assembleur   y compris la fonction d'attente */ 
.syntax unified             @ non obligatoire
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/* L'include des constantes générales est   */
/* en fin du programme                      */
/********************************************/
.equ IOPORT,          0xD0000000
.equ IO_BANK0_BASE,   0x40014000
.equ PADS_BANK0_BASE, 0x4001C000
.equ GPIO0,   4
.equ GPIO0_CTRL,  4
.equ LED_PIN, 25
.equ GPIO_OUT, 1
.equ GPIO_IN,  0

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

.equ IO_BANK0_GPIO0_CTRL_FUNCSEL_LSB,  0
.equ PADS_BANK0_GPIO0_OD_BITS,         0x00000080
.equ PADS_BANK0_GPIO0_IE_BITS,         0x00000040
/*******************************************/
/*         Structures                      */
/*******************************************/
/*  définitions SIO */
    .struct  0
sio_cpuid:                     @  0 = UC 0   1 = UC 1 
    .struct  sio_cpuid + 4 
sio_gpio_in:
    .struct  sio_gpio_in + 4 
sio_gpio_hi_in:
    .struct sio_gpio_hi_in + 4
sio_pad:
    .struct  sio_pad + 4 

sio_gpio_out:                       @ 16
    .struct  sio_gpio_out + 4 
sio_gpio_set:                       @
    .struct  sio_gpio_set + 4 
sio_gpio_clr:                       @ 
    .struct  sio_gpio_clr + 4 
sio_gpio_togl:
    .struct  sio_gpio_togl + 4 
sio_gpio_oe:                         @ 32
    .struct  sio_gpio_oe + 4         
sio_gpio_oe_set:                     @ 36
    .struct  sio_gpio_oe_set + 4
sio_gpio_oe_clr:                     @ 40
    .struct  sio_gpio_oe_clr + 4     
sio_gpio_oe_togl:
    .struct  sio_gpio_oe_togl + 4 
sio_gpio_hi_out:
    .struct  sio_gpio_hi_out + 4 
sio_gpio_hi_set:
    .struct  sio_gpio_hi_set + 4 
sio_gpio_hi_clr:
    .struct  sio_gpio_hi_clr + 4 
sio_gpio_hi_togl:
    .struct  sio_gpio_hi_togl + 4 
sio_gpio_hi_oe:
    .struct  sio_gpio_hi_oe + 4 
sio_gpio_hi_oe_set:
    .struct  sio_gpio_hi_oe_set + 4 
sio_gpio_hi_oe_clr:
    .struct  sio_gpio_hi_oe_clr + 4 
sio_gpio_hi_oe_togl:
    .struct  sio_gpio_hi_oe_togl + 4 
   
    // à completer
sio_fin:
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
.thumb
.global main
.thumb_func
main:                           @ routine
    push {r1,lr}                @ save des  registres 
    movs r0,#LED_PIN            @ pin de la led
    movs r1,#GPIO_FUNC_SIO      @ code fonction
    bl initGpio
    movs r0,#LED_PIN
    movs r1,#GPIO_OUT
    bl seldirGpio               @ direction sortie
1:
    movs r0,#LED_PIN
    movs r1,#1                  @ allumage de la led
    bl putGpio
    movs r0, #250               @ attente
    bl attendre
    movs r0,#LED_PIN            @ extinction de la led
    movs r1,#0
    bl putGpio
    movs r0, #250
    bl attendre
    b 1b                        @ et boucle
100:                            @ fin de programme standard  mais jamais atteint
    pop {r1,pc}                 @ restaur des  registres 
.align 2


/************************************/
/*       init gpio               */
/***********************************/
/* r0 pin   */
/* r1 code fonction */
.thumb_func
initGpio:
    push {r4,lr}
    movs r3,#1
    lsls r3,r3,r0                 @ position pin
    ldr r2,iAdrIoport
    str r3,[r2,#sio_gpio_oe_clr]  @ 1 -> registre clear à la position pin
    str r3,[r2,#sio_gpio_clr]     @ 1 -> registre clear à la position pin
    bl gpioSetFonction
    pop {r4,pc}
.align 2
/************************************/
/*       fonction              */
/***********************************/
/* r0 pin   */
/* r1 code fonction */
.thumb_func
gpioSetFonction:              @ INFO: gpioSetFonction
    push {r4,lr}
    ldr r2,iAdrAdrPad0        @ adresse du bloc des registres pad
    adds r2,#GPIO0            @ pour sauter le premier registre
    lsls r3,r0,#2             @ pin position * 4 (4 octets  par pin gpio registres User Bank Pad Control)
    adds r3,r2
    ldr r4,[r3]               @ charge le registre pad correspondant à la position pin
    movs r2,#PADS_BANK0_GPIO0_IE_BITS
    eors r4,r2
    movs r2,#PADS_BANK0_GPIO0_IE_BITS | PADS_BANK0_GPIO0_OD_BITS
    ands r4,r2
    ldr r2,iAdrAdrPad0Xor
    lsls r3,r0,#2             @ pin position * 4 (idem plus haut)
    adds r2,r3
    str r4,[r2]
    
    ldr r2,iAdrAdrIOBank0     @ adresse IO_BANK0_BASE
    lsls r3,r0,#3             @ pin position * 8    (1 registre status + 1 registre ctrl par pin gpio)
    adds r3,r2                @ ajout position pin * 8
    str r1,[r3,#GPIO0_CTRL]   @ stocke code fonction
    
    pop {r4,pc}
.align 2
iAdrAdrIOBank0:    .int IO_BANK0_BASE
iAdrAdrPad0:       .int PADS_BANK0_BASE
iAdrAdrPad0Xor:    .int PADS_BANK0_BASE + 0x1000   @ write xor registre
/************************************/
/*       Put pin gpio               */
/***********************************/
/* r0 pin   */
/* r1 valeur */
.thumb_func
putGpio:
    movs r3,#1
    lsls r3,r3,r0                 @ bit correspondant au pin gpio
    ldr r2,iAdrIoport
    cmp r1,#1                     @ suivant la valeur
    bne 1f
    str r3,[r2,#sio_gpio_set]     @ registre set 
    b 2f
1:
    str r3,[r2,#sio_gpio_clr]     @ registre clear
2:
    bx lr
/************************************/
/*       get pin gpio               */
/***********************************/
/* r0 pin   */
.thumb_func
getGpio:                           // TODO: NON TESTE
    movs r3,#1
    lsls r3,r3,r0
    ldr r2,iAdrIoport
    ldr r1,[r2,#sio_gpio_in]        // charge le registre
    ands r1,r3                      // extrait le bit correspondant au pin
    lsrs r1,r1,r0                   // déplacement à droite
    movs r0,r1
    bx lr
/************************************/
/*       select direction pin gpio   */
/***********************************/
/* r0 pin   */
/* r1 value */
.thumb_func
seldirGpio:
    movs r3,#1
    lsls r3,r3,r0                  @ bit correspondant au pin gpio
    ldr r2,iAdrIoport
    cmp r1,#1
    bne 1f
    str r3,[r2,#sio_gpio_oe_set]   @ refistre set
    b 2f
1:
    str r3,[r2,#sio_gpio_oe_clr]   @ registre clear
2:
    bx lr
.align 2
iAdrIoport:      .int IOPORT

/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:
    lsls r0,#16             @ approximatif TODO: à verifier avec le timer
1:
    subs r0,r0,#1
    bgt 1b
    bx lr
    
    
