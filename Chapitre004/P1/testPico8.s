/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* commandes  afficher un registre memoire en binaire */
/* afficher une zone mémoire */
/* test appel fonction de la rom */ 
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/* L'include des constantes générales est   */
/* en fin du programme                      */
/********************************************/
.equ   PICO_OK,              0
.equ   PICO_ERROR_NONE,      0
.equ   PICO_ERROR_TIMEOUT,  -1
.equ   PICO_ERROR_GENERIC,  -2
.equ   PICO_ERROR_NO_DATA,  -3
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
.macro afficherLib str 
    push {r0-r3}               @ save registres
    adr r0,libaff1\@           @ recup adresse libellé passé dans str
    bl __wrap_puts
    pop {r0-r3}                @ restaur registres
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
szMessDebutPgm:    .asciz "Debut du programme."
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

szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"
szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:"

szMessAffBin:      .ascii "Affichage binaire : "
szZoneConvBin:     .asciz "                                      "
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
6:                              @ test appel fonction rom
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 7f
    movs r0,'P'                 @ codes pour la fonction
    movs r1,'3'                 @ nombre de bits à 1 dans la valeur
    movs r2,2                   @ valeur passée en paramètre
    movs r3,0
    movs r4,0
    bl appelFctRom
    afficherLib ResultatFonction
    push {r0}
    bl affRegHexa
    add sp, 4
    
    b 10f
7:                               @ affichage registre binaire mémoire
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
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdAff:        .int szLibCmdAff
iAdrszLibCmdMem:        .int szLibCmdMem
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszLibCmdBin:        .int szLibCmdBin
iAdrszMessDebutPgm:     .int szMessDebutPgm
/******************************************************************/
/*     lire une commande                                          */ 
/******************************************************************/
/* r0 contient l'adresse du buffer                   */
.thumb_func
lireChaine:
    push {r4-r6,lr}
    movs r5,r0
    movs r6, 0          @ nombre de caractères
    ldr r4,iValErreur
1:                      @ lire un caractère
    movs r0, 100
    bl getchar_timeout_us
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
/*     affichage registre systeme                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
cmdAffReg:
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
/* test commande bin */
.thumb_func
affRegBin:
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
affZoneMem:
    push {lr}
    ldr r0,iAdrszMessSaisieReg
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    bl convertirChHexa
    bcs 100f
    push {r0}              @ passage adresse demandée à la fonction
    bl afficherMemoire
    add sp, 4              @ alignement pile
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
    push {r2-r4,lr}       @ save des registres
    movs r2, 0            @ indice
1:    
    ldrb r3,[r0,r2]       @ octet chaine 1
    ldrb r4,[r1,r2]       @ octet chaine 2
    cmp r3,r4
    blt 2f
    bgt 3f
    cmp r3, 0             @ 0 final
    beq 4f                @ c est la fin
    adds r2,r2, 1         @ sinon plus 1 dans indice
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
afficherMemoire:                 @ INFO: affRegHexa
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
    movs r0, ' '                  @ espace dans 0 final
    strb r0,[r1]

    ldr r0,iAdrszAffMem           @ affichage entete
    bl __wrap_puts
    movs r0, 100
    bl sleep_ms
                                  @ calculer debut du bloc de 16 octets
    lsrs r1, r4, 4                @ r1 ← (r4/16)
    lsls r5, r1, 4                @ r5 ← (r1*16)
                                  @ mettre une étoile à la position de l adresse demandée
    movs r3, 3                    @ 3 caractères pour chaque octet affichée
    subs r0,r4,r5                 @ calcul du deplacement dans le bloc de 16 octets
    muls r3,r0,r3                 @ deplacement * par le nombre de caractères
    ldr r0,iAdrsZone1             @ adresse de stockage
    adds r7,r0,r3                 @ calcul de la position
    subs r7,r7, 1                 @ on enleve 1 pour se mettre avant le caractère
    movs r0, '*'           
    strb r0,[r7]                  @ stockage de l étoile
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
4:                                @ debut de boucle de vidage par bloc de 16 octets
    ldrb r4,[r5,r2]               @ recuperation du byte à l adresse début + le compteur
                                  @ conversion byte pour affichage
    ldr r0,iAdrsZone1             @ adresse de stockage
    movs r3, 3
    muls r3,r2,r3                 @ calcul position r3 <- r2 * 3 
    adds r0,r3
    lsrs r1,r4, 4                 @ r1 ← (r4/16)
    cmp r1, 9                     @ inferieur a 10 ?
    bgt 41f
    movs r3,r1
    adds r3, 48                   @ oui
    b 42f
41:
    movs r3,r1
    adds r3, 55                   @ c est une lettre en hexa
42:
    strb r3,[r0]                  @ on le stocke au premier caractères de la position
    adds r0, 1                    @ 2ième caractere
    movs r3,r1
    lsls r3, 4                    @ r3 <- (r3*16)
    subs r1,r4,r3                 @ pour calculer le reste de la division par 16
    cmp r1, 9                     @ inferieur a 10 ?
    bgt 43f
    movs r3,r1
    adds r3, 48
    b 44f
43:
    mov r3,r1
    adds r3, 55
44:
    strb r3,[r0]                  @ stockage du deuxieme caractere
    adds r2,r2, 1                 @ +1 dans le compteur
    cmp r2, 16                    @ fin du bloc de 16 caractères ? 
    blt 4b
                                  @ vidage en caractères
    movs r2, 0                    @ compteur
5:                                @ debut de boucle
    ldrb r4,[r5,r2]               @ recuperation du byte à l adresse début + le compteur
    cmp r4, 31                    @ compris dans la zone des caractères imprimables ?
    ble 6f                        @ non
    cmp r4, 125
    bgt 6f
    b 7f
6:
    movs r4, 46                   @ on force le caractere .
7:
    ldr r0,iAdrsZone2             @ adresse de stockage du resultat
    adds r0,r2
    strb r4,[r0]
    adds r2,r2, 1
    cmp r2, 16                    @ fin de bloc ?
    blt 5b    
                                  @ affichage resultats */
    ldr r0,iAdrsDebmem
    bl __wrap_puts
    movs r0, 100
    bl sleep_ms
    movs r0, ' '
    strb r0,[r7]                  @ on enleve l étoile pour les autres lignes
    
    adds r5,r5, 16                @ adresse du bloc suivant de 16 caractères
    subs r6,r6, 1                 @ moins 1 au compteur de blocs
    bgt 3b                        @ boucle si reste des bloc à afficher
    
                                  @ fin de la fonction 
    pop {r0-r7,pc}                @ restaur des registres
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
conversion16:               @ INFO: affRegHexa
    push {r1-r4,lr}         @ save des registres

    movs r2, 28              @ start bit position
    movs r4, 0xF             @ mask
    lsls r4, 28
    movs r3,r0               @ save entry value
1:                           @ start loop
    movs r0,r3
    ands r0,r0,r4            @ value register and mask
    lsrs r0,r2               @ move right 
    cmp r0, 10               @ compare value
    bge 2f
    adds r0, 48              @ <10  ->digit 
    b 3f
2:    
    adds r0, 55              @ >10  ->letter A-F
3:
    strb r0,[r1]             @ store digit on area and + 1 in area address
    adds r1, 1
    lsrs r4, 4               @ shift mask 4 positions
    subs r2,r2, 4            @  counter bits - 4 <= zero  ?
    bge 1b                   @  no -> loop
    movs r0, 8
    pop {r1-r4,pc}           @ restaur des registres

/***************************************************/
/*     conversion chaine hexa en  valeur           */
/***************************************************/
// r0 contient adresse chaine
// r0 retiurne la valeur
// carry on si erreur
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
    bl __wrap_puts
    movs r0, 200
    bl attendre
    movs r0,0
    cmp r0,r0                @ positionne le carry à 1
    b 100f
10:
    movs r0,r3
    cmn r2,r2                @ positionne le carry à 0
100: 
    pop {r4,pc}              @ restaur registers
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
appelFctRom:
    push {r2-r5,lr}            @ save  registers 
    lsls r1,#8                 @ conversion des codes
    orrs r0,r1
    ldr r1,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r1]               @ sur 2 octets seulement
    ldr r1,ptFunctionTable
    movs r3,#0
    ldrh r3,[r1]               @ sur 2 octets seulement
    movs r1,r0
    movs r0,r3                 @ init des valeurs
    blx r2                     @ recherche fonction à appeler
    movs r5,r0
    ldr r0,[sp]                @ Comme r2 et r3 peuvent être écrasés par l appel précedent
    ldr r1,[sp,4]              @ récupération des paramétres 1 et  2 pour la fonction
    movs r2,r4                 @ parametre 3 fonction
    blx r5                     @ et appel de la fonction trouvée 

    pop {r2-r5,pc}             @ restaur registers
.align 2
ptRom_table_lookup:     .int 0x18
ptFunctionTable:        .int 0x14
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:
    lsls r0,r0,16             @ approximatif TODO: à verifier avec le timer
1:
    subs r0,r0, 1
    bne 1b
    bx lr
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 contient la valeur   */
/* r1 contient l'adresse de la zone de conversion */
.thumb_func
conversion2:
    push {r4,lr}            @ save  registers 
    movs r2,0               @ indice position bit
    movs r4,0               @ indice position caractère dans zone de conversion
1:
    lsls r0,1               @ deplacement 1 caractère gauche
    bcs 2f                  @ carry ?
    movs r3,'0'             @ non -> 0 
    b 3f
2:
    movs r3,'1'             @ oui > 1
3:
    strb r3,[r1,r4]         @ stocke le caractère trouvé
    adds r4,1               @ incremente la position
    cmp r2,7                @ puis tous les 8 caractères 
    beq 4f
    cmp r2,15
    beq 4f
    cmp r2,23
    beq 4f
    b 5f
4:
    movs r3,' '             @ ajoute un espace dans la zone de conversion
    strb r3,[r1,r4]
    adds r4,1
5:
    adds r2,1               @ puis bit suivant
    cmp r2,32               @ fin ?
    blt 1b                  @ non -> boucle 
    movs r3,0               @ sinon 0 final
    strb r3,[r1,r4]
    pop {r4,pc}             @ restaur registers
    