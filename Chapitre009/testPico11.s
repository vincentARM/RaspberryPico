/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* test multi  core */
/* fonctionne mais ne pas lancer 2 fois la commande fct  */ 
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
cmd_sequence:      .int 0,0,1,0,0,0,0          @ séquence initialisation
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
    bl sleep_ms
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
    
    bl lancementCore1

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
lancerWatchDog:               @ INFO: verifWatchDog
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
/*     lancement multicore                                        */ 
/******************************************************************/
/*                    */
.thumb_func
lancementCore1:                     @ INFO: lancementCore1
    push {lr}
    adr r0,executionCore1           @ adresse procèdure à exécuter par le core 1
    movs r1,1
    eors r0,r1                      @ adresse doit se finir par 1 voir info thumb
    bl multicore_launch_core1       @ initialisation core 1
    afficherLib retourInitOK
    movs r0,100
    bl attendre
    bl multicore_fifo_pop_blocking  @ lecture valeur envoyée par le coeur 1
    afficherLib core0_2
    push {r0}
    bl affRegHexa
    add sp, 4
    pop {pc}
.align 2

/******************************************************************/
/*     execution programme core 1                                         */ 
/******************************************************************/
/*                    */
.thumb_func
executionCore1:                     @ INFO: executionCore1
    push {lr}
    afficherLib core1_debut
    movs r0,FLAG_VALUE              @ valeur à transmettre
    bl multicore_fifo_push_blocking @ envoi
    bl multicore_fifo_pop_blocking  @ attente retour
    afficherLib core1
1:                                  @ boucle pour rester sur le coeur 1
    b 1b
    pop {pc}
.align 2
/******************************************************************/
/*     ecriture FIFO                                              */ 
/******************************************************************/
/*                    */
.thumb_func
multicore_fifo_push_blocking:         @INFO: multicore_fifo_push_blocking
    push {lr}
    ldr r1,iAdrSioBase
    movs r2,SIO_FIFO_ST_RDY_BITS      @ soit 2
1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ etat de la pile fifo
    tst r3,r2                         @ bit 1 à 1 ?
    beq 1b                            @ non boucle
    str r0,[r1,SIOBASE_FIF0_WR]       @ écriture dans la file FIFO 
    sev                               @ evenement vers l autre coeur
    pop {pc}
.align 2
/******************************************************************/
/*     récupération fifo                                         */ 
/******************************************************************/
/*                    */
.thumb_func
multicore_fifo_pop_blocking:          @ INFO: multicore_fifo_pop_blocking
    push {lr}
    movs r2,SIO_FIFO_ST_VLD_BITS
    ldr r1,iAdrSioBase
1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ registre status de la file fifo
    tst r3,r2
    bne 3f
2:
    wfe
    ldr r3,[r1,SIOBASE_FIF0_ST]       @ registre status de la file fifo
    tst r3,r2
    bne 2b
3:
    ldr r1,iAdrSioBase
    ldr r0,[r1,SIOBASE_FIF0_RD]       @ lecture fifo
    
    pop {pc}
.align 2

/******************************************************************/
/*     initialisation lancement core 1                            */ 
/******************************************************************/
/*  r0 = adresse procédure                   */
.thumb_func
multicore_launch_core1:      @ INFO: multicore_launch_core1
    push {lr}
    ldr r1,iAdrStack1
    ldr r2,iTailleStack1
    adds r3,r1,r2            @ adresse de fin de pile
    subs r3,12               @ - 12 octets
    str r0,[r3]              @ stocke l adresse de la procédure du core1
    str r1,[r3,4]            @ stocke l'adresse de la fin de pile 
    ldr r2,iAdrcore1_wrapper
    str r2,[r3,8]            @ stocke l'adresse du wrapper sur la pile
    ldr r0,iAdrCoreT         @ adresse fonction trampoline ???

    movs r1,r3               @ adresse pile
    ldr r2,iAdrPPBBase
    ldr r3,iAdrVtor
    add r2,r3                           @ calcul de l'adresse où se trouve l'adresse vtor
    ldr r2,[r2]                         @ charge l'adresse vtor
    bl multicore_launch_core1_raw       @ appel séquence d initialisation
    pop {pc}
.align 2
iAdrStack1:     .int 0x20040800
iTailleStack1:  .int TAILLESTACK
iAdrPPBBase:    .int PPB_BASE
iAdrVtor:       .int PPB_VTOR
iAdrCoreT:      .int core_trampoline
iAdrcore1_wrapper: .int core1_wrapper
/******************************************************************/
/*      code pour séquence init ? ?                               */ 
/******************************************************************/
.align 2
.thumb_func
core_trampoline:                 @ INFO: core_trampoline
    mov r8,r8
    pop {r0, r1, pc}
/******************************************************************/
/*     code wrapper core 1   ?????                                */ 
/******************************************************************/
/*  r0 = adresse procédure  r1 adresse de la pile                 */
.thumb_func
core1_wrapper:               @ INFO: core1_wrapper
    push {r4,lr}
    mov r4,r0
    mov r0,r1                @ peut être inutile car sert à verifier le débordement pile 
    //bl runtime_install_stack_guard   @ à remettre si necessaire
    //bl irq_init_priorities   @ ???  à remettre si necessaire
    blx r4
    pop {r4,pc}

/******************************************************************/
/*     envoi séquence initialisation                                         */ 
/******************************************************************/
/*  r0 = adresse procèdure                   */
.thumb_func
multicore_launch_core1_raw:        @ INFO: multicore_launch_core1_raw
    push {r4-r6,lr}
    ldr r3,iAdrcmd_sequence
    str r2,[r3,12]                 @ stocke adresse vtor
    str r1,[r3,16]                 @ stocke adresse fin de pile - 12 octets
    str r0,[r3,20]                 @ stocke adresse code trampoline !!!!!
    movs r4,0                      @ indice élement séquence

1:
    ldr r3,iAdrcmd_sequence        @ adresse de la sequence d initialisation
    lsls r5,r4,2                   @ déplacement
    ldr r6,[r3,r5]                 @ charge un élement de la sequence 
    cmp r6,0
    bne 2f
    bl multicore_fifo_drain        @ vide la file d'attente lecture fifo
    sev
2:
    mov r0,r6
    bl multicore_fifo_push_blocking @ envoi élément séquence
    bl multicore_fifo_pop_blocking  @ réponse
    cmp r0,r6
    beq 3f                          @ compare envoi et réponse
    movs r4,0
    b 4f
3:
    adds r4,1
4:
    cmp r4,5
    ble 1b
100:
    pop {r4-r6,pc}
.align 2
iAdrcmd_sequence:   .int cmd_sequence
/******************************************************************/
/*     vidage de la file d'attente lecture FIFO                   */ 
/******************************************************************/
.thumb_func
multicore_fifo_drain:                 @ INFO:  multicore_fifo_drain
    push {lr}
    ldr r1,iAdrSioBase
    movs r2,SIO_FIFO_ST_VLD_BITS      @   soit 1

1:  
    ldr r3,[r1,SIOBASE_FIF0_ST]        @ état de la pile FIFO
    tst r3,r2                          @ bits 0  à 1 ?
    beq 2f
    ldr r3,[r1,SIOBASE_FIF0_RD]        @ vide le registre de lecture
    b 1b
2:
    pop {pc}
.align 2
iAdrSioBase:     .int SIO_BASE
