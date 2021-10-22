/* Programme assembleur ARM Raspberry pico */
/* routines assembleur PICO */
/* affichage port USB par le core 1 */ 
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
szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:"
szMessAffBin:      .ascii "Affichage binaire : \r\n"
szZoneConvBin:     .asciz "                                      \r\n"
szMessSystick:     .ascii "Nombre de cycles = "
sZoneDecSys:       .asciz "             \r\n"
szMessChrono:     .ascii "Temps en µs = "
sZoneDec:         .asciz "             \r\n"
                                        @ donnees pour vidage mémoire
szAffMem:      .ascii "Affichage mémoire "
sAdr1:         .ascii " adresse : "
sAdresseMem :  .ascii "          "
               .asciz " \r\n"
sDebmem:       .fill 9, 1, ' '
s1mem:         .ascii " "
sZone1:        .fill 48, 1, ' '
s2mem:         .ascii " "
sZone2:        .fill 16, 1, ' '
s3mem:         .asciz "\r\n"
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iValDepSys:     .skip 4
dwDebut:        .skip 8               @ zones début temps timer
dwFin:          .skip 8               @ zones fin temps timer
sBuffer:        .skip 80

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global affRegHexa,conversion16,comparerChaines,initHorloges
.global attendre,init_clk_sys,init_clk_usb,pll_init,pll_usb_init
.global appelFctRom,appelDatasRom,affRegBin,conversion10,conversion2,convertirChHexa
.global ledEclats,debutSystick,stopSystick,debutChrono,stopChrono,initLed25
.global afficherMemoire
/******************************************************************/
/*     affichage registre systeme  en binaire                               */ 
/******************************************************************/
/*  */
.thumb_func
affRegBin:
    push {lr}
    ldr r0,iAdrszMessSaisieReg
    bl ecrireMessage
    ldr r0,iAdrsBuffer
    bl recevoirMessage
    ldr r0,iAdrsBuffer
    bl convertirChHexa
    bcs 100f
    ldr r0,[r0]
    ldr r1,iAdrszZoneConvBin
    bl conversion2
    movs r2,' '
    strb r2,[r1,r0]
    ldr r0,iAdrszMessAffBin
    bl ecrireMessage
100:
    pop {pc}
.align 2
iAdrszMessSaisieReg:      .int szMessSaisieReg
iAdrszZoneConvBin:        .int szZoneConvBin
iAdrsBuffer:              .int sBuffer
iAdrszMessAffBin:         .int szMessAffBin
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
    bl ecrireMessage
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

//iAdrSioBase:            .int SIO_BASE
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
/************************************************/
/* appel des fonctions de la Rom  partie Datas  */
/************************************************/
/* r0 Code 1  */
/* r1 code 2  */
/* retourne dans r0 l'adresse des fonctions de la rom */
.thumb_func
appelDatasRom:
    push {r2-r3,lr}         @ save  registers 
    lsls r1,#8              @ conversion des codes
    orrs r1,r0              @ paramètre 2 recherche adresse
    ldr r0,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r0]
    ldr r0,ptDatasTable
    movs r3,#0              @ 
    ldrh r3,[r0]
    movs r0,r3              @ parametre 1 recherche adresse
    blx r2                  @ recherche adresse 

    pop {r2-r3,pc}          @ restaur registers
.align 2
ptRom_table_lookup:     .int 0x18
ptDatasTable:           .int 0x16
/***************************************************/
/*     conversion chaine hexa en  valeur           */
/***************************************************/
// r0 contains string address
// r0 return value
// carry on if error
.thumb_func
convertirChHexa:               @ TODO: convertirChHexa
    push {r4,lr}            @ save  registers 
    movs r2, 0                  @ indice
    movs r3, 0                  @ valeur
    movs r1, 0                  @ nombre de chiffres
1:
    ldrb r4,[r0,r2]
    cmp r4, 0                  @ string end
    beq 10f
    subs r4,r4, 0x30           @ conversion digits
    blt 5f
    cmp r4, 10
    blt 3f                     @ digits 0 à 9 OK
    cmp r4, 17                 @ < A ?
    blt 5f
    cmp r4, 22
    bge 2f
    subs r4,r4, 7             @ letters A-F
    b 3f
2:
    cmp r4, 49                 @ < a ?
    blt 5f
    cmp r4, 54                 @ > f ?
    bgt 5f
    subs r4,r4, 39              @ letters  a-f
3:                             @ r4 contains value on right 4 bits
    adds r1, 1
    cmp r1, 8
    bgt 9f                   @ plus de 8 chiffres -> erreur
    lsls r3, 4
    eors r3,r4
5:                             @ loop to next byte 
    adds r2,r2, 1
    b 1b
9:
    adr r0,szMessErreurConv
    bl ecrireMessage
    movs r0, 200
    bl attendre
    movs r0,0
    cmp r0,r0
    b 100f
10:
    movs r0,r3
    cmn r2,r2               @ car cmn est faux pour des nombres négatifs
100: 
    pop {r4,pc}             @ restaur registers
.align 2
szMessErreurConv:    .asciz "Trop de chiffres hexa !!"
.align 2
    /************************************/
/*       boucle attente            */
/***********************************/
/* r0 contient la valeur   */
/* r1 contient l'adresse de la zone de conversion */
.thumb_func
conversion2:                @ INFO: conversion2
    push {r4,lr}            @ save  registers 
    movs r2,0
    movs r4,0
1:
    lsls r0,1
    bcs 2f
    movs r3,'0'
    b 3f
2:
    movs r3,'1'
3:
    strb r3,[r1,r4]
    adds r4,1
    cmp r2,7
    beq 4f
    cmp r2,15
    beq 4f
    cmp r2,23
    beq 4f
    b 5f
4:
    movs r3,' '
    strb r3,[r1,r4]
    adds r4,1
5:
    adds r2,1
    cmp r2,32
    blt 1b
    movs r3,0
    strb r3,[r1,r4]
    mov r0,r4               @ retourne longueur
    pop {r4,pc}             @ restaur registers
/******************************************************************/
/*     Conversion base 10               */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion10:                @ INFO: conversion10
    push {r1-r4,lr}          @ save registers 
    movs r3,r1
    movs r2,#LGZONECAL
1:                           @ start loop
    bl divisionpar10U        @ unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    adds r1,#48              @ digit
    strb r1,[r3,r2]          @ store digit on area
    cmp r0,#0                @ stop if quotient = 0 
    beq 11f
    subs r2,#1               @ else previous position
    b 1b                     @ and loop
                             @ and move digit from left of area
11:
    movs r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    adds r2,#1
    adds r4,#1
    cmp r2,#LGZONECAL
    ble 2b
                             @ and move spaces in end on area
    movs r0,r4               @ result length 
    movs r1,#' '             @ space
3:
    strb r1,[r3,r4]          @ store space in area
    adds r4,#1               @ next position
    cmp r4,#LGZONECAL
    ble 3b                   @ loop if r4 <= area size
 
100:
    pop {r1-r4,pc}                                    @ restaur registres 
    bx lr     
/***************************************************/
/*   division par 10   non signé                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient    */
/* r1 reste   */
divisionpar10U:                @ INFO: divisionpar10U
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
    lsrs r3,r1,3  @ q
    movs r2,10
    muls r2,r3,r2
    subs r1,r0,r2    @ r
    adds r0,r1,6
    lsrs r0,4
    add r0,r3
    cmp r1,10
    blt 1f
    subs r1,10
1:
    pop {r2,r3,pc}

/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.global ledEclats
.thumb_func
ledEclats:                      @ INFO: ledEclats
    push {r1-r4,lr}
    movs r4,r0
    movs  r2,1
    lsls  r2,25                 @ GPIO pin 25
    ldr r3,iAdrSioBase
1:
    str r2,[r3,GPIO_OUT_XOR]   @ allumage led
    movs r0, #250
    bl attendre
    str r2,[r3,GPIO_OUT_XOR]   @ extinction led
    movs r0, #250
    bl attendre 
    subs r4,1                  @ décremente nombre eclats
    bgt 1b                     @ et boucle 
    
    pop {r1-r4,pc}
.align 2
//iAdrSioBase:    .int SIO_BASE
/******************************************************************/
/*     Début comptage systick                                         */ 
/******************************************************************/
.thumb_func
debutSystick:                  @ INFO: debutSystick
    push {lr}
    ldr r0,iAdrSystick_RVR     @ adresse Systick_RVR voir ch 2.4.8
    ldr r1,iParam              @ Reload Value Register
    str r1,[r0]                @ valeur de départ
    adds r2,r0,4               @ adresse Systick_CVR Current Value Register
    movs r1,0                  @ init compteur
    str r1,[r2]
    subs r0,4                  @ adresse Systick_CSR Control and Status Register
    movs r1,5                  @ processeur et activation 
    str r1,[r0]
    ldr r1,iAdriValDepSys
    ldr r0,[r2]                @ lecture valeur
    str r0,[r1]                @ stockage valeur début   2 cycles

100:
    pop {pc}                      @ 5 cycles
.align 2
iParam:           .int 0x00ffffff
/******************************************************************/
/*     Fin comptage systick                                         */ 
/******************************************************************/
.thumb_func
stopSystick:                  @ INFO: finSystick
    push {lr}                @ 2 cycles
    ldr r0,iAdrSystick_CVR   @ adresse Systick_RVR voir ch 2.4.8   2 cycles
    ldr r2,[r0]              @ lecture valeur
    ldr r1,iAdriValDepSys
    ldr r0,[r1]
    subs r0,r2                @ calcul différence
    ldr r1,iAdrsZoneDecSys    @ conversion
    bl conversion10
    ldr r0,iAdrszMessSystick  @ et affichage
    bl ecrireMessage
100:
    pop {pc}
    bx lr
.align 2
iAdriValDepSys:       .int iValDepSys
iAdrSystick_RVR:      .int PPB_BASE + SYST_RVR
iAdrSystick_CVR:      .int PPB_BASE + SYST_CVR
iAdrsZoneDecSys:      .int sZoneDecSys
iAdrszMessSystick:    .int szMessSystick
/******************************************************************/
/*     Début du chrono                                          */ 
/******************************************************************/
/*                    */
.thumb_func
debutChrono:                  @ INFO: debutChrono
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
stopChrono:                   @ INFO: stopChrono
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
    bl ecrireMessage
    pop {r0-r4,pc} 
.align 2
iAdrdwDebut:       .int dwDebut
iAdrTimerBase:     .int TIMER_BASE
iAdrsZoneDec:      .int sZoneDec
iAdrszMessChrono:  .int szMessChrono
/************************************/
/*       init de la Led pin 25      */
/***********************************/
.thumb_func
initLed25:                      @ INFO: initLed25
    ldr  r1,iAdrGPIO25          @ init fonction sio
    movs r0,GPIO_FUNC_SIO
    str  r0, [r1]

    ldr  r1,iAdrSioBase
    movs  r0,1
    lsls  r0,25                 @ GPIO pin 25 
    str  r0, [r1, GPIO_OE_SET]  @ output
    bx lr
.align 2
iAdrSioBase:    .int SIO_BASE
iAdrGPIO25:     .int IO_BANK0_BASE + 8 * 25 + 4
/******************************************************************/
/*     affichage zone mémoire passée par push                       */ 
/******************************************************************/
/* Vide 4 blocs seulement */
/* Attention après l'appel aligner la pile */
.thumb_func
afficherMemoire:                 @ INFO: afficherMemoire
    push {r0-r7,lr}              @ save des registres
    mov r0,sp
    ldr r0,[r0,#36]              @ début adresse mémoire
    mov r4,r0                     @ début adresse mémoire
    movs r6,#4                    @ nombre de blocs
    ldr r1,iAdrsAdresseMem        @ adresse de stockage du resultat
    bl conversion16
    adds r1,r0
    movs r0,#' '                   @ espace dans 0 final
    strb r0,[r1]

    ldr r0,iAdrszAffMem            @ affichage entete
    bl ecrireMessage
                                  @ calculer debut du bloc de 16 octets
    lsrs r1, r4,#4             @ r1 ← (r4/16)
    lsls r5, r1,#4             @ r5 ← (r1*16)
                                  @ mettre une étoile à la position de l'adresse demandée
    movs r3,#3                     @ 3 caractères pour chaque octet affichée
    subs r0,r4,r5                  @ calcul du deplacement dans le bloc de 16 octets
    muls r3,r3,r0                  @ deplacement * par le nombre de caractères
    ldr r0,iAdrsZone1              @ adresse de stockage
    adds r7,r0,r3               @ calcul de la position
    subs r7,r7,#1               @ on enleve 1 pour se mettre avant le caractère
    movs r0,#'*'           
    strb r0,[r7]               @ stockage de l'étoile
3:
                               @ afficher le debut  soit r3
    movs r0,r5
    ldr r1,iAdrsDebmem
    bl conversion16
    adds r1,r0
    //sub r1,#1
    movs r0,#' '
    strb r0,[r1]
                               @ balayer 16 octets de la memoire
    movs r2,#0
4:                             @ debut de boucle de vidage par bloc de 16 octets
    ldrb r4,[r5,r2]            @ recuperation du byte à l'adresse début + le compteur
                               @ conversion byte pour affichage
    ldr r0,iAdrsZone1           @ adresse de stockage
    movs r3,#3
    muls r3,r2,r3               @ calcul position r3 <- r2 * 3 
    add r0,r3
    //mov r1,r4
    lsrs r1,r4,#4               @ r1 ← (r4/16)
    cmp r1,#9                  @ inferieur a 10 ?
    bgt 41f
    mov r3,r1
    adds r3,#48            @ oui
    b 42f
41:
    mov r3,r1
    adds r3,#55            @ c'est une lettre en hexa
42:
    strb r3,[r0]               @ on le stocke au premier caractères de la position
    adds r0,#1                  @ 2ième caractere
    mov r3,r1
    lsls r3,#4                  @ r5 <- (r4*16)
    subs r1,r4,r3               @ pour calculer le reste de la division par 16
    cmp r1,#9                  @ inferieur a 10 ?
    bgt 43f
    mov r3,r1
    adds r3,#48
    b 44f
43:
    mov r3,r1
    adds r3,#55
44:
    strb r3,[r0]               @ stockage du deuxieme caractere
    adds r2,r2,#1               @ +1 dans le compteur
    cmp r2,#16                 @ fin du bloc de 16 caractères ? 
    blt 4b
                               @ vidage en caractères
    movs r2,#0                 @ compteur
5:                             @ debut de boucle
    ldrb r4,[r5,r2]            @ recuperation du byte à l'adresse début + le compteur
    cmp r4,#31                 @ compris dans la zone des caractères imprimables ?
    ble 6f                     @ non
    cmp r4,#125
    bgt 6f
    b 7f
6:
    movs r4,#46                 @ on force le caractere .
7:
    ldr r0,iAdrsZone2           @ adresse de stockage du resultat
    adds r0,r2
    strb r4,[r0]
    adds r2,r2,#1
    cmp r2,#16                 @ fin de bloc ?
    blt 5b    
                               @ affichage resultats
    ldr r0,iAdrsDebmem
    bl ecrireMessage
    movs r0,#' '
    strb r0,[r7]              @ on enleve l'étoile pour les autres lignes
    
    adds r5,r5,#16             @ adresse du bloc suivant de 16 caractères
    //push {r5}
    //bl affRegHexa
    //add sp,4
    subs r6,r6,#1              @ moins 1 au compteur de blocs
    cmp r6,#0
    bgt 3b                    @ boucle si reste des bloc à afficher
    
    pop {r0-r7,pc}
.align 2
iAdrszAffMem:     .int szAffMem
iAdrsAdresseMem:  .int sAdresseMem
iAdrsDebmem:      .int sDebmem
iAdrsZone1:       .int sZone1
iAdrsZone2:       .int sZone2
