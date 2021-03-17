/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* commandes  test capteur de temperature  */
/* calcul en virgule flottante */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "../constantesPico.inc"

.equ RESETS_BASE,       0x4000c000
.equ RESETS_RESET,      0
.equ RESETS_WDSEL,      4
.equ RESETS_RESET_DONE, 8
.equ ADC_BASE,          0x4004c000
.equ ADC_CS,          0
.equ ADC_RESULT,      4
.equ ADC_FCS,         8
.equ ADC_FIFO,        0xC
.equ ADC_DIV,         0x10
.equ ADC_INTR,        0x14
.equ ADC_INTE,        0x18
.equ ADC_INTF,        0x1C
.equ ADC_INTS,        0x20

.equ PLL_USB_BASE,    0x4002c000
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
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebutPgm:   .asciz "Debut du programme."

szMessTemp:       .ascii "Température (en dizième de degrés) = "
sZoneTempDec:     .asciz "             "

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"
szLibCmdTemp:      .asciz "temp"

.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:    .skip 20 

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ routine
    bl stdio_init_all
    bl initADC                  @ initialisation 
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
    //movs r0, 200
    //bl sleep_ms
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
6:                        @ test capteur température
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdTemp
    bl comparerChaines
    cmp r0, 0
    bne 7f
    bl testTemp
    
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
iAdrszLibCmdTemp:       .int szLibCmdTemp
iAdrsBuffer:            .int sBuffer
/******************************************************************/
/*     Température                                           */ 
/******************************************************************/
.thumb_func
testTemp:
    push {lr}

    afficherLib debutADC 
    ldr r2,iAdrAdcBase      @ lancement mesure 
    ldr r1,[r2,ADC_CS]
    ldr r3,iParam
    orrs r3,r3,r1           @ à revoir utilisation autre adresse
    str r3,[r2,ADC_CS]
    movs r0,100
    bl attendre
    movs r1,1
    lsls r1,8
1:
    ldr r0,[r2,ADC_CS]
    tst r0,r1
    beq 1b
    
    str r3,[r2,ADC_CS]       @ lancement mesure
    afficherLib resultat
    ldr r4,[r2,ADC_RESULT]
    
    push {r4}                @ affichage mesure brute
    bl affRegHexa
    add sp, 4

    movs r0,'S'
    movs r1,'F'
    bl appelDatasRom         @ recherche début float fonctions
    mov r5,r0
    ldr r2,[r5,0x34]         @ conversion en float
    movs r0,r4
    blx r2
    
    ldr r1,iCst4
    ldr r2,[r5,8]            @ operateur multiplication
    blx r2
    
    ldr r2,[r5,4]            @ operateur soustraction
    ldr r1,iCst1
    blx r2

    ldr r2,[r5,0xC]          @ opérateur division
    ldr r1,iCst3
    blx r2

    ldr r2,[r5,4]            @ operateur soustraction
    movs r1,r0
    ldr r0,iCst2
    blx r2

    ldr r1,iCst5             @ 10      pour avoir un résultat en dizième de degré
    ldr r2,[r5,8]            @ operateur multiplication
    blx r2
    
    ldr r2,[r5,0x24]         @ conversion vers entier
    blx r2
    afficherLib résultatFinal
    push {r0}
    bl affRegHexa
    add sp, 4
                             @ affichage final
    ldr r1,iAdrsZoneTempDec
    bl conversion10
    ldr r0,iAdrszMessTemp
    bl __wrap_puts
    
    pop {pc}
.align 2
iParam:           .int 0x100007
iCst1:            .float 0.706
iCst2:            .float 27.0
iCst3:            .float 0.001721
iCst4:            .float 0.000805664
iCst5:            .float 10.0
iAdrBasePllUsb:   .int PLL_USB_BASE
iAdrszMessTemp:   .int szMessTemp
iAdrsZoneTempDec: .int sZoneTempDec
/******************************************************************/
/*     initialisation ADC                                         */ 
/******************************************************************/
.thumb_func
initADC:
    ldr r0,iAdrResetBaseMskSet      @ reset 
    movs r1,1
    str r1,[r0]                     @ reset des zones
    ldr r0,iAdrResetBaseMskClear
    str r1,[r0]
    ldr r2,iAdrResetBase
    movs r0,r1
1:                                  @ boucle d'attente du reset
    movs r0,r1
    ldr r3,[r2,RESETS_RESET_DONE]
    bics r0,r3
    bne 1b
    ldr r2,iAdrAdcBase
    str r1,[r2]
    lsls r1,8
2:                                 @ boucle attente init 
    ldr r3,[r2]
    tst r3,r1
    beq 2b
    bx lr
.align 2
iAdrResetBase:            .int RESETS_BASE
iAdrResetBaseMskSet:      .int RESETS_BASE + 0x2000
iAdrResetBaseMskClear:    .int RESETS_BASE + 0x3000
iAdrAdcBase:              .int ADC_BASE

/************************************************/
/* appel des fonctions de la Rom  partie Datas  */
/************************************************/
/* r0 Code 1  */
/* r1 code 2  */
.thumb_func
appelDatasRom:
    push {r2-r3,lr}         @ save  registers 
    lsls r1,#8              @ conversion des codes
    orrs r1,r0              @ paramètre 2 recherche adresse
    ldr r0,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r0]
    ldr r0,ptDatasTable
    movs r3,#0              @ TODO: voir comportement de ldrh 
    ldrh r3,[r0]
    movs r0,r3              @ parametre 1 recherche adresse
    blx r2                  @ recherche adresse 

    pop {r2-r3,pc}          @ restaur registers
.align 2
ptRom_table_lookup:     .int 0x18
ptDatasTable:           .int 0x16
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
/* division entière spéciale voir   */
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
    