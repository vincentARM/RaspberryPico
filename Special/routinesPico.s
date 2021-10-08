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
.include "../constantesPico.inc"
.equ   PICO_OK,              0
.equ   PICO_ERROR_NONE,      0
.equ   PICO_ERROR_TIMEOUT,  -1
.equ   PICO_ERROR_GENERIC,  -2
.equ   PICO_ERROR_NO_DATA,  -3

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessAffReg:      .ascii "Valeur du registre : "
sZoneRes:          .ascii "         "
                   .asciz " "
                                        @ donnees pour vidage mémoire
szAffMem:      .ascii "Affichage mémoire "
sAdr1:         .ascii " adresse : "
sAdresseMem :  .asciz "           "
 
sDebmem:       .fill 9, 1, ' '
s1mem:         .ascii " "
sZone1:        .fill 48, 1, ' '
s2mem:         .ascii " "
sZone2:        .fill 16, 1, ' '
s3mem:         .asciz " "

szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:"

szMessAffBin:      .ascii "Affichage binaire : "
szZoneConvBin:     .asciz "                                      "

szMessChrono:     .ascii "Temps = "
sZoneDec:         .asciz "             "
.align 4
ptzZoneHeap:       .int zZoneHeap
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
dwDebut:    .skip 8
dwFin:      .skip 8
zZoneHeap:              .skip HEAPSIZE
zEndZoneHeap:
sBuffer:    .skip 20 

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global lireChaine,cmdAffReg,affRegBin,affZoneMem,comparerChaines,affRegHexa,afficherMemoire,convertirChHexa
.global attendre,conversion16,conversion2,appelFctRom,insertChaineChar,reserverPlace,libererPlace, appelDatasRom
.global debutChrono,stopChrono,conversion10
/******************************************************************/
/*     lire une commande                                          */ 
/******************************************************************/
/* r0 contient l'adresse du buffer                   */
.thumb_func
lireChaine:              @ INFO: lireChaine
    push {r4-r6,lr}
    movs r5,r0
    movs r6, 0          @ nombre de caractères
    ldr r4,iValErreur
1:                      @ lire un caractère
    movs r0, 100
    bl getchar_timeout_us
    bl majWatchDog          @ maj du watchdog
    cmp r0,r4
    beq 1b
    cmp r0, 0
    beq 5f
    cmp r0, 0xD
    beq 5f
    strb r0,[r5,r6]
    adds r6, 1
    bl putchar
    b 1b
5:
    movs r0, 0
    strb r0,[r5,r6]
    movs r0, 0xA
    bl putchar
    movs r0, 0xD
    bl putchar
    movs r0,r6
    pop {r4-r6,pc}
.align 2
iValErreur:             .int PICO_ERROR_TIMEOUT
/******************************************************************/
/*     mise à jour compteur majWatchDog                           */ 
/******************************************************************/
/* test commande aff */
.thumb_func
.global majWatchDog
majWatchDog:                    @ INFO:  majWatchDog
    push {r0-r1,lr}
    ldr r0,iAdrWatchdog      @ lancement du compteur
    ldr r1,iDelai
    str r1,[r0,#WATCHDOG_LOAD]
    pop {r0-r1,pc}
.align 2
iAdrWatchdog:    .int WATCHDOG_BASE
iDelai:          .int 10000000          @ 10 s
/******************************************************************/
/*     affichage registre systeme                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
cmdAffReg:                    @ INFO:  cmdAffReg
    push {lr}
    ldr r0,iAdrszMessSaisieReg
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    bl convertirChHexa
    bcs 100f
    push {r0}
    bl affRegHexa
    add sp, 4
    ldr r1,[r0]
    push {r1}
    bl affRegHexa
    add sp, 4
100:
    pop {pc}
.align 2

/******************************************************************/
/*     affichage registre systeme  en binaire                               */ 
/******************************************************************/
/* test commande aff */
.thumb_func
affRegBin:                     @ INFO: affRegBin
    push {lr}
    ldr r0,iAdrszMessSaisieReg
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    bl convertirChHexa
    bcs 100f
    ldr r0,[r0]
    ldr r1,iAdrszZoneConvBin
    bl conversion2
    ldr r0,iAdrszMessAffBin
    bl __wrap_puts
100:
    pop {pc}
/******************************************************************/
/*     affichage zone memoire                               */ 
/******************************************************************/
/* test commande aff */
.thumb_func
affZoneMem:                    @ INFO: affZoneMem
    push {lr}
    ldr r0,iAdrszMessSaisieReg
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    bl convertirChHexa
    bcs 100f
    push {r0}
    bl afficherMemoire
    add sp, 4
100:
    pop {pc}
.align 2
iAdrszMessAffBin:    .int szMessAffBin
iAdrszZoneConvBin:   .int szZoneConvBin
iAdrszMessSaisieReg: .int szMessSaisieReg
iAdrsBuffer:         .int sBuffer
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
/******************************************************************/
/*     affichage du registre passé par push                       */ 
/******************************************************************/
/* r0 contient l adresse du message */
/* Attention après l'appel aligner la pile */
.thumb_func
affRegHexa:                 @ INFO: affRegHexa
    push {r0-r4,lr}         @ save des registres
    mov r0,sp
    ldr r0,[r0, 24]
    ldr r1,iAdrsZoneRes
    bl conversion16
    ldr r0,iAdrszMessAffReg
    bl __wrap_puts
    pop {r0-r4,pc}          @ restaur des registres
.align 2
iAdrsZoneRes:     .int sZoneRes
iAdrszMessAffReg: .int szMessAffReg

/******************************************************************/
/*     affichage zone mémoire passée par push                       */ 
/******************************************************************/
/* Vide 4 blocks seulement */
/* Attention après l'appel aligner la pile */
.thumb_func
afficherMemoire:                 @ INFO: afficherMemoire
    push {r0-r7,lr}              @ save des registres
    mov r0,sp
    ldr r0,[r0, 36]              @ début adresse mémoire
    push {r0}
    bl affRegHexa
    add sp,sp, 4
    movs r4,r0                    @ début adresse mémoire
    movs r6, 4                    @ nombre de blocs
    ldr r1,iAdrsAdresseMem        @ adresse de stockage du resultat
    bl conversion16
    adds r1,r0
    movs r0, ' '                   @ espace dans 0 final
    strb r0,[r1]

    ldr r0,iAdrszAffMem            @ affichage entete
    bl __wrap_puts
    movs r0, 100
    bl sleep_ms
                                  @ calculer debut du bloc de 16 octets
    lsrs r1, r4, 4             @ r1 ← (r4/16)
    lsls r5, r1, 4             @ r5 ← (r1*16)
                                  @ mettre une étoile à la position de l'adresse demandée
    movs r3, 3                     @ 3 caractères pour chaque octet affichée
    subs r0,r4,r5                  @ calcul du deplacement dans le bloc de 16 octets
    muls r3,r0,r3                  @ deplacement * par le nombre de caractères
    ldr r0,iAdrsZone1              @ adresse de stockage
    adds r7,r0,r3               @ calcul de la position
    subs r7,r7, 1               @ on enleve 1 pour se mettre avant le caractère
    movs r0, '*'           
    strb r0,[r7]               @ stockage de l'étoile
3:
                               @ afficher le debut  soit r3
    movs r0,r5
    ldr r1,iAdrsDebmem
    bl conversion16
    add r1,r0
    //sub r1, 1
    movs r0, ' '
    strb r0,[r1]
                               @ balayer 16 octets de la memoire
    movs r2, 0
4:                             @ debut de boucle de vidage par bloc de 16 octets
    ldrb r4,[r5,r2]            @ recuperation du byte à l'adresse début + le compteur
                               @ conversion byte pour affichage
    ldr r0,iAdrsZone1           @ adresse de stockage
    movs r3, 3
    muls r3,r2,r3               @ calcul position r3 <- r2 * 3 
    adds r0,r3
    //mov r1,r4
    lsrs r1,r4, 4               @ r1 ← (r4/16)
    cmp r1, 9                  @ inferieur a 10 ?
    bgt 41f
    movs r3,r1
    adds r3, 48            @ oui
    b 42f
41:
    movs r3,r1
    adds r3, 55            @ c'est une lettre en hexa
42:
    strb r3,[r0]               @ on le stocke au premier caractères de la position
    adds r0, 1                  @ 2ième caractere
    movs r3,r1
    lsls r3, 4                  @ r5 <- (r4*16)
    subs r1,r4,r3               @ pour calculer le reste de la division par 16
    cmp r1, 9                  @ inferieur a 10 ?
    bgt 43f
    movs r3,r1
    adds r3, 48
    b 44f
43:
    mov r3,r1
    adds r3, 55
44:
    strb r3,[r0]               @ stockage du deuxieme caractere
    adds r2,r2, 1               @ +1 dans le compteur
    cmp r2, 16                 @ fin du bloc de 16 caractères ? 
    blt 4b
                               @ vidage en caractères
    movs r2, 0                  @ compteur
5:                             @ debut de boucle
    ldrb r4,[r5,r2]            @ recuperation du byte à l'adresse début + le compteur
    cmp r4, 31                 @ compris dans la zone des caractères imprimables ?
    ble 6f                     @ non
    cmp r4, 125
    bgt 6f
    b 7f
6:
    movs r4, 46                 @ on force le caractere .
7:
    ldr r0,iAdrsZone2           @ adresse de stockage du resultat
    adds r0,r2
    strb r4,[r0]
    adds r2,r2, 1
    cmp r2, 16                 @ fin de bloc ?
    blt 5b    
                               @ affichage resultats */
    ldr r0,iAdrsDebmem
    bl __wrap_puts
    movs r0, 100
    bl sleep_ms
    movs r0, ' '
    strb r0,[r7]              @ on enleve l'étoile pour les autres lignes
    
    adds r5,r5, 16             @ adresse du bloc suivant de 16 caractères
    subs r6,r6, 1                @ moins 1 au compteur de blocs
    bgt 3b                     @ boucle si reste des bloc à afficher
    
                               @ fin de la fonction 
    pop {r0-r7,pc}             @ restaur des registres
.align 2
iAdrszAffMem:     .int szAffMem
iAdrsAdresseMem:  .int sAdresseMem
iAdrsDebmem:      .int sDebmem
iAdrsZone1:       .int sZone1
iAdrsZone2:       .int sZone2
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

/***************************************************/
/*     conversion chaine hexa en  valeur           */
/***************************************************/
// r0 contains string address
// r0 return value
// carry on if error
.thumb_func
convertirChHexa:               @ INFO: convertirChHexa
    push {r4,lr}               @ save  registers 
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
    bgt 2f
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
    bl __wrap_puts
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
/************************************/
/*       conversion binaire         */
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
    pop {r4,pc}             @ restaur registers
/******************************************************************/
/*     Début du chrono                                          */ 
/******************************************************************/
/*                    */
.thumb_func
debutChrono:                  @ INFO: debutChrono
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMER_TIMERAWL]
    ldr r2,[r0,TIMER_TIMERAWH]
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
stopChrono:                  @ INFO: stopChrono
    push {r0-r4,lr} 
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMER_TIMERAWL]
    ldr r2,[r0,TIMER_TIMERAWH]
    ldr r0,iAdrdwDebut
    ldr r4,[r0,4]             @ chargement zones
    ldr r3,[r0]
    subs r0,r1,r4
    sbcs r2,r3
    ldr r1,iAdrsZoneDec
    bl conversion10
    ldr r0,iAdrszMessChrono
    bl __wrap_puts
    pop {r0-r4,pc} 
.align 2
iAdrdwDebut:       .int dwDebut
iAdrTimerBase:     .int TIMER_BASE
iAdrsZoneDec:      .int sZoneDec
iAdrszMessChrono:  .int szMessChrono
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
/************************************************/
/* appel des fonctions de la Rom  partie Datas  */
/************************************************/
/* r0 Code 1  */
/* r1 code 2  */
.thumb_func
appelDatasRom:              @ INFO: appelDatasRom
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
/***************************************************/
/*   reserve heap area                             */
/***************************************************/
// r0 contains size in byte to reserve */
// r0 returne  begin address of area */
.thumb_func
reserverPlace:              @ INFO: reserverPlace
    push {r1,r2,r3,lr}      @ save des registres
    movs r1,r0
    movs r2,0b11
    tst r1,r2               @ taille multiple de 4 ?
    beq 1f                  @ oui
    ldr r2,iConst1
    ands r1,r2              @ sinon alignement sur frontière supérieure de 4
    adds r1,#4
1:
    ldr r2,iAdrptzZoneHeap
    ldr r0,[r2]
    adds r1,r1,r0            @  taille trop grande ?
    ldr r3,iAdrzEndZoneHeap
    cmp r1,r3
    blt 2f                  @ non 
    adr r0,szMessErrTas     @ oui -> erreur
    bl __wrap_puts
    movs r0,0
    subs r0,1
    b 100f
2:
    str r1,[r2]           @ stocke le nouveau pointeur
100:                      @ fin standard de la fonction
    pop {r1,r2,r3,pc}     @ restaur des registres
.align 2
iConst1:               .int 0xFFFFFFFC
szMessErrTas:          .asciz "Erreur : tas trop petit !!!\n"
.align 2
/***************************************************/
/*   liberer place sur le tas                     */
/***************************************************/
// r0 contains begin address area 
.thumb_func
libererPlace:               @ INFO: libererPlace
    push {r1,lr}            @ save des registres
    ldr r1,iAdrzZoneHeap
    cmp r0,r1
    blt 99f
    ldr r1,iAdrzEndZoneHeap
    cmp r0,r1
    bge 99f
    ldr r1,iAdrptzZoneHeap
    str r0,[r1]
    b 100f
99:
    adr r0,szMessErrTas1
    bl __wrap_puts
    movs r0,0
    subs r0,1
100:
    pop {r1,pc}                          @ restaur registers 
.align 2
iAdrzZoneHeap:    .int zZoneHeap
iAdrzEndZoneHeap: .int zEndZoneHeap
iAdrptzZoneHeap:  .int ptzZoneHeap
szMessErrTas1:    .asciz "Erreur adresse < ou > adresses tas !!!\n"
.align 4
/******************************************************************/
/*   insert string at character insertion                         */ 
/******************************************************************/
/* r0 contains the address of string 1 */
/* r1 contains the address of insertion string   */
/* r0 return the address of new string  on the heap */
/* or -1 if error   */
.thumb_func
insertChaineChar:             @ INFO: insertChaineChar
    push {r1-r7,lr}                         @ save  registres
    movs r3,#0                                // length counter 
1:                                           // compute length of string 1
    ldrb r4,[r0,r3]
    cmp r4,#0
    beq 11f
    adds r3,r3,#1                           // increment to one if not equal
    b 1b                                    // loop if not equal
11:
    movs r5,#0                                // length counter insertion string
2:                                           // compute length to insertion string
    ldrb r4,[r1,r5]
    cmp r4,#0
    beq 21f
    adds r5,r5,#1                           // increment to one if not equal
    b 2b                                   // and loop
21:
    cmp r5,#0
    beq 99f                                  // string empty -> error
    adds r3,r3,r5                             // add 2 length
    adds r3,r3,#1                             // +1 for final zero
    movs r6,r0                                // save address string 1
    movs r0,r3
    bl reserverPlace
    movs r5,r0                                // save address heap for output string
    movs r2,0
    subs r2,1
    cmp r0,r2                               // allocation error
    beq 99f
 
    movs r2,#0
    movs r4,#0
3:                                           // loop copy string begin 
    ldrb r3,[r6,r2]
    cmp r3,#0
    beq 99f
    cmp r3,#CHARPOS                           // insertion character ?
    beq 5f                                   // yes
    strb r3,[r5,r4]                          // no store character in output string
    adds r2,r2,#1
    adds r4,r4,#1
    b 3b                                     // and loop
5:                                           // r4 contains position insertion
    adds r7,r4,#1                              // init index character output string
                                             // at position insertion + one
    movs r3,#0                                // index load characters insertion string
6:
    ldrb r0,[r1,r3]                          // load characters insertion string
    cmp r0,#0                                // end string ?
    beq 7f                                   // yes 
    strb r0,[r5,r4]                          // store in output string
    adds r3,r3,#1                             // increment index
    adds r4,r4,#1                             // increment output index
    b 6b                                     // and loop
7:                                           // loop copy end string 
    ldrb r0,[r6,r7]                          // load other character string 1
    strb r0,[r5,r4]                          // store in output string
    cmp r0,#0                                // end string 1 ?
    beq 8f                                   // yes -> end
    adds r4,r4,#1                             // increment output index
    adds r7,r7,#1                             // increment index
    b 7b                                     // and loop
8:
    movs r0,r5                                // return output string address 
    b 100f
99:                                          // error
    movs r0,0
    subs r0,1
100:
    pop {r1-r7,pc}                          @ restaur registers 
    