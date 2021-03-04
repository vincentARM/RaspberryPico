/* Programme assembleur ARM Raspberry pico */
/*  */
/* affichage d'un message sur le port USB  */

.syntax unified             @ non obligatoire
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebutPgm:      .asciz "Début du programme. \n"

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
    push {r1,lr}                @ save des  registres 
    bl stdio_init_all           @ initialisation
1:
    
    ldr r0,iAdrszMessDebutPgm   @ adresse du message 
    bl __wrap_puts              @ appel routine librairie
    movs r0, #250                @ attente 
    lsls r0,r0,#2                @ multipliée par 4 
    bl attendre
 
    b 1b
.thumb_func
100:                            @ fin de programme standard  
    pop {r1,pc}                 @ restaur des  registres 
.align 2
iAdrszMessDebutPgm:        .int szMessDebutPgm
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:
    lsls r0,#16             @ approximatif TODO: à verifier avec le timer
1:
    subs r0,r0,#1
    bgt 1b
    bx lr
