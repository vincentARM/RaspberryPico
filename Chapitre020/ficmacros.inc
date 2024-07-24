/* macros pour Pico */

/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
/* attention pas de save du registre d'état */
.macro afficherLib str 
    push {r0-r3}               @ save des registres
    adr r0,libaff1\@           @ recup adresse libellé passé dans str
    bl      __wrap_puts
    pop {r0-r3}                @ restaure des registres
    b smacroafficheMess\@      @ pour sauter le stockage de la chaine.
.align 4
libaff1\@:     .asciz "\str\r\n"
.align 4
smacroafficheMess\@:     
.endm                          @ fin de la macro
/****************************************************/
/* macro d'affichage de zones mémoire                   */
/****************************************************/
/* pas d'espace dans le libellé     */
/* attention pas de save du registre d'état */
.macro affmemtit str adr bloc
    push {r0-r2}               @ save des registres
    adr r2,libaffM1\@           @ recup adresse libellé passé dans str
    .ifc \adr,r1
    movs r0,r1
    .else
    .ifnc \adr,r0
    ldr r0,zon1\@
    .endif
    .endif
    movs r1,#\bloc
    bl afficherMemoire
    pop {r0-r2}                @ restaure des registres
    b smacroaffmem\@      @ pour sauter le stockage de la chaine.
.align 2
libaffM1\@:     .asciz "\str"
.align 2
smacroaffmem\@:     
.endm                          @ fin de la macro
/* macro d'enrobage du vidage des registres  avec étiquette */
.macro affregtit str 
    push {r0}             @ save r0
    mrs r0,apsr           @ save du registre d'état  dans r0
    push {r0}
    adr r0,lib1\@         @ utilisation de adr suite pb gros programme
    push {r0}             @ passage argument sur la pile
    ldr r0,[sp,#8]        @ on remet en etat r0 pour l'afficher correctement
    bl affregistres        @ affichage des registres
    add sp,#4              @ pour liberer la pile du push 1 argument
    pop {r0}
    msr PSR_nzcvq,r0            @ restaur registre d'état
    pop {r0}              @ on restaure R0 pour avoir une pile réalignée
    b smacro1vidregtit\@   @ pour sauter le stockage de la chaine. 
.align 2    
lib1\@:  .asciz "\str"
.align 2
smacro1vidregtit\@:     
.endm   @ fin de la macro
