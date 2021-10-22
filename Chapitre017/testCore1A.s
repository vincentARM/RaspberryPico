/* Programme assembleur ARM Raspberry pico */
/* Connexion USB OK sans utilisation du SDK */
/* utilise Putty pour connexion série 9600 bauds */
/* utilise les routinesPicoARM et routinesUSBCDC  */
/* Attention encodage du programme en UTF-8 pour éviter pb des accents */
/* ajout des commandes pour afficher nombres Float */
/* Algorithme https://blog.benoitblanchon.fr/lightweight-float-to-string/  */
/* Attention si float inférieur à 1E-37 , la multiplication par 1E32 est fausse !! */
/* commande clk affiche la frequence de l'horloge demandée */
/* commande mes : compte le nombre de cycle en utilisant systick */
/* commande mem : test affichage memoire et macro */
.syntax unified
.cpu cortex-m0plus 
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ ADDRESSEPILE,    0x20042000
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* libellé peut être entre quotes    */
/* attention pas de save du registre d'état */
.macro afficherLib str 
    push {r0-r3}               @ save des registres
    adr r0,libaff1\@           @ recup adresse libellé passé dans str
    bl ecrireMessage
    pop {r0-r3}                @ restaure des registres
    b smacroafficheMess\@      @ pour sauter le stockage de la chaine.
.align 2
libaff1\@:     .asciz "\str\r\n"
.align 2
smacroafficheMess\@:     
.endm                          @ fin de la macro
/****************************************************/
/* macro de vidage memoire                          */
/****************************************************/
/* n'affiche que les adresses ou les registre r0 et r1      */
.macro affmemoire  adr
    push {r0,r1,r2}    @ save registre
    .ifc \adr,r1       @ test si registre r1
    mov r0,r1
    .else
    .ifnc \adr,r0      @ test si pas registre r0
    ldr r0,zon1\@      @ recup de l'adresse demandée
    .endif
    .endif
    push {r0}
    bl afficherMemoire
    add sp,4
    pop {r0,r1,r2}
    b smacro1vidmemtit\@   @ pour sauter le stockage de la chaine.
.ifnc \adr,r0
.ifnc \adr,r1
.align 2
zon1\@:  .int \adr
.endif
.endif
.align 4
smacro1vidmemtit\@:     
.endm   @ fin de la macro
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
vtorData:
    .word ADDRESSEPILE
    .word Principale
    .word loop
    .word loop
    .word loop

    .word loop
    .word loop
    .word loop
    .word loop
    .word loop

    .word loop
    .word loop
    .word loop
    .word loop
    .word loop

    .word loop
    .word loop
    .word loop
    .word loop
    .word loop
    
    .word loop
    .word loop
    .word loop
    .fill 80,1,0

szMessDebPgm:       .asciz "Début du programme.\r\n"
szMessFinPgm:       .asciz "Fin du programme.\r\n"
szRetourLigne:      .asciz "\r\n"
szMessCommande:     .asciz "Tapez une commande : \r\n"
szLibCmdAide:       .asciz "aide"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdCore:       .asciz "core"
szLibCmdBin:       .asciz "bin"
szLibCmdMes:       .asciz "mes"

szMessAide:        .asciz "Liste des commandes disponibles : \r\n"
szMessAideListe:   .asciz "aide\r\nfin\r\ncore\r\nfct\r\nbin\r\nmes\r\n"

szMessTest:        .asciz "Message envoi par core1\r\n"

/*******************************************/
/* DONNEES NON INITIALISEES                */
/*******************************************/ 
/* ATTENTION : la BSS n'est pas initialisée */
.bss
.align 4
sZoneConv:          .skip 24
sBuffer:            .skip 80 
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global Principale
.thumb_func
Principale:                     @ INFO: Principale
    mov r6,sp
    ldr r1,iAdrStack
    mov sp,r1                   @ init adresse de la pile
    //msr msp, r1               @ TODO: voir son utilité

    bl initDebut
    bl initHorloges
    bl initLed25

    bl initUsbDevice          @ init de la connexion USB

    bl initCore1              @ init du core 1 

    ldr r2,iAdriHostOK        @ host est connecté ?
1:                            @ boucle d'attente
    movs r0,10
    bl attendre 
    ldr r0,[r2]
    cmp r0,1
    bne 1b                     @ non -> boucle
    
    
    movs r0,2                 @ pour verifier init et connexion
    bl ledEclats 

    ldr r0,iAdrszMessDebPgm    @  message début 
    bl ecrireMessage
    
    afficherLib VerifAdressePile
    push {r6}
    bl affRegHexa
    add sp,4

2:                            @ debut de boucle de reception des commandes
    ldr r0,iAdrszMessCommande
    bl ecrireMessage
    ldr r0,iAdrsBuffer
    bl recevoirMessage
    
                               @ analyser réponse
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAide
    bl comparerChaines
    cmp r0, 0
    bne 3f
    ldr r0,iAdrszMessAide        @ affichage des commandes disponibles
    bl ecrireMessage
    ldr r0,iAdrszMessAideListe
    bl ecrireMessage
    b 10f                        @ suite boucle

3:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFin
    bl comparerChaines
    cmp r0, 0
    bne 4f
    ldr r0,iAdrszMessFinPgm      @ message de fin
    bl ecrireMessage
    movs r0,'U'                   @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
    b loop                        @ fin du programme
    
4:          
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct        @ pour test de fonction particulière
    bl comparerChaines
    cmp r0, 0
    bne 5f
    // ajouter la fonction a tester
    b 10f                        @ suite boucle
    
5:  
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdBin        @ affichage registre memoire en binaire
    bl comparerChaines
    cmp r0, 0
    bne 6f
    bl affRegBin
    b 10f                         @ suite boucle

6:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdCore        @ envoi message par core1
    bl comparerChaines
    cmp r0, 0
    bne 7f
    afficherLib "test Core 1"
    bl debutSystick                @ debut du comptage
    ldr r0,iAdrszMessTest
    bl ecrireMessage
    bl stopSystick
    b 10f                         @ suite boucle

7:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdMes        @ mesure de cycles
    bl comparerChaines
    cmp r0, 0
    bne 8f
    bl mesurerCycles
    b 10f                         @ suite boucle

8:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdMem        @ affichage mémoire
    bl comparerChaines
    cmp r0, 0
    bne 9f
    ldr r0,iAdriHostOK
    push {r0}
    bl afficherMemoire            @ test de la routine
    add sp,#4 
    ldr r0,iAdrszLibCmdAide       @ test de la macro
    affmemoire r0 
    b 10f                         @ suite boucle

9:
    afficherLib "Commande inconnue! tapez aide"

10:
    b 2b                          @ boucle commande


.thumb_func
loop:                             @ boucle pour fin de programme standard  
    b loop
 
/************************************/
.align 2
iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrStack:              .int ADDRESSEPILE
iAdriHostOK:            .int iHostOK
iAdrsBuffer:            .int sBuffer
iAdrszMessCommande:     .int szMessCommande
iAdrszLibCmdAide:       .int szLibCmdAide
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszLibCmdBin:        .int szLibCmdBin
iAdrszLibCmdCore:        .int szLibCmdCore
iAdrszLibCmdMes:        .int szLibCmdMes
iAdrszLibCmdMem:        .int szLibCmdMem
iAdrszMessAide:         .int szMessAide
iAdrszMessAideListe:    .int szMessAideListe
iAdrszMessTest:         .int szMessTest
/******************************************************************/
/*     initialisation                                             */ 
/******************************************************************/
.thumb_func
initDebut:                       @ INFO: initDebut
    ldr r1,iAdrDebRomData
    ldr r2,iAdrDebRamData
    ldr r3,iAdrDebRamBss
1:                              @ boucle de copie de la data en rom
    ldm r1!, {r0}               @ vers la data en ram
    stm r2!, {r0}
    cmp r2, r3
    blo 1b
                                @ TODO: il faudrait aussi initialiser la .bss
    
    ldr r1,iAdrVtor             @ init table des vecteurs VTOR
    ldr r0,iAdrVector
    str r0,[r1]
    
    ldr r1,iparReset
    mvns r1,r1   
    ldr r0,iAdrResetBaseClr      @ reset général sauf 2 sous systèmes  (LES PLL sont inits)
    ldr r2,iAdrResetBaseSet
    str r1,[r2,RESET_RESET]
    str r1,[r0,RESET_RESET]
    ldr r2,iAdrResetBase
1:
    ldr r3,[r2,#RESET_DONE]      @ boucle attente reset ok
    tst r3,r1
    beq 1b

    bx lr
.align 2
iAdrResetBase:            .int RESETS_BASE
iAdrResetBaseSet:         .int RESETS_BASE + 0x2000
iAdrResetBaseClr:         .int RESETS_BASE + 0x3000
iparReset:                .int (RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS)
iAdrVtor:                 .int PPB_BASE + PPB_VTOR
iAdrVector:               .int vtorData
iAdrDebRomData:           .int _debutRomData
iAdrDebRamData:           .int _debutRamData
iAdrDebRamBss:            .int _debutRamBss


/******************************************************************/
/*     mesure de cycles                                            */ 
/******************************************************************/
.thumb_func
mesurerCycles:                       @ INFO: mesurerCycles
    push {r1-r4,lr}
    afficherLib "Comptage cycles à vide  "
    bl debutSystick          @ debut du comptage
    bl stopSystick            @ 4 cycles
    afficherLib "Comptage cycles instructions "
    bl debutSystick          @ debut du comptage
    movs r0,2
    movs r2,5
    muls r0,r2
    bl stopSystick            @ 4 cycles
100:
    pop {r1-r4,pc}
.align 2


