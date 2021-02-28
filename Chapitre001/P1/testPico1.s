/* Programme assembleur ARM Raspberry pico */
/*  */
/* création routine en assembleur pour appel par programme C  */
/* test instructions thumb */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data

.align 4

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.thumb
.global routine1
.thumb_func
routine1:                       @ routine
    push {r1,lr}                @ save des  registres 
    movs r1,#5
    lsls r0,r1,#2 
100:                            @ fin de routine
    pop {r1,pc}                 @ restaur des  registres 

/************************************/



