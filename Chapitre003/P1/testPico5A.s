/* Programme assembleur ARM Raspberry pico */
/*  */
/* boucle de commandes  affichage d'un registre mémoire  */
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
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessAffReg:      .ascii "Valeur du registre : "
sZoneRes:          .ascii "         "
                   .asciz " "
szMessCmd:         .asciz "Entrez une commande :"
szLibCmdAff:       .asciz "aff"
szLibCmdLed:       .asciz "led"

szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:"
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
main:
    bl stdio_init_all
1:                             @ début boucle attente connexion 
    mov r0,#0
    bl tud_cdc_n_connected     @ terminal connecté ?
    cmp r0,#0
    bne 2f                     @ oui
    mov r0,#100                @ sinon attente et boucle
    bl attendre
    b 1b
2:  
    mov r0,sp                   @ pour affichage adresse pile début programme
    push {r0}
    bl affRegHexa               @ affichage registre 
    add sp,#4                   @ alignement pile
3:                              @ boucle de lecture traitement des commandes
    mov r0,#200
    //lsl r0,#2
    //bl attendre
    ldr r0,iAdrszMessCmd
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine

    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAff
    bl comparerChaines
    cmp r0,#0
    bne 4f
    mov r0,sp
    bl cmdAffReg
4:
    b 3b                       @ boucle commande
    
100:                            @ boucle pour fin de programme standard  
    b 100b

.align 2
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdAff:        .int szLibCmdAff
/******************************************************************/
/*     lire une commande                                          */ 
/******************************************************************/
/* r0 contient l'adresse du buffer                   */
.thumb_func
lireChaine:
    push {r4-r6,lr}
    mov r5,r0          @ save adresse du buffer
    mov r6,#0          @ nombre de caractères
    ldr r4,iValErreur
1:                     @ lire un caractère
    mov r0,#100
    bl getchar_timeout_us
    cmp r0,r4          @ boucle si pas de saisie
    beq 1b
    cmp r0,#0          @ fin ?
    beq 2f
    cmp r0,#0xD        @ retour ligne ?
    beq 2f
    strb r0,[r5,r6]    @ stockage dans buffer
    add r6,#1          @ incremente nombre de caractère
    bl putchar         @ affichage caractère saisi
    b 1b               @ et boucle
2:
    mov r0,#0          @ fin de saisie 0 -> dans buffer
    strb r0,[r5,r6]
    mov r0,#0xA        @ et passage ligne suivante
    bl putchar
    mov r0,#0xD
    bl putchar
    mov r0,r6          @ retour nombre de caractères saisis
    pop {r4-r6,pc}
.align 2
iValErreur:             .int PICO_ERROR_TIMEOUT
/******************************************************************/
/*     affichage du registre passé par push                       */ 
/******************************************************************/
/* test commande aff */
.thumb_func
cmdAffReg:
    push {lr}
    ldr r0,iAdrszMessSaisieReg  @ affichage message
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine               @ saisie de l'adresse du registre
    ldr r0,iAdrsBuffer          @ mais c est une chaine
    bl convertirChHexa          @ qu'il faut convertir en valeur hexa
    bcs 100f                    @ erreur ?
    push {r0}                   @ affichage de la valeur convertie pour vérification
    bl affRegHexa
    add sp,#4
    ldr r1,[r0]                 @ puis chargement de la valeur du registre mémoire
    push {r1}                   @ et affichage en hexa
    bl affRegHexa
    add sp,#4
100:
    pop {pc}
.align 2
iAdrszMessSaisieReg:      .int szMessSaisieReg
iAdrsBuffer:              .int sBuffer
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
    mov r2,#0             @ indice
1:
    ldrb r3,[r0,r2]       @ octet chaine 1
    ldrb r4,[r1,r2]       @ octet chaine 2
    cmp r3,r4
    blt 2f
    bgt 3f
    cmp r3,#0             @ 0 final
    beq 4f                @ c est la fin
    add r2,r2,#1          @ sinon plus 1 dans indice
    b 1b                  @ et boucle
2:
    mov r0,#0             @ plus petite
    sub r0,#1             @ -1
    b 100f
3:
    mov r0,#1             @ plus grande
    b 100f
4:
    mov r0,#0             @ égale
100:
    pop {r2-r4,pc}
/******************************************************************/
/*     affichage du registre passé par push                       */ 
/******************************************************************/
/* r0 contient l adresse du message */
/* Attention après l'appel aligner la pile */
.thumb_func
affRegHexa:
    push {r0-r4,lr}         @ save des registres
    mov r0,sp               @ adresse pile
    ldr r0,[r0,#24]         @ récup paramètre passé par push
    ldr r1,iAdrsZoneRes     @ adresse de la zone résultat
    mov r2,#28              @ position de départ
    mov r4,#0xF             @ masque
    lsl r4,#28              @ masque le plus à gauche
    mov r3,r0               @ save valeur
1:                          @ début boucle
    mov r0,r3
    and r0,r0,r4            @ valeur registre et masque
    lsr r0,r2               @ déplacement à droite
    cmp r0,#10              @ chiffre ?
    bge 2f
    add r0,#48              @ <10  -> chiffre
    b 3f    
2:    
    add r0,#55              @ >10  ->lettre A-F
3:
    strb r0,[r1]            @ stocke le chiffre dans la zone resultat
    add r1,#1               @ position suivante
    lsr r4,#4               @ deplacement du masque de 4 positions à droite
    sub r2,r2,#4            @ compteur bits - 4 <= zero  ?
    cmp r2,#0
    bge 1b                  @ non -> boucle
    ldr r0,iAdrszMessAffReg @ affichage du message résultat
    bl __wrap_puts
    pop {r0-r4,pc}          @ restaur des registres
.align 2
iAdrsZoneRes:     .int sZoneRes
iAdrszMessAffReg: .int szMessAffReg
/***************************************************/
/*     conversion chaine hexa en                   */
/***************************************************/
// r0 : adresse de la chaine
// r0 : returne la valeur
// carry on si erreur
convertirChHexa:                @ TODO: convertirChHexa
    push {r4,lr}                @ save  registres 
    movs r2,#0                  @ indice
    movs r3,#0                  @ valeur
    movs r1,#0                  @ nombre de chiffres
1:
    ldrb r4,[r0,r2]
    cmp r4,#0                   @ fin de chaine
    beq 10f
    sub r4,r4,#0x30             @ conversion chiffres
    blt 5f
    cmp r4,#10
    blt 3f                      @ chiffres 0 à 9 OK
    cmp r4,#17                  @ < A ?
    blt 5f
    cmp r4,#22
    bgt 2f
    sub r4,r4,#7                @ lettres A-F
    b 3f
2:
    cmp r4,#49                  @ < a ?
    blt 5f
    cmp r4,#54                  @ > f ?
    bgt 5f
    sub r4,r4,#39               @ lettres  a-f
3:                              @ r4 contient la valeur sur 4 bits
    add r1,#1
    cmp r1,#8
    bgt 9f                      @ plus de 8 chiffres -> erreur
    lsl r3,#4
    eor r3,r4
5:                              @ boucle sur autre chiffre
    add r2,r2,#1
    b 1b
9:
    adr r0,szMessErreurConv
    bl __wrap_puts
    mov r0,#0
    cmp r0,r0               @ positionne carry à 1
    b 100f
10:
    mov r0,r3
    cmn r2,r2               @ TODO: positionne carry à 0
                            @  teste r2 car non efficace pour nombre négatif 
                            @ or r0 peut contenir une adresse au délà de 0x7000000
100: 
    pop {r4,pc}             @ restaur registres
.align 2
szMessErreurConv:    .asciz "Trop de chiffres hexa !!"
.align 2
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:
    lsl r0,#16             @ approximatif TODO: à verifier avec le timer
1:
    sub r0,r0,#1
    bgt 1b
    bx lr
