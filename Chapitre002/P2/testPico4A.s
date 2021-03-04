/* Programme assembleur ARM Raspberry pico */
/*  */
/* Attente connexion terminal Affichage d'un registre  */
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebutPgm:     .asciz "Début du programme."
szMessAffReg:       .ascii "Valeur du registre : "
sZoneRes:           .space ' ',9
                    .asciz " "
.align 4

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:    .skip 500 

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:
    bl stdio_init_all          @ initialisation générale
1:                             @ boucle d'attente de connection
    mov r0,#0
    bl tud_cdc_n_connected     @ terminal connecté ?
    cmp r0,#0
    bne 2f                     @ oui
    mov r0,#100                @ sinon attente et boucle
    bl attendre 
    b 1b
2:  
    ldr r0,iAdrszMessDebutPgm
    bl __wrap_puts
    mov r0,sp                   @ pour affichage adresse pile début programme
    push {r0}
    bl affRegHexa               @ affichage registre 
    add sp,#4                   @ alignement pile

100:                            @ fin de programme standard  
    b 100b

/************************************/
.align 2
iAdrszMessDebutPgm:      .int szMessDebutPgm
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
    
