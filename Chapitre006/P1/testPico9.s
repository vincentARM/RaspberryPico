/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* commandes  gestion du timer , routines chrono */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ TIMER_BASE,     0x40054000
.equ WATCHDOG_BASE,  0x40058000
.equ TIMELR,    0xC
.equ TIMEHR,    0x8
.equ WATCHDOG_CTRL,  0
.equ WATCHDOG_LOAD,  4
.equ WATCHDOG_TICK,  0x2C
.equ WATCHDOG_TICK_ENABLE_BITS,   0x00000200

.equ ROSC_BASE,       0x40060000
.equ ROSC_COUNT,      0x20
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
szMessDebutPgm:   .asciz "Debut du programme."
szMessChrono:     .ascii "Temps = "
sZoneDec:         .asciz "             "

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"        @ affichage hexa registre mémoire
szLibCmdMem:       .asciz "mem"        @ affichage zone mémoire
szLibCmdFin:       .asciz "fin"        @ sortie avec reset du pico
szLibCmdFct:       .asciz "fct"        @ pour tester une fonction particulière
szLibCmdBin:       .asciz "bin"        @ affichage binaire registre mémoire

.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
dwDebut:    .skip 8               @ zones début temps timer
dwFin:      .skip 8               @ zones fin temps timer
sBuffer:    .skip 20 

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ routine
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
    movs r0,'U'                 @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
    b 10f
6:                              @ test du timer
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 7f
    bl testTimer
    bl debutChrono              @ test chrono à vide
    bl stopChrono
                                @ test chrono
    bl debutChrono
    movs r0,250
    lsls r0,2                   @ test pour 1 seconde
    bl sleep_ms
    bl stopChrono
    
    movs r0,127                 @ valeur maxi
    bl testerCount              @ test du compteur de l'oscillateur
    movs r0,42
    bl testerCount              @ test du compteur de l'oscillateur
    
    b 10f
7:                              @ affichage registre binaire mémoire
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdBin
    bl comparerChaines
    cmp r0, 0
    bne 8f
    bl affRegBin
    b 10f
8:                              @ suite éventuelle
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
/*     test du Timer                                          */ 
/******************************************************************/
/* r0 contient l'adresse du buffer                   */
.thumb_func
testTimer:
    push {lr}
    ldr r0,iAdrWatchdog        @ lancement du compteur tick
    ldr r1,iParCycles
    str r1,[r0,#WATCHDOG_TICK]
    movs r0,200
    bl attendre
    ldr r0,iAdrWatchdog
    ldr r2,[r0,#WATCHDOG_TICK] @ verification le bit 9 doit être à 1
    push {r2}
    bl affRegHexa
    add sp, 4
    ldr r0,iAdrTimerBase       @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMELR]
    ldr r2,[r0,TIMEHR]
    ldr r3,[r0,0x28]           @ affichage du TIMERAWL  pour voir
    afficherLib ExtractTimer
    push {r1}
    bl affRegHexa
    add sp, 4
    push {r2}
    bl affRegHexa
    add sp, 4
    push {r3}
    bl affRegHexa
    add sp, 4
    pop {pc}
.align 2
iAdrWatchdog:    .int WATCHDOG_BASE
iParCycles:      .int WATCHDOG_TICK_ENABLE_BITS| 10
/******************************************************************/
/*     test du compteur interne à Rosc                             */ 
/******************************************************************/
/* r0 contient le délai maxi 127 */
.thumb_func
testerCount:               @ INFO: testerCount
    push {lr}
    afficherLib testCountOsc
    mov r4,r0
    bl debutChrono          @ lancement du chrono pour compter le temps
    ldr r1,iAdrRoscBase      @ charge délai
    //movs r0,127              @ ne pas dépasser 127 (7 bits)
    str r4,[r1,ROSC_COUNT]
1:                          @ boucle 
    ldr r0,[r1,ROSC_COUNT] @ teste si le compteur est à zéro
    cmp r0,0
    bne 1b
    bl stopChrono           @ et fin du chrono
    pop {pc}
.align 2
iAdrRoscBase:          .int ROSC_BASE

/******************************************************************/
/*     Début du chrono                                          */ 
/******************************************************************/
/*                    */
.thumb_func
debutChrono:
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMELR]
    ldr r2,[r0,TIMEHR]
    ldr r0,iAdrdwDebut
    str r1,[r0,4]             @ stockage dans zones
    str r2,[r0]
    bx lr
.align 2
/******************************************************************/
/*     Fin du chrono                                          */ 
/******************************************************************/
/*                    */
.thumb_func
stopChrono:
    push {r0-r4,lr} 
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMELR]
    ldr r2,[r0,TIMEHR]
    ldr r0,iAdrdwDebut
    ldr r4,[r0,4]             @ stockage dans zones
    ldr r3,[r0]
    subs r0,r1,r4             @ calcul de la différence
    sbcs r2,r3
    ldr r1,iAdrsZoneDec       @ conversion
    bl conversion10
    ldr r0,iAdrszMessChrono   @ et affichage
    bl __wrap_puts
    pop {r0-r4,pc} 
.align 2
iAdrdwDebut:       .int dwDebut
iAdrTimerBase:     .int TIMER_BASE
iAdrsZoneDec:      .int sZoneDec
iAdrszMessChrono:  .int szMessChrono
/******************************************************************/
/*     Conversion registre en décimal non signé                   */ 
/******************************************************************/
/* r0 contient valeur et r1 adresse zone de conversion   */
/* r0 returne la longueur du résultat */
/* taille zone  => 11 octets          */
.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}               @ save registres 
    movs r3,r1
    movs r2,#LGZONECAL
1:                                @ debut de boucle
    bl divisionpar10U             @ unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    adds r1,#48                   @ conversion chiffre ascii
    strb r1,[r3,r2]               @ stocke le chiffre dans zone reception
    cmp r0,#0                     @ stop si quotient = 0 
    beq 11f
    subs r2,#1                    @ sinon position précédente
    b 1b                          @ et boucle
                                  @ deplacement des chiffres en début de zone
11:
    movs r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    adds r2,#1
    adds r4,#1
    cmp r2,#LGZONECAL
    ble 2b
                                   @ et ajout blancs en fin de zone
    movs r0,r4                     @ longueur résultat
    movs r1,#' '                   @ space
3:
    strb r1,[r3,r4]                @ blanc dans zone reception
    adds r4,#1                     @ position suivante
    cmp r4,#LGZONECAL
    ble 3b                         @ et boucle
 
100:
    pop {r1-r4,pc}                 @ restaur registres 
/***************************************************/
/*   division par 10   non signé                    */
/***************************************************/
/* division entière spéciale voir les textes de Deligt  */
/* r0 dividende   */
/* r0 quotient    */
/* r1 reste   */
divisionpar10U:
    push {r2,r3, lr}
    lsrs r1,r0,1
    lsrs r2,r0,2
    adds r1,r2
    lsrs r2,r1,4
    adds r1,r2
    lsrs r2,r1,8
    adds r1,r2
    lsrs r2,r1,16
    adds r1,r2
    lsrs r3,r1,3     @ quotient 1
    movs r2,10
    muls r2,r3,r2
    subs r1,r0,r2    @ reste
    adds r0,r1,6
    lsrs r0,4
    add r0,r3        @ quotient 
    cmp r1,10        @ dans certains cas, il faut rectifier le calcul du reste 
    blt 1f
    subs r1,10
1:
    pop {r2,r3,pc}
