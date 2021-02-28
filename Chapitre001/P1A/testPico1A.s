/* Programme assembleur ARM Raspberry pico */
/*  */
/* Clignotement de la led  */
/* appel des routines de la librairie */ 
/* ATTENTION : erreurs de compilation lire le texte */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ LED_PIN, 25
.equ GPIO_OUT, 1
.equ GPIO_IN,  0
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
.global main
.thumb_func
main:                           @ Programme principal
    push {r1,lr}                @ save des  registres 
    movs r0,#LED_PIN
    bl gpio_init
    movs r0,#LED_PIN
    movs r1,#GPIO_OUT
    bl gpio_set_dir
1:
    
    movs r0,#LED_PIN
    movs r1,#1
    bl gpio_put
    movs r0, #250
    bl sleep_ms 
    movs r0,#LED_PIN
    movs r1,#0
    bl gpio_put
    movs r0, #250
    bl sleep_ms 
    b 1b
100:                            @ fin de programme standard  
    pop {r1,pc}                 @ restaur des  registres 

/************************************/



