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
                   .asciz " "
szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:"
szMessAffBin:      .ascii "Affichage binaire : "
szZoneConvBin:     .asciz "                                      \r\n"
                                        @ donnees pour vidage mémoire
szAffMem:      .ascii "Mémoire "
sAdr1:         .ascii " adresse : "
sAdresseMem :  .ascii "          "
sZoneLibel:    .fill NBCARLIBEL,1,' '
               .asciz " "
sDebmem:       .fill 9, 1, ' '
s1mem:         .ascii " "
sZone1:        .fill 48, 1, ' '
s2mem:         .ascii " "
sZone2:        .fill 16, 1, ' '
s3mem:         .asciz " "
                                 @ donnees pour vidage tout registres */          
szLigne1:      .ascii "Vidage registres : "
szLibTitre:    .fill LGZONEADR, 1, ' '
suiteReg:      .ascii "\r\nr0  : "
reg0:          .fill 9, 1, ' '
s1: .ascii " r1  : "
reg1: .fill 9, 1, ' '
s2: .ascii " r2  : "
reg2: .fill 9, 1, ' '
s3: .ascii " r3  : "
reg3: .fill 9, 1, ' '
/*ligne2 */
s4: .asciz " "
szLigne2: .ascii "r4  : "
reg4: .fill 9, 1, ' '
s5: .ascii " r5  : "
reg5: .fill 9, 1, ' '
s6: .ascii " r6  : "
reg6: .fill 9, 1, ' '
s7: .ascii " r7  : "
reg7: .fill 9, 1, ' '
/*ligne 3 */
s8: .asciz " " 
szLigne3: .ascii "r8  : "
reg8: .fill 9, 1, ' '
s9: .ascii " r9  : "
reg9: .fill 9, 1, ' '
s10: .ascii " r10 : "
reg10: .fill 9, 1, ' '
s11: .ascii " fp  : "
reg11: .fill 9, 1, ' '
/*ligne4 */
s12: .asciz " "

szLigne4: .ascii "r12 : "
reg12: .fill 9, 1, ' '
s13: .ascii " sp  : "
reg13: .fill 9, 1, ' '
s14: .ascii " lr  : inconnu  "
s15: .ascii " pc  : "
reg15: .fill 9, 1, ' '

fin: .asciz " "
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:        .skip 80

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global affRegHexa,conversion16,comparerChaines
.global attendre,divisionEntiere
.global appelFctRom,appelDatasRom,conversion10,conversion2,convertirChHexa
.global afficherMemoire,divisionpar10U,affregistres

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
    bl      __wrap_puts
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
    push {r1,lr} 
    lsls r1,r0,15             @ approximatif 
    lsls r0,r0,13
    adds r0,r1
1:
    subs r0,r0, 1
    bne 1b
    pop {r1,pc}

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
//ptRom_table_lookup:     .int 0x18
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
    bl      __wrap_puts
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
/*****************************************************/
/*     affichage zone mémoire                        */ 
/*****************************************************/
/* r0  : adresse zone mémoire */
/* r1  : nombre de blocs */
/* r2  : adresse libellé  */
.thumb_func
afficherMemoire:                 @ INFO: afficherMemoire
    push {r0-r7,lr}              @ save des registres
    //mov r0,sp
    //ldr r0,[r0,#36]              @ début adresse mémoire
    //push {r2}
    //bl affRegHexa
    //add sp,#4
    mov r4,r0                     @ début adresse mémoire
    movs r6,r1                    @ nombre de blocs
    ldr r1,iAdrsAdresseMem        @ adresse de stockage du resultat
    bl conversion16
    add r1,r0
    movs r0,#' '                   @ espace dans 0 final
    strb r0,[r1]
    
    //afficherLib debut
                                   @ recopie libellé
    ldr r3,iAdrsZoneLibel
    movs r5,#0
1:
    ldrb r7,[r2,r5]
    cmp r7,#0
    beq 2f
    strb r7,[r3,r5]
    adds r5,r5,#1
    b 1b
2:
    movs r7,' '
21:
    cmp r5,NBCARLIBEL
    bge 22f
    strb r7,[r3,r5]
    adds r5,r5,#1
    b 21b
22:
    //afficherLib debut1
    ldr r0,iAdrszAffMem            @ affichage entete
    bl      __wrap_puts
    //b 100f
                                  @ calculer debut du bloc de 16 octets
    lsrs r1, r4,#4             @ r1 ← (r4/16)
    lsls r5, r1,#4             @ r5 ← (r1*16)
                                  @ mettre une étoile à la position de l'adresse demandée
    movs r3,#3                     @ 3 caractères pour chaque octet affichée
    subs r0,r4,r5                  @ calcul du deplacement dans le bloc de 16 octets
    muls r3,r0,r3                  @ deplacement * par le nombre de caractères
    ldr r0,iAdrsZone1              @ adresse de stockage
    adds r7,r0,r3               @ calcul de la position
    subs r7,r7,#1               @ on enleve 1 pour se mettre avant le caractère
    movs r0,#'*'           
    strb r0,[r7]               @ stockage de l'étoile
3:
                               @ afficher le debut  soit r3
    mov r0,r5
    ldr r1,iAdrsDebmem
    bl conversion16
    adds r1,r0
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
    adds r0,r3
    lsrs r1,r4,#4               @ r1 ← (r4/16)
    cmp r1,#9                  @ inferieur a 10 ?
    bgt 41f
    mov r3,r1
    adds r3,#48                @ oui
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
    movs r2,#0                  @ compteur
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
                               @ affichage resultats */
    ldr r0,iAdrsDebmem
    bl      __wrap_puts
    movs r0,#' '
    strb r0,[r7]              @ on enleve l'étoile pour les autres lignes
    
    adds r5,r5,#16             @ adresse du bloc suivant de 16 caractères
    subs r6,r6,#1                @ moins 1 au compteur de blocs
    cmp r6,#0
    bgt 3b                    @ boucle si reste des bloc à afficher
100:
                                          @ fin de la fonction 
    pop {r0-r7,pc}                        @ restaur des registres
    .align 2
iAdrszAffMem:     .int szAffMem
iAdrsAdresseMem:  .int sAdresseMem
iAdrsDebmem:      .int sDebmem
iAdrsZone1:       .int sZone1
iAdrsZone2:       .int sZone2
iAdrsZoneLibel:   .int sZoneLibel
/**************************************************/
/*     affichage de tous les registres               */
/**************************************************/
/* argument pile : adresse du libelle a afficher */
affregistres:          @ INFO: affregistres
    push {lr}          @ saveregistre 
    push {r0,r1,r2,r3} @ save des registres pour restaur finale en fin */ 
    push {r0,r1,r2,r3} @ save des registres avant leur vidage */ 
    ldr r1,[sp,#36]     @ recup du libellé sur la pile  décalage 9 push
    movs r2,#0
    ldr r0,iAdrszLibTitre
1: @ boucle copie
    ldrb r3,[r1,r2]
    cmp r3,#0
    beq 11f
    strb r3,[r0,r2]
    adds r2,r2,#1
    b 1b
11:
    movs r3,#' '
2:
    strb r3,[r0,r2]
    adds r2,r2,#1
    cmp r2,#LGZONEADR
    blt 2b
    /* contenu registre */
    ldr r1,adresse_reg0 /*adresse de stockage du resultat */
    pop {r0}  
    bl conversion16
    
    ldr r1,adresse_reg1 /*adresse de stockage du resultat */
    pop {r0}
    bl conversion16
    ldr r1,adresse_reg2 /*adresse de stockage du resultat */
    pop {r0}  
    bl conversion16
    ldr r1,adresse_reg3 /*adresse de stockage du resultat */
    pop {r0}  
    bl conversion16
    ldr r1,adresse_reg4 /*adresse de stockage du resultat */
    mov r0,r4
    bl conversion16
    ldr r1,adresse_reg5 /*adresse de stockage du resultat */
    mov r0,r5
    bl conversion16
    ldr r1,adresse_reg6 /*adresse de stockage du resultat */
    mov r0,r6  
    bl conversion16
    ldr r1,adresse_reg7 /*adresse de stockage du resultat */
    mov r0,r7
    bl conversion16
    ldr r1,adresse_reg8 /*adresse de stockage du resultat */
    mov r0,r8 
    bl conversion16
    ldr r1,adresse_reg9 /*adresse de stockage du resultat */
    mov r0,r9 
    bl conversion16
    ldr r1,adresse_reg10 /*adresse de stockage du resultat */
    mov r0,r10 
    bl conversion16
    ldr r1,adresse_reg11 /*adresse de stockage du resultat */
    mov r0,r11 
    bl conversion16
    ldr r1,adresse_reg12 /*adresse de stockage du resultat */
    mov r0,r12
    bl conversion16
    /* r13 = sp   */
    ldr r1,adresse_reg13 /*adresse de stockage du resultat */
    add r0,sp,#32     @ car 5 push qui ont décalé la pile + 3 de la macro
    bl conversion16
    /* r14 = lr   adresse du retour  sauvegardé au début */
    /* mais c'est l'adresse de retour du programme appelant  */
    /* et donc qui est ecrase par l'appel de cette procedure */
    /* pour connaitre la valeur exacte il faut utiliser vidregistre */
    /* en vidant le contenu de lr */

    /* r15 = pc  donc contenu = adresse de retour (lr) - 4 */
    ldr r1,adresse_reg15 /*adresse de stockage du resultat */
    //sub r2,r7,#4
    ldr r0,[sp,#16]      @ car 4 pushs pour arriver à lr
    subs r0,r0,#4
    bl conversion16
    
                                @ affichage resultats */
    ldr r0,iAdrszLigne1
    bl      __wrap_puts
    ldr r0,iAdrszLigne2
    bl      __wrap_puts
    ldr r0,iAdrszLigne3
    bl      __wrap_puts
    ldr r0,iAdrszLigne4
    bl      __wrap_puts
    
    pop {r0,r1,r2,r3}           @ fin fonction
    pop {pc}                    @ restaur registre

.align 2
iAdrszLigne1:       .int szLigne1
iAdrszLigne2:       .int szLigne2
iAdrszLigne3:       .int szLigne3
iAdrszLigne4:       .int szLigne4
iAdrszLibTitre:     .int szLibTitre 
adresse_reg0:       .int reg0
adresse_reg1:       .int reg1
adresse_reg2:       .int reg2
adresse_reg3:       .int reg3
adresse_reg4:       .int reg4
adresse_reg5:       .int reg5
adresse_reg6:       .int reg6
adresse_reg7:       .int reg7
adresse_reg8:       .int reg8
adresse_reg9:       .int reg9
adresse_reg10:      .int reg10
adresse_reg11:      .int reg11
adresse_reg12:      .int reg12
adresse_reg13:      .int reg13
adresse_reg15:      .int reg15 
/**********************************************/	  
/* division entiere non signée                */
/* routine trouvée sur Internet               */
/* auteur à rechercher                        */ 
/**********************************************/
/* attention ne sauve que le registre r4 */	  
divisionEntiere:                   @ INFO: divisionEntiere
    /* r0 contient Nombre */
    /* r1 contient Diviseur */
    /* r2 contient Quotient */
    /* r3 contient Reste */
    push {r4, lr}
    movs r2, #0
    movs r3, #0
    movs r4, #32
    b 3f
1:
    movs r0, r0, LSL #1    @ r0 <- r0 << 1 updating cpsr (sets C if 31st bit of r0 was 1)
    adcs r3, r3, r3        @ r3 <- r3 + r3 + C. This is equivalent to r3 ? (r3 << 1) + C
 
    cmp r3, r1             @ compute r3 - r1 and update cpsr
    blt 2f
    subs r3, r3, r1        @ if r3 >= r1 (C=1) then r3 ? r3 - r1
2:
    adcs r2, r2, r2        @ r2 ? r2 + r2 + C. This is equivalent to r2 ? (r2 << 1) + C
3:
    subs r4, r4, #1        @ r4 ? r4 - 1
    bpl 1b                 @ if r4 >= 0 (N=0) then branch to .Lloop1
 
    pop {r4, pc}
