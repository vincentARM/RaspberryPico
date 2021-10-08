/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* test mesure cycles */
/*  */ 
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "../constantesPico.inc"
.equ TAILLESTACK,  0x800
.equ FLAG_VALUE,   123
.equ SIO_FIFO_ST_RDY_BITS,   0x00000002
.equ SIO_FIFO_ST_VLD_BITS,   0x00000001

.equ PPB_BASE,   0xe0000000
.equ PPB_VTOR,   0xed08

.equ GPIO_16_CTRL,    IO_BANK0_BASE + 8 * 16 + 4
.equ GPIO_16_STATUS,  IO_BANK0_BASE + 8 * 16
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
    b smacroafficheMess\@   @ pour sauter le stockage de la chaine.
.align 2
libaff1\@:     .asciz "\str"
              // .asciz " "
.align 2
smacroafficheMess\@:     
.endm   @ fin de la macro
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDemStd:       .asciz "Demarrage normal."
szMessDemWDog:      .asciz "Reboot par watchdog !!"
szMessTemp:       .ascii "Température (en dizième de degrés) = "
sZoneTempDec:     .asciz "             "

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"
szLibCmdTemp:      .asciz "temp"

szMessDebut:       .asciz "test insertion @  avant la fin"
szMessInsert:      .asciz "123456789"

szMessAlarme:      .asciz "WOU WOU Alarme 1 !!"
szNomALarme1:      .asciz "AL1"
.align 4
cmd_sequence:      .int 0,0,1,0,0,0,0
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iZoneAlarme1:  .skip 4
sBuffer:    .skip 20 
stack1:      .skip TAILLESTACK
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
    movs r0, 200                @ sinon attente et boucle
    bl attendre
    b 1b
2:  
    mov r0,sp                   @ pour affichage adresse pile début programme
    push {r0}
    bl affRegHexa               @ affichage registre 
    add sp, 4                   @ alignement pile
   // bl lancerWatchDog
3:                              @ boucle de lecture traitement des commandes
    ldr r0,iAdrszMessCmd
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAff
    bl comparerChaines
    cmp r0, 0
    bne 4f
    mov r0,sp
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
    bne 6f
    movs r0,200
    bl attendre
    movs r0,'U'          @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
    b 10f
6:                        @ test température
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdTemp
    bl comparerChaines
    cmp r0, 0
    bne 7f
    //bl testTemp
    b 10f
7:                        @ affichage registre binaire mémoire
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdBin
    bl comparerChaines
    cmp r0, 0
    bne 8f
    bl affRegBin
    b 10f
8:    @ suite éventuelle
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 9f
    
    bl testerDoigts

    b 10f
9:    @ suite éventuelle
10:
    b 3b                        @ boucle commande
 
100:                            @ boucle pour fin de programme standard  
    b 100b
/************************************/
.align 2
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdAff:        .int szLibCmdAff
iAdrszLibCmdMem:        .int szLibCmdMem
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszLibCmdBin:        .int szLibCmdBin
iAdrszLibCmdTemp:       .int szLibCmdTemp
iAdrsBuffer:            .int sBuffer
iAdrszMessInsert:       .int szMessInsert
iAdrszMessDebut:        .int szMessDebut


/******************************************************************/
/*     lancement du watchdog                                      */ 
/******************************************************************/
/*                    */
.thumb_func
lancerWatchDog:               @ INFO: lancerWatchDog
    push {r4,lr}
    ldr r4,iAdrWatchDogBase
    ldr r0,[r4,WATCHDOG_REASON]
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
    str r1,[r4,#WATCHDOG_TICK]
    ldr r1,iparWDem
    str r1,[r4,#WATCHDOG_CTRL]
    
    ldr r2,iAdrPsmBase
    ldr r1,iParPsm
    str r1,[r2,PSM_WDSEL]
    
    pop {r4,pc}
.align 2
iAdrWatchDogBase:       .int WATCHDOG_BASE
iAdrWatchDogBaseXor:    .int WATCHDOG_BASE +0x1000
iAdrWatchDogBaseSet:    .int WATCHDOG_BASE +0x2000
iAdrWatchDogBaseClear:  .int WATCHDOG_BASE +0x3000
iAdrszMessDemStd:       .int szMessDemStd
iAdrszMessDemWDog:      .int szMessDemWDog
iParCycles:             .int WATCHDOG_TICK_ENABLE_BITS | 1
iparWDem:               .int 0x40000064       @ enable + 100ms
iAdrPsmBase:            .int PSM_BASE
iParPsm:                .int PSM_WDSEL_BITS & ~(PSM_WDSEL_ROSC_BITS |PSM_WDSEL_XOSC_BITS)
/******************************************************************/
/*     touche d'un pin avec les doigts                                            */ 
/******************************************************************/
/* r0   */

.thumb_func
testerDoigts:                       @ INFO: testerDoigts
    push {r1-r4,lr}
    ldr  r1,iAdrGPIO16          @ init fonction sio
    movs r0,GPIO_FUNC_SIO
    str  r0, [r1]
    
    movs  r2,1
    lsls  r2,16                 @ GPIO pin 16
    ldr r1,iAdrSioBase
    str  r2, [r1, GPIO_OE_SET]  @ output
    str r2,[r1,GPIO_OUT_SET]   @ niveau haut
    //str r2,[r1,GPIO_OE_CLR]  @ niveau bas
    movs r0,1
    bl attendre
    
    ldr r1,iAdrPads
    movs r2,1
    str r2,[r1]
    ldr r1,iAdrPads16
    ldr r2,[r1]
    movs r0,0b1000100         @ pull_down et input
   // bics r2,r0               @ raz
    orrs r2,r0                 @ set
    str r2,[r1]

    movs r0,50
    bl attendre

    ldr r1,iAdrSioBase
    ldr  r0, [r1, GPIO_IN]     @ input
    
    //afficherLib lecture1
    //push {r0}
    //bl affRegHexa
    //add sp,4
    
    movs r0,255
    lsls r0,4
    bl attendre
    
    ldr  r1,iAdrSioBase
    ldr  r2, [r1, GPIO_IN]  @ input
    afficherLib lecture2
    push {r2}
    bl affRegHexa
    add sp,4

    
    
100:
    pop {r1-r4,pc}
.align 2
iAdrGPIO16:            .int GPIO_16_CTRL
iAdrGPIO16ST:          .int GPIO_16_STATUS
iAdrGPIO16INTR2:        .int SIO_BASE + 0x0f8 
iAdrPads:             .int PADS_BANK0_BASE  @ TENSION
iAdrPads16:             .int PADS_BANK0_BASE + 0x44  @ GPIO16
iAdrSioBase:    .int SIO_BASE
