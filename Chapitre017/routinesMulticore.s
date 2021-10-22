/* Programme assembleur ARM Raspberry pico */
/* routines assembleur PICO */
/* gestion multicore */ 
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ TAILLESTACK,  0x800                     @ taille à revoir si necessaire

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
.align 4
cmd_sequence:      .int 0,0,1,0,0,0,0          @ séquence initialisation
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global ecrireMessage,multicore_fifo_push_blocking,multicore_fifo_pop_blocking
.global initCore1,multicore_launch_core1
/******************************************************************/
/*     initialisation core 1                                             */ 
/******************************************************************/
/*    */
.thumb_func
initCore1:                          @ INFO: initCore1
    push {r1-r4,lr}
    adr r0,executionCore1           @ adresse procèdure à exécuter par le core 1
    movs r1,1
    orrs r0,r1                      @ adresse doit se finir par 1 voir info thumb
    bl multicore_launch_core1       @ initialisation core 1
    movs r0,5
    bl attendre
100:
    pop {r1-r4,pc}
.align 2

/******************************************************************/
/*     execution programme core 1                                         */ 
/******************************************************************/
/*             */
.thumb_func
executionCore1:                     @ INFO: executionCore1
    push {lr}
1:
    bl multicore_fifo_pop_blocking  @ attend et récupère l'adresse du texte
    bl envoyerMessage               @ et envoie le texte sur le port USB
    b 1b                            @ puis boucle 
    pop {pc}
.align 2
/******************************************************************/
/*     ecriture FIFO                                              */ 
/******************************************************************/
/*  r0  contient la valeur à écrire (ici adresse du texte)           */
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
/*     récupération FIFO                                         */ 
/******************************************************************/
/*  r0  retoune la valeur lue                 */
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
    beq 2b
3:
    ldr r1,iAdrSioBase
    ldr r0,[r1,SIOBASE_FIF0_RD]       @ lecture fifo
    
    pop {pc}
.align 2

/******************************************************************/
/*     initialisation lancement core 1                            */ 
/******************************************************************/
/*  r0 = adresse procédure devant être executée par le core 1     */
.thumb_func
multicore_launch_core1:           @ INFO: multicore_launch_core1
    push {lr}
    ldr r1,iAdrStack1
    ldr r2,iTailleStack1
    adds r3,r1,r2                  @ adresse de fin de pile
    subs r3,12                     @ - 12 octets
    str r0,[r3]                    @ stocke l adresse de la procédure du core1
    str r1,[r3,4]                  @ stocke l'adresse de la fin de pile 
    ldr r2,iAdrcore1_wrapper
    str r2,[r3,8]                  @ stocke l'adresse du wrapper sur la pile
    ldr r0,iAdrCoreT               @ adresse fonction trampoline ???

    movs r1,r3                     @ adresse pile
    ldr r2,iAdrPPBBase
    ldr r3,iAdrVtor1
    add r2,r3                      @ calcul de l'adresse où se trouve l'adresse vtor
    ldr r2,[r2]                    @ charge l'adresse vtor
    bl multicore_launch_core1_raw  @ appel séquence d initialisation
    pop {pc}
.align 2
iAdrStack1:     .int 0x20040800
iTailleStack1:  .int TAILLESTACK
iAdrPPBBase:    .int PPB_BASE
iAdrVtor1:      .int PPB_VTOR
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
    push {lr}
    mov r2,r0                @ save adresse
    mov r0,r1                @ adresse de la pile ??
    blx r2                   @ appel de la routine
    pop {pc}

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
    movs r4,0                       @ si écart recommence l'envoi
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
/******************************************************************/
/*     Envoi des messages au core 1                   */ 
/******************************************************************/
.global ecrireMessage
.thumb_func
ecrireMessage:                 @ INFO:  ecrireMessage
    push {lr}
    bl multicore_fifo_push_blocking @ envoi 
    movs r0,3                  @ TODO: à améliorer pour réduire ce temps
    bl attendre
    pop {pc}
    