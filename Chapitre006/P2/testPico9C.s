/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* mise en place du watchdog */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "../constantesPico.inc"

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
.endm                          @ fin de la macro
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebutPgm:     .asciz "Début du programme"
szMessDemStd:       .asciz "Demarrage normal."
szMessDemWDog:      .asciz "Reboot par watchdog !!"

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"

.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:       .skip 20 
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
    bl lancerWatchDog
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
    movs r0,'U'                 @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
    b 10f
6:                        @ affichage registre binaire mémoire
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdBin
    bl comparerChaines
    cmp r0, 0
    bne 8f
    bl affRegBin
    b 10f
8:                       @ test de fonction ici lancement du core1
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 9f
    
    movs r0,250
    lsls r0,5
    bl attendre

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
/*     lancement du watchdog                                      */ 
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
    ldr r1,iParCycles          @ lancement du compteur
    ldr r2,iAdrWatchDogBase    @ car r2 perdu lors du __wrap_puts
    str r1,[r2,#WATCHDOG_TICK]
    ldr r1,iparWDem
    str r1,[r2,#WATCHDOG_CTRL]
    
    ldr r2,iAdrPsmBase
    ldr r1,iParPsm             @ pour reset de tout sauf horloges
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
