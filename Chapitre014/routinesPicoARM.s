/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* routines assembleur PICO */
/* commentaire */ 
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessAffReg:      .ascii "Valeur du registre : "
sZoneRes:          .ascii "         "
                   .asciz "\r\n"
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global affRegHexa,conversion16,comparerChaines,initHorloges
.global attendre,init_clk_sys,init_clk_usb,pll_init,pll_usb_init
.global appelFctRom
/******************************************************************/
/*     affichage du registre passé par push                       */ 
/******************************************************************/
/* Attention après l'appel aligner la pile */
.thumb_func
affRegHexa:                 @ INFO: affRegHexa
    push {r0-r4,lr}         @ save des registres
    mov r0,sp
    ldr r0,[r0, 24]
    ldr r1,iAdrsZoneRes
    bl conversion16
    ldr r0,iAdrszMessAffReg
    bl envoyerMessage
    pop {r0-r4,pc}          @ restaur des registres
.align 2
iAdrsZoneRes:     .int sZoneRes
iAdrszMessAffReg: .int szMessAffReg
/******************************************************************/
/*     conversion hexa                       */ 
/******************************************************************/
/* r0 contient la valeur */
/* r1 contient la zone de conversion  */
.thumb_func
conversion16:               @ INFO: conversion16
    push {r1-r4,lr}         @ save des registres

    movs r2, 28              @ start bit position
    movs r4, 0xF             @ mask
    lsls r4, 28
    movs r3,r0               @ save entry value
1:                          @ start loop
    movs r0,r3
    ands r0,r0,r4            @ value register and mask
    lsrs r0,r2               @ move right 
    cmp r0, 10              @ compare value
    bge 2f
    adds r0, 48              @ <10  ->digit 
    b 3f
2:    
    adds r0, 55              @ >10  ->letter A-F
3:
    strb r0,[r1]            @ store digit on area and + 1 in area address
    adds r1, 1
    lsrs r4, 4               @ shift mask 4 positions
    subs r2,r2, 4            @  counter bits - 4 <= zero  ?
    bge 1b                  @  no -> loop
    movs r0, 8
    pop {r1-r4,pc}          @ restaur des registres

/************************************/       
/* comparaison de chaines           */
/************************************/      
/* r0 et r1 contiennent les adresses des chaines */
/* retour 0 dans r0 si egalite */
/* retour -1 si chaine r0 < chaine r1 */
/* retour 1  si chaine r0> chaine r1 */
.thumb_func
comparerChaines:          @ INFO: comparerChaines
    push {r2-r4,lr}          @ save des registres
    movs r2, 0             @ indice
1:    
    ldrb r3,[r0,r2]       @ octet chaine 1
    ldrb r4,[r1,r2]       @ octet chaine 2
    cmp r3,r4
    blt 2f
    bgt 3f
    cmp r3, 0             @ 0 final
    beq 4f                @ c est la fin
    adds r2,r2, 1          @ sinon plus 1 dans indice
    b 1b                  @ et boucle
2:
    movs r0, 0            @ plus petite
    subs r0, 1
    b 100f
3:
    movs r0, 1             @ plus grande
    b 100f
4:
    movs r0, 0             @ égale
100:
    pop {r2-r4,pc}


/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
/* r1 non sauvegardé */
.thumb_func
attendre:                     @ INFO: attendre
    lsls r1,r0,15             @ approximatif 
    lsls r0,r0,13
    adds r0,r1
1:
    subs r0,r0, 1
    bne 1b
    bx lr
/******************************************************************/
/*     initialisation   horloges                                          */ 
/******************************************************************/
.thumb_func
initHorloges:                             @ INFO: initHorloge
    push {r1-r6,lr}
    movs r1,0
    ldr r4,iAdrCLOCKS_BASE
    str  r1, [r4, #CLK_SYS_RESUS_CTRL]
    
    ldr r6,iAdrOscBase
    ldr r5,iParamDel
    str  r5, [r6, #XOSC_STARTUP]     @ A value of 47 for XOSC_DELAY would suffice,
                                     @ but writing 0x301 to is saves one opcode.
    ldr r3,iParamOsc
    str  r3, [r6, #XOSC_CTRL]        @ Activate XOSC. r3 = XOSC_ENABLE_12MHZ

1:  ldr  r0, [r6, #XOSC_STATUS]      @ Wait for stable flag (in MSB)
    asrs r0, r0, 31
    bpl  1b
    
    movs r1,#2                      @ modif 19/05
    str  r1, [r4, #CLK_REF_CTRL]    @ Select XOSC as source for clk_ref,
    
    /* init des PLL */
    bl pll_init
    bl pll_usb_init
    /* init des horloges */
    bl init_clk_sys
    bl init_clk_usb
    
    pop {r1-r6,pc}
.align 2
iAdrCLOCKS_BASE:        .int CLOCKS_BASE
iParamClk:              .int 0x860
iAdrOscBase:            .int XOSC_BASE
iParamOsc:              .int XOSC_ENABLE_12MHZ
iParamDel:              .int 0x301

iAdrSioBase:            .int SIO_BASE
iAdrClocks:             .int CLOCKS_BASE
iAdrClocksSet:          .int CLOCKS_BASE + 0x2000
/***********************************/
/*       Init Pll USB   */
/***********************************/
/* cf datasheet     2.18 PLL  */
/* PLL USB: 12 / 1 = 12MHz * 40 = 480 MHz / 5 / 2 = 48MHz  */
.thumb_func
pll_usb_init:                @ INFO: pll_usb_init
    push    {r4, lr}
    ldr r4,iAdrPllUsb
    movs    r3, #1           @ - 1
    negs    r3, r3
    str    r3, [r4, #4]      @ stocke - 1 dans registre PWR (donc 0xFFFFFFFF )
    movs    r3, #0
    str    r3, [r4, #8]      @ stocke 0 dans registre FBDIV_INT
    movs    r1,1
    str    r1, [r4, #0]      @ stocke 1 dans registre CS

    movs r0,40               @ pour pll_usb
    movs    r1,0xc0
    adds    r3, r4, #4       @ calcule registre pwr
    lsls    r1, r1, #6
    orrs    r1, r3           @ calcule base+pwr + 0x3000
    movs    r3, #33          @ 0x21
    str    r0, [r4, #8]      @ stocke le résultat dans FBDIV_INT
    str    r3, [r1, #0]      @ stocke 0x21 base + pwr + 0x3000

1:
    ldr    r2, [r4, #0]      @ charge registre CS 
    cmp    r2, #0
    bge  1b                  @  boucle attente 
    
    movs    r3, #8
    movs r0,2                @ postdiv2
    lsls    r0, r0, #12
    movs r2,5                @ postdiv1  pour pll usb
    lsls    r2, r2, #16
    orrs    r2, r0
    str    r2, [r4, #12]     @ PRIM register
    str    r3, [r1, #0]      @ stocke 8 dans base + pwr + 0x3000
    pop    {r4, pc}
.align 2
iAdrPllUsb:              .int 0x4002c000
/***********************************/
/*       Init Pll SYS   */
/***********************************/
/* cf datasheet     2.18 PLL  */
/*  PLL SYS: 12 / 1 = 12MHz * 125 = 1500MHZ / 6 / 2 = 125MHz  */
.thumb_func
pll_init:                   @ INFO: pll_init
    push    {r4, lr}
    ldr r4,iAdrPllSys
    movs    r3, #1          @ - 1
    negs    r3, r3
    str    r3, [r4, #4]     @ stocke - 1 dans registre PWR
    movs    r3, #0
    str    r3, [r4, #8]     @ stocke 0 dans registre FBDIV_INT
    movs    r1,1
    str    r1, [r4, #0]     @ stocke ref (1) dans registre CS


    movs r0,125             @ pour pll_sys
    movs    r1, #192        @ 0xc0
    adds    r3, r4, #4      @ calcule registre pwr
    lsls    r1, r1, #6
    orrs    r1, r3           @ calcule base+pwr + 0x3000
    movs    r3, #33          @ 0x21
    str    r0, [r4, #8]      @ stocke le résultat dans FBDIV_INT
    str    r3, [r1, #0]      @ stocke 0x21 base + pwr + 0x3000

1:
    ldr    r2, [r4, #0]      @ charge registre CS 
    cmp    r2, #0
    bge  1b                  @ attente lock 
    
    movs    r3, #8
    movs r0,2                @ postdiv2
    lsls    r0, r0, #12
    movs r2,6                @ postdiv1  pour pll sys
    lsls    r2, r2, #16
    orrs    r2, r0
    str    r2, [r4, #12]     @ PRIM register
    str    r3, [r1, #0]      @ stocke 8 dans base + pwr + 0x3000
    pop    {r4, pc}
.align 2
iAdrPllSys:              .int 0x40028000 
/***********************************/
/*       Init hologe usb    */
/***********************************/
init_clk_usb:                 @ INFO: init_clk_usb
    push {r4,lr}
    movs   r2,0x80
    lsls   r2, r2,1           @ soit 1 dans le bit 8
    ldr    r3,iAdrClkUsbDiv   @ adresse diviseur horloge usb
    ldr    r1, [r3]    
    cmp    r1,0xFF
    bhi    1f                 @
    str    r2, [r3]           @ init du bit 8 du diviseur
1:
    movs   r2,0x80
    ldr    r3,iAdrClkUsbClr   @ adresse controle horloge usb + 0x3000
    lsls   r2, r2, #4         @ donc 1 dans le bit 11
    str    r2, [r3]           @ donc adresse du CLK_USB_CTRL + 0x3000

    movs    r2,0xe0           @ bits 5,6,7
    ldr    r1,iAdrClkUsb      @ adresse controle horloge usb
    ldr    r3, [r1]           @ charge le registre controle horloge USB
    ands    r2, r3            @ extrait les bits 5,6,7
    ldr    r3,iAdrClkUsbXor   @ adresse horloge usb + 0x1000
    str     r2, [r3]          @ stocke result et xor dans clock usb + 0x1000
    movs    r2,0x80
    lsls    r2, r2, #4        @ donc 1 dans bit 11
    ldr    r3,iAdrClkUsbSet   @ adresse horloge usb + 0x2000 donc start horloge
    str    r2, [r3]
    movs    r2,0x80
    lsls    r2, r2, #1        @ donc 1 dans le bit 8
    ldr   r1,iAdrClkUsbDiv
    str    r2, [r1]           @ init du bit 8 du diviseur
    pop {r4,pc}
.align 2
iAdrClkUsb:          .int 0x40008054     @ CLOCK_BASE + CLK_USB_CTRL
iAdrClkUsbXor:       .int 0x40009054     @ + 0x1000
iAdrClkUsbSet:       .int 0x4000a054     @ + 0x2000
iAdrClkUsbClr:       .int 0x4000b054     @ + 0x3000
iAdrClkUsbDiv :      .int 0x40008058     @ CLOCK_BASE + CLK_USB_DIV
/***********************************/
/*       Init hologe systeme    */
/***********************************/
init_clk_sys:                     @ INFO: init_clk_sys
    push {r4,lr}
    movs   r2,0x80
    lsls   r2, r2, #1             @ valeur 256 cad bit 8 à 1
    ldr    r3, iAdrClkSysDiv      @ adresse diviseur horloge système
    ldr    r1, [r3]
    cmp    r1,0xff
    bhi   1f                      @ 
    str    r2, [r3]               @ met 1 dans le bit 8 du diviseur
1:
    movs    r1, #1
    ldr    r2,iAdrClkSysClr       @ adresse horloge système bitmask clear
    ldr    r3,iAdrClkSysSel       @ adresse controle horloge système
    str    r1, [r2]               @ clear le bit 0
2:
    ldr    r2, [r3]
    tst    r2,r1                  @ teste le bit 0
    beq  2b                       @ boucle attente de prise en compte du clear
    movs    r0, 0xe0              @ bits 5,6,7
    ldr    r3,iAdrClkSys          @ adresse controle horloge système
    ldr    r2, [r3]               @ charge le registre controle 
    ands    r0, r2                @ efface tous les bits sauf 5,6,7
    ldr    r2,iAdrClkSysXor
    str    r0, [r2]               @ stocke nouvelle valeur avec xor
    ldr    r0, [r3]               @ charge le nouveau  registre controle
    eors    r0, r1                @ 
    movs    r1, #3
    ands    r1, r0
    str    r1, [r2]
    ldr    r1,iAdrClkSysSel       @ adresse CLK_SYS_SELECTED
    movs   r3,#2
3:
    ldr    r2, [r1]
    tst    r2,r3                  @ test bit 1 
    beq   3b                      @ boucle attente
    ldr     r3,iAdrClkSysSet
    movs    r2, 0x80
    lsls    r2, r2, #4           @ 1 dans le bit 11
    str    r2, [r3]              @ 
    movs    r2, 0x80
    ldr    r1, iAdrClkSysDiv     @ adresse registre diviseur 
    lsls    r2, r2, #1           @ 1 dans bit 8  
    str    r2, [r1]              @ 
   pop {r4,pc}
.align 2
iAdrClkSys:              .int  0x4000803c   @ CLK_SYS_CTRL
iAdrClkSysXor:           .int  0x4000903c   @ CLK_SYS_CTRL + 0x1000
iAdrClkSysSet:           .int  0x4000a03c   @ CLK_SYS_CTRL + 0x2000
iAdrClkSysClr:           .int  0x4000b03c   @ CLK_SYS_CTRL + 0x3000
iAdrClkSysDiv:           .int  0x40008040   @ CLK_SYS_DIV
iAdrClkSysSel:           .int  0x40008044   @ CLK_SYS_SELECTED
/************************************/
/*       appel des fonctions de la Rom            */
/***********************************/
/* r0 Code 1  */
/* r1 code 2  */
/* r2 parametre fonction 1 */
/* r3 parametre fonction 2 */
/* r4 parametre fonction 3 */
/* TODO: voir si plus de 3 paramètres */
.thumb_func
appelFctRom:                  @ INFO: appelFctRom
    push {r2-r5,lr}            @ save  registers 
    lsls r1,#8          // conversion des codes
    orrs r0,r1
    ldr r1,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r1]
    ldr r1,ptFunctionTable
    movs r3,#0
    ldrh r3,[r1]
    movs r1,r0
    movs r0,r3        // init des valeurs
    blx r2            // recherche fonction à appeler
    movs r5,r0
    ldr r0,[sp]       // Comme r2 et r3 peuvent être écrasés par l'appel précedent
    ldr r1,[sp,4]       // récupération des paramétres 1 et  2 pour la fonction
    movs r2,r4        // parametre 3 fonction
    blx r5            // et appel de la fonction trouvée 

    pop {r2-r5,pc}             @ restaur registers
.align 2
ptFunctionTable:        .int 0x14
ptRom_table_lookup:     .int 0x18

