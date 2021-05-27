/* Programme assembleur ARM Raspberry pico */
/* utilisation du bouton pour allumer la led */
/* attention : ne fonctionne pas si programme seulement dans memoire flash */
/* mettre l'option pico_set_binary_type(testPico12 copy_to_ram) dans le CMakelists.txt */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "../constantesPico.inc"

.equ IOPORT,          0xD0000000
.equ IO_BANK0_GPIO0_CTRL_FUNCSEL_LSB,  0
.equ PADS_BANK0_GPIO0_OD_BITS,         0x00000080
.equ PADS_BANK0_GPIO0_IE_BITS,         0x00000040

.equ GPIO_OUT, 1
.equ GPIO_IN,  0

.equ IO_BANK0_BASE,     0x40014000
.equ GPIO_25_CTRL,    IO_BANK0_BASE + 8 * 25 + 4

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

.equ GPIO_OVERRIDE_NORMAL, 0
.equ GPIO_OVERRIDE_INVERT, 1
.equ GPIO_OVERRIDE_LOW,    2
.equ GPIO_OVERRIDE_HIGH,   3

.equ IO_QSPI_BASE,   0x40018000
.equ GPIO_QSPI_SCLK_STATUS,    0
.equ GPIO_QSPI_SCLK_CTRL,      4
.equ GPIO_QSPI_SS_STATUS,      8
.equ GPIO_QSPI_SS_CTRL,        0xC

.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_RESET,         0x0
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_BITS,          0x00003000
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_MSB,           13
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_LSB,           12
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_ACCESS,        "RW"
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_VALUE_NORMAL,  0x0
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_VALUE_INVERT,  0x1
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_VALUE_DISABLE, 0x2
.equ IO_QSPI_GPIO_QSPI_SS_CTRL_OEOVER_VALUE_ENABLE,  0x3

.equ RESETS_BASE,     0x4000C000
.equ RESET_RESET,     0
.equ RESET_WDSEL,     4
.equ RESET_DONE,      8
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
/* attention pas de save du registre d'état */
.macro afficherLib str 
    push {r0-r3}               @ save des registres car r1, r2 r3 écrasés par wrap_puts
    adr r0,libaff1\@           @ recup adresse libellé passé dans str
    bl __wrap_puts
    pop {r0-r3}                @ restaure des registres
    b smacroafficheMess\@      @ pour sauter le stockage de la chaine.
.align 2
libaff1\@:     .asciz "\str"
.align 2
smacroafficheMess\@:     
.endm   @ fin de la macro
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
szMessDebutPgm:     .asciz "Debut du programme."
szMessDemStd:       .asciz "Demarrage normal."
szMessDemWDog:      .asciz "Reboot par watchdog !!"

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:    .skip 80 
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ INFO: main
    bl stdio_init_all

1:                              @ début boucle attente connexion 
    movs r0, 0
    bl tud_cdc_n_connected      @ terminal connecté ?
    cmp r0, 0
    bne 2f                      @ oui
    movs r0, 100                @ sinon attente et boucle
    bl attendre
    b 1b
2:  
    ldr r0,iAdrszMessDebutPgm
    bl __wrap_puts
    bl lancerWatchDog           @ permet la relance auto du programme si blocage
3:                              @ boucle de lecture traitement des commandes
    movs r0, 200
    bl sleep_ms
    ldr r0,iAdrszMessCmd
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAff
    bl comparerChaines
    cmp r0, 0
    bne 4f
                                 @ affichage registre memoire
    bl cmdAffReg
    b 10f
4:                               @ affichage mémoire
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdMem
    bl comparerChaines
    cmp r0, 0
    bne 5f
    bl affZoneMem
    b 10f
5:                              @  reset du pico 
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFin
    bl comparerChaines
    cmp r0, 0
    bne 7f
    movs r0,200
    bl attendre
    movs r0,'U'                 @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
    b 10f

7:                              @ affichage registre binaire mémoire
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdBin
    bl comparerChaines
    cmp r0, 0
    bne 8f
    bl affRegBin
    b 10f
8:                              @ test de fonctions
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 9f
    
    bl boutonLed

    b 10f
9:    @ suite éventuelle
10:
    b 3b                        @ boucle commande
 
100:                            @ boucle pour fin de programme standard  
    b 100b
/************************************/
.align 2
iAdrszMessDebutPgm:     .int szMessDebutPgm
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdAff:        .int szLibCmdAff
iAdrszLibCmdMem:        .int szLibCmdMem
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszLibCmdBin:        .int szLibCmdBin
iAdrsBuffer:            .int sBuffer

/******************************************************************/
/*     lancement du watchdog                                         */ 
/******************************************************************/
/*                    */
.thumb_func
lancerWatchDog:               @ INFO: lancerWatchDog
    push {lr}
    ldr r2,iAdrWatchDogBase
    ldr r0,[r2,WATCHDOG_REASON]

    movs r1,0b11
    tst r0,r1
    bne 1f
    ldr r0,iAdrszMessDemStd
    b 2f
1: 
    ldr r0,iAdrszMessDemWDog
2:
    bl __wrap_puts
    ldr r1,iParCycles        @ lancement du compteur
    str r1,[r2,#WATCHDOG_TICK]
    ldr r1,iparWDem
    str r1,[r2,#WATCHDOG_CTRL]
    
    ldr r2,iAdrPsmBase
    ldr r1,iParPsm
    str r1,[r2,PSM_WDSEL]
    
    pop {pc}
.align 2
iAdrWatchDogBase:       .int WATCHDOG_BASE
iAdrWatchDogBaseXor:    .int WATCHDOG_BASE +0x1000
iAdrWatchDogBaseSet:    .int WATCHDOG_BASE +0x2000
iAdrWatchDogBaseClear:  .int WATCHDOG_BASE +0x3000
iAdrszMessDemStd:       .int szMessDemStd
iAdrszMessDemWDog:      .int szMessDemWDog
iParCycles:             .int WATCHDOG_TICK_ENABLE_BITS| 10
iparWDem:               .int 0x40000064       @ enable + 100ms
iAdrPsmBase:            .int PSM_BASE
iParPsm:                .int PSM_WDSEL_BITS & ~(PSM_WDSEL_ROSC_BITS |PSM_WDSEL_XOSC_BITS)


/******************************************************************/
/*     allumage de la Led avec le bouton                           */ 
/******************************************************************/
/*                    */
.thumb_func
boutonLed:                     @ INFO: boutonLed
    push {lr}
    afficherLib debutboutonled
    ldr r6,iAdrPin25
    movs r7,0xD             
    lsls r7,28                      @ calcul de l'adresse SIO_BASE
    movs r0, GPIO_FUNC_SIO
    str  r0, [r6]                   @ maj fonction gpio
    movs r6,1                       @ réutilisation de r6
    lsls r6,25                      @ attention sert ensuite à l allumage de la led
    str  r6, [r7, #sio_gpio_oe_set]
    movs r5,0xFF
1:
    bl etatPin                      @ teste l'état du bouton
    cmp r0,r5
    beq 3f
    mov r5,r0
    cmp r0,#0
    beq 2f
    str r6,[r7,#sio_gpio_set]       @ r7 = pin 25 allumage
    b 3f
2:                                  @ eteint la Led
    str r6,[r7,#sio_gpio_clr]       @ r7 = pin 25 extinction

3:
    movs r0,#100
    bl attendre
    bl majWatchDog                  @ mise à jour du compteur du watchdog
    b 1b
100:
    pop {pc}
.align 2
iAdrPin25:              .int GPIO_25_CTRL

/************************************/
/*       etat du pin gpio   */
/***********************************/
/* r0 pin   */
.thumb_func
etatPin:                          @ INFO: etatPin
    push {lr}
    ldr r3,iAdrIoQspiBase
    adds r3,GPIO_QSPI_SS_CTRL
    movs r2,5                     @ code fonction sio 
    str r2,[r3]
    ldr r3,iAdrIoport             @ adresse base IO
    movs r2,2                     @ in order 0..5: SCLK, SSn, SD0, SD1, SD2, SD3
    str r2,[r3,#sio_gpio_hi_out]  @ QSPI output value
    str r2,[r3,#sio_gpio_hi_oe]   @ QSPI output enable
    movs r2,0
    str r2,[r3,#sio_gpio_hi_oe]   @ 
    movs r0,50
    bl attendre
  
    ldr r0,[r3,#sio_gpio_hi_in]   @  lecture de l'état pin qspi du gpio

    lsrs r0,#1                    @ décalage droit de 1
    beq 1f                        @ égal à zéro ?
    movs r0,0                     @ pas d'appui sur le bouton
    b 100f
1:
    movs r0,1                     @ bouton appuyé
100: 
    pop {pc}
.align 2
iAdrIoport:       .int IOPORT
iAdrIoQspiBase:   .int IO_QSPI_BASE + 0x2000

/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:                     @ INFO: attendre
    lsls r0,13                @ approximatif 
1:
    subs r0,r0, 1
    bne 1b
    bx lr

