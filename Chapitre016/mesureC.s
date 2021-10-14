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
.syntax unified
.cpu cortex-m0plus 
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ ADDRESSEPILE,    0x20042000
.equ GPIO_25_CTRL,    IO_BANK0_BASE + 8 * 25 + 4
.equ GPIO_16_CTRL,    IO_BANK0_BASE + 8 * 16 + 4
.equ GPIO_16_STATUS,  IO_BANK0_BASE + 8 * 16

.equ CLOCKS_BASE,    0x40008000
.equ FC0_REF_KHZ,    0x80
.equ FC0_MIN_KHZ,    0x84
.equ FC0_MAX_KHZ,    0x88
.equ FC0_DELAY,      0x8C
.equ FC0_INTERVAL,   0x90
.equ FC0_SRC,        0x94
.equ FC0_STATUS,     0x98
.equ FC0_RESULT,     0x9c

.equ CLOCKS_FC0_STATUS_RUNNING_BITS,   0x00000100
.equ CLOCKS_FC0_STATUS_DONE_BITS,      0x00000010
.equ CLOCKS_FC0_RESULT_KHZ_LSB,        5

.equ TIMER_BASE,     0x40054000
.equ WATCHDOG_BASE,  0x40058000
.equ TIMELR,    0xC
.equ TIMEHR,    0x8
.equ PPB_BASE,       0xE0000000
.equ SYST_CSR,       0xE010        // systick
.equ SYST_RVR,       0xE014
.equ SYST_CVR,       0xE018
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
/* attention pas de save du registre d'état */
.macro afficherLib str 
    push {r0-r3}               @ save des registres
    adr r0,libaff1\@           @ recup adresse libellé passé dans str
    bl envoyerMessage
    pop {r0-r3}                @ restaure des registres
    b smacroafficheMess\@      @ pour sauter le stockage de la chaine.
.align 2
libaff1\@:     .asciz "\str\r\n"
.align 2
smacroafficheMess\@:     
.endm                          @ fin de la macro


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
szLibCmdClk:       .asciz "clk"
szLibCmdBin:       .asciz "bin"
szLibCmdMes:       .asciz "mes"
szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:\r\n"

szMessAide:        .asciz "Liste des commandes disponibles : \r\n"
szMessAideListe:   .asciz "aide\r\nfin\r\nclk\r\nfct\r\nbin\r\nmes\r\n"

szMessChrono:     .ascii "Temps en µs = "
sZoneDec:         .asciz "             \r\n"

szMessSystick:     .ascii "Nombre de cycles = "
sZoneDecSys:       .asciz "             \r\n"
.align 4

/*******************************************/
/* DONNEES NON INITIALISEES                */
/*******************************************/ 
/* ATTENTION : la BSS n'est pas initialisée */
.bss
.align 4
dwDebut:            .skip 8               @ zones début temps timer
dwFin:              .skip 8               @ zones fin temps timer
iValDepSys:         .skip 4
sZoneConv:          .skip 24
sBuffer:            .skip 80 
sZoneConvFloat:     .skip 80
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
    bl initGpio

    bl initUsbDevice          @ init de la connexion USB
    

    ldr r2,iAdriHostOK        @ host est connecté ?
1:                            @ boucle d'attente
    movs r0,10
    bl attendre 
    ldr r0,[r2]
    cmp r0,1
    bne 1b                     @ non -> boucle
    
    movs r0,2                 @ pour verifier init et connexion
    bl ledEclats

    ldr r0,iAdrszMessDebPgm    @  message
    bl envoyerMessage
    
    afficherLib VerifAdressePile
    push {r6}
    bl affRegHexa
    add sp,4

2:
    ldr r0,iAdrszMessCommande
    bl envoyerMessage
    ldr r0,iAdrsBuffer
    bl recevoirMessage
    
                               @ analyser réponse
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdAide
    bl comparerChaines
    cmp r0, 0
    bne 3f
    ldr r0,iAdrszMessAide        @ affichage des commandes disponibles
    bl envoyerMessage
    ldr r0,iAdrszMessAideListe
    bl envoyerMessage
    b 10f                        @ suite boucle

3:
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFin
    bl comparerChaines
    cmp r0, 0
    bne 4f
    ldr r0,iAdrszMessFinPgm      @ message de fin
    bl envoyerMessage
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
    bl testerFloat
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
    ldr r1,iAdrszLibCmdClk        @ affichage frequence horloge
    bl comparerChaines
    cmp r0, 0
    bne 7f
    afficherLib "Numéro horloge (en hexa de 0 à 0d) ? :"
    ldr r0,iAdrsBuffer
    bl recevoirMessage           @ attend le N°
    ldr r0,iAdrsBuffer
    bl convertirChHexa           @ le convertit en valeur dans r0
    bl calculerFrequence
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
iAdrszLibCmdClk:        .int szLibCmdClk
iAdrszLibCmdMes:        .int szLibCmdMes
iAdrszMessAide:         .int szMessAide
iAdrszMessAideListe:    .int szMessAideListe

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
/************************************/
/*       init gpio               */
/***********************************/
.thumb_func
initGpio:
    ldr  r1,iAdrGPIO25          @ init fonction sio
    movs r0,GPIO_FUNC_SIO
    str  r0, [r1]

    ldr  r1,iAdrSioBase
    movs  r0,1
    lsls  r0,25                 @ GPIO pin 25 
    str  r0, [r1, GPIO_OE_SET]  @ output
    bx lr
.align 2
iAdrGPIO25:     .int GPIO_25_CTRL

/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.global ledEclats
.thumb_func
ledEclats:                      @ INFO: ledEclats
    push {r1-r4,lr}
    movs r4,r0
    movs  r2,1
    lsls  r2,25                 @ GPIO pin 25
    ldr r3,iAdrSioBase
1:
    str r2,[r3,GPIO_OUT_XOR]   @ allumage led
    movs r0, #250
    bl attendre
    str r2,[r3,GPIO_OUT_XOR]   @ extinction led
    movs r0, #250
    bl attendre 
    subs r4,1                  @ décremente nombre eclats
    bgt 1b                     @ et boucle 
    
    pop {r1-r4,pc}
.align 2
iAdrSioBase:    .int SIO_BASE
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
/******************************************************************/
/*     mesure de cycles                                            */ 
/******************************************************************/
.thumb_func
mesurerCycles:                       @ INFO: mesurerCycles
    push {r1-r4,lr}
       afficherLib "Comptage cycles à vide  "
    bl debutSystick          @ debut du comptage
    bl finSystick            @ 4 cycles
    afficherLib "Comptage cycles instructions "
    bl debutSystick          @ debut du comptage
    movs r0,2
    movs r2,5
    muls r0,r2
    bl finSystick            @ 4 cycles
100:
    pop {r1-r4,pc}
.align 2
/******************************************************************/
/*     test Conversion Float                                            */ 
/******************************************************************/
.thumb_func
testerFloat:                       @ INFO: testerFloat
    push {r1-r4,lr}

    afficherLib "Mesure temps conversion float"
    bl debutChrono
    ldr r0,fValPlusGrande
    bl tester1Float
    bl stopChrono
    afficherLib "Mesure cycles conversion float"
    bl debutSystick
    ldr r0,fValPlusGrande
    bl tester1Float
    bl finSystick
100:
    pop {r1-r4,pc}
.align 2
fValPlusPetite:     .float 1E-37
fValPlusGrande:     .float 3.4E38
fValPlusGrandeN:    .float -3.4E38
fValNormale:        .float 123456.7
/******************************************************************/
/*     tester 1 cas Conversion Float                              */ 
/******************************************************************/
/* r0 contient la valeur du float */
.thumb_func
tester1Float:                    @ INFO: tester1Float
    push {r0,r1,lr}
    ldr r1,iAdrsZoneConvFloat    @ adresse zone de reception
    bl convertirFloat
    push {r0}                    @ pour afficher la longueur retournée
    bl affRegHexa
    add sp,4
    ldr r0,iAdrsZoneConvFloat    @ affichage du résultat de la conversion
    bl envoyerMessage
    ldr r0,iAdrszRetourLigne     @ et retour ligne
    bl envoyerMessage

100:
    pop {r0,r1,pc}
.align 2
iAdrszRetourLigne:    .int szRetourLigne
/******************************************************************/
/*     Conversion Float                                            */ 
/******************************************************************/
/* r0  contient la valeur du Float */
/* r1 contient l'adresse de la zone de conversion  mini 20 caractères*/
/* r0 retourne la longueur utile de la zone */
.thumb_func
convertirFloat:               @ INFO: convertirFloat
    push {r1-r7,lr}
    mov r6,r8
    mov r7,r9
    push {r6,r7}              @ pour sauver les registres r8 et r9 
    mov r6,r1                 @ save adresse de la zone
    movs r7,#0                @ nombre de caractères écrits
    movs r3,'+'
    strb r3,[r6]              @ forçage du signe +
    mov r2,r0
    lsls r2,1                 @ extraction 31 bit
    bcc 1f                    @ positif ?
    lsrs r0,r2,1              @ suppression du signe si negatif
    movs r3,'-'               @ et signe -
    strb r3,[r6]
1:
    adds r7,1                 @ position suivante
    cmp r0,0                  @ cas du 0 positif ou negatif
    bne 2f
    movs r3,'0'
    strb r3,[r6,r7]           @ stocke le caractère 0
    adds r7,1
    movs r3,0
    strb r3,[r6,r7]           @ stocke le 0 final
    mov r0,r7                 @ retourne la longueur
    b 100f
2: 
    ldr r2,iMaskExposant
    mov r1,r0
    ands r1,r2                @ exposant à 255 ?
    cmp r1,r2
    bne 4f
    lsls r0,10                @ bit 22 à 0 ?
    bcc 3f                    @ oui 
    movs r2,'N'               @ cas du Nan. stk byte car pas possible de stocker un int 
    strb r2,[r6]              @ car zone non alignée
    movs r2,'a'
    strb r2,[r6,1] 
    movs r2,'n'
    strb r2,[r6,2] 
    movs r2,0                  @ 0 final
    strb r2,[r6,3] 
    movs r0,3
    b 100f
3:                             @ cas infini positif ou négatif
    movs r2,'I'
    strb r2,[r6,r7] 
    adds r7,1
    movs r2,'n'
    strb r2,[r6,r7] 
    adds r7,1
    movs r2,'f'
    strb r2,[r6,r7] 
    adds r7,1
    movs r2,0
    strb r2,[r6,r7]
    mov r0,r7
    b 100f
4:
    mov r4,r0                @ save float
    movs r0,'S'
    movs r1,'F'
    bl appelDatasRom         @ recherche début float fonctions
    mov r5,r0                @ adresse début fonctions

    mov r0,r4
    mov r1,r5                @ fonction
    bl normaliserFloat
    mov r8,r1                @ exposant
    mov r4,r0                @ save nouvelle valeur
    ldr r3,[r5,0x24]         @ fonction conversion en entier non signé
    blx r3
    mov r9,r0                @ valeur entière
    ldr r3,[r5,0x34]         @ fonction conversion en float
    blx r3
    mov r1,r0
    mov r0,r4
    ldr r3,[r5,0x4]          @ fonction soustraction
    blx r3
    ldr r1,iConst1
    ldr r3,[r5,0x8]          @ fonction multiplication
    blx r3
    ldr r3,[r5,0x24]         @ fonction conversion en entier non signé
    blx r3
    mov r4,r0                @ valeur fractionnaire

    mov r0,r9                @ conversion partie entière
    mov r2,r6                @ save adresse début zone 
    adds r6,r7
    mov r1,r6
    bl conversion10
    add r6,r0
    movs r3,','
    strb r3,[r6]
    adds r6,1
 
    mov r0,r4                @ conversion partie fractionnaire
    mov r1,r6
    bl conversion10
    add r6,r0
    subs r6,1
                             @ il faut supprimer les zéros finaux
5:
    ldrb r0,[r6]
    cmp r0,'0'
    bne 6f
    subs r6,1
    b 5b
6:
    cmp r0,','
    bne 7f
    subs r6,1
7:
    adds r6,1
    movs r3,'E'
    strb r3,[r6]
    adds r6,1
    mov r0,r8                  @ conversion exposant
    mov r3,r0
    lsls r3,1
    bcc 4f
    rsbs r0,r0,0
    movs r3,'-'
    strb r3,[r6]
    adds r6,1
4:
    mov r1,r6
    bl conversion10
    add r6,r0
    
    movs r3,0
    strb r3,[r6]
    adds r6,1
    mov r0,r6
    subs r0,r2                 @ retour de la longueur de la zone
    subs r0,1                  @ sans le 0 final

100:
    pop {r6,r7}
    mov r8,r6
    mov r9,r7
    pop {r1-r7,pc}
.align 2
iAdrsZoneConvFloat:       .int sZoneConvFloat
iMaskExposant:            .int 0xFF<<23
iConst1:                  .float 0f1E9

/***************************************************/
/*   normaliser float                              */
/***************************************************/
/* r0 contient la valeur du float (valeur toujours positive et <> Nan) */
/* r1 contient l'adresse des fonctions ROM */
/* r0 retourne la nouvelle valeur */
/* r1 retourne l'exposant */
normaliserFloat:            @ INFO: normaliserFloat
    push {r2-r6,lr}         @ save des registres
    mov r6,r0               @ valeur de départ
    mov r5,r1
    movs r4,0               @ exposant
    ldr r1,iConstE7         @ pas de normalisation pour les valeurs < 1E7
    cmp r6,r1               @ comparaison binaire ok pour les floats positifs 
    blo 10f                 @ si r0 est < iConstE7
    
    ldr r1,iConstE32
    cmp r6,r1
    blo 1f
    mov r0,r6
    ldr r1,iConstE32
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,32
1:
    ldr r1,iConstE16
    cmp r6,r1
    blo 2f
    mov r0,r6
    ldr r1,iConstE16
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,16
2:
    ldr r1,iConstE8
    cmp r6,r1
    blo 3f
    mov r0,r6
    ldr r1,iConstE8
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,8
3:
    ldr r1,iConstE4
    cmp r6,r1
    blo 4f
    mov r0,r6
    ldr r1,iConstE4
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,4
4:
    ldr r1,iConstE2
    cmp r6,r1
    blo 5f
    mov r0,r6
    ldr r1,iConstE2
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,2
5:
    ldr r1,iConstE1
    cmp r6,r1
    blo 10f
    mov r0,r6
    ldr r1,iConstE1
    ldr r3,[r5,0xC]         @ fonction division
    blx r3
    mov r6,r0
    adds r4,1

10:
    ldr r1,iConstME5        @ pas de normalisation pour les valeurs > 1E-5
    cmp r6,r1
    bhi 20f
    ldr r1,iConstME31
    cmp r6,r1
    bhi 11f
    mov r0,r6
    ldr r1,iConstE32
    ldr r3,[r5,0x8]         @ ATTENTION opération fausse si r0 < 1E-37   Résultat 0 
    blx r3
    mov r6,r0
    subs r4,32
11:
    ldr r1,iConstME15
    cmp r6,r1
    bhi 12f
    mov r0,r6
    ldr r1,iConstE16
    ldr r3,[r5,0x8]         @ fonction multiplication
    blx r3
    mov r6,r0
    subs r4,16
12:
    ldr r1,iConstME7
    cmp r6,r1
    bhi 13f
    mov r0,r6
    ldr r1,iConstE8
    ldr r3,[r5,0x8]         @ fonction multiplication
    blx r3
    mov r6,r0
    subs r4,8
13:
    ldr r1,iConstME3
    cmp r6,r1
    bhi 14f
    mov r0,r6
    ldr r1,iConstE4
    ldr r3,[r5,0x8]         @ fonction multiplication
    blx r3
    mov r6,r0
    subs r4,4
14:
    ldr r1,iConstME1
    cmp r6,r1
    bhi 15f
    mov r0,r6
    ldr r1,iConstE2
    ldr r3,[r5,0x8]         @ fonction multiplication
    blx r3
    mov r6,r0
    subs r4,2
15:
    ldr r1,iConstE0
    cmp r6,r1
    bgt 20f
    mov r0,r6
    ldr r1,iConstE1
    ldr r3,[r5,0x8]         @ fonction multiplication
    blx r3
    mov r6,r0
    subs r4,1

20:
    mov r0,r6              @ nouvelle valeur
    mov r1,r4              @ retourne l'exposant
100:                       @ fin standard de la fonction
    pop {r2-r6,pc}         @ restaur des registres
.align 2
iConstE7:             .float 0f1E7
iConstE32:            .float 0f1E32
iConstE16:            .float 0f1E16
iConstE8:             .float 0f1E8
iConstE4:             .float 0f1E4
iConstE2:             .float 0f1E2
iConstE1:             .float 0f1E1
iConstME5:            .float 0f1E-5
iConstME31:           .float 0f1E-31
iConstME15:           .float 0f1E-15
iConstME7:            .float 0f1E-7
iConstME3:            .float 0f1E-3
iConstME1:            .float 0f1E-1
iConstE0:             .float 0f1E0
/******************************************************************/
/*     Calcul frequence                                             */ 
/******************************************************************/
/* r0  N° horloge */
/*
CLOCKS_FC0_SRC_VALUE_PLL_SYS_CLKSRC_PRIMARY 0x01
CLOCKS_FC0_SRC_VALUE_PLL_USB_CLKSRC_PRIMARY 0x02
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC            0x03
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC_PH         0x04
CLOCKS_FC0_SRC_VALUE_XOSC_CLKSRC            0x05
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN0           0x06
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN1           0x07
CLOCKS_FC0_SRC_VALUE_CLK_REF                0x08
CLOCKS_FC0_SRC_VALUE_CLK_SYS                0x09
CLOCKS_FC0_SRC_VALUE_CLK_PERI               0x0a
CLOCKS_FC0_SRC_VALUE_CLK_USB                0x0b
CLOCKS_FC0_SRC_VALUE_CLK_ADC                0x0c
CLOCKS_FC0_SRC_VALUE_CLK_RTC                0x0d
*/
.thumb_func
calculerFrequence:              @ INFO: calculerFrequence
    push {r1-r4,lr}
    ldr r1,iAdrClockStatus
    ldr r3,iBitsRun
1:                              @ boucle attente mesure
    ldr r2,[r1]
    ands r2,r3
    bne 1b

    ldr r1,iAdrClockRefKLZ
    ldr r2,iFresRef            @ frequence du XOSC 12000 KHz
    str r2,[r1]
    ldr r1,iAdrClockInter
    movs r2,10                 @ intervalle
    str r2,[r1]
    ldr r1,iAdrClockMin
    movs r2,0                  @ minimum
    str r2,[r1]
    ldr r1,iAdrClockMax
    movs r2,0
    subs r2,1                  @ maximun 0xFFFFFFFF
    str r2,[r1]
    ldr r1,iAdrClockSrc
    str r0,[r1]                @ N° horloge demandée demarre la mesure

    ldr r1,iAdrClockStatus
    movs r3,CLOCKS_FC0_STATUS_DONE_BITS
2:                             @ boucle attente résultat
    ldr r2,[r1]
    ands r2,r3
    beq 2b
    
    ldr r1,iAdrClockResult     @ récupération resultat
    ldr r2,[r1]
    lsrs r2,CLOCKS_FC0_RESULT_KHZ_LSB
    afficherLib "Resultat en KHz :"
    mov r0,r2
    ldr r1,iAdrsZoneConv
    bl conversion10            @ conversion décimale
    add r0,r1
    movs r2,0x0D               @ ajout du retour ligne en fin de chaine
    strb r2,[r0]
    movs r2,0x0A
    strb r2,[r0,1]
    movs r2,0
    strb r2,[r0,2]
    mov r0,r1
    bl envoyerMessage
    
100:
    pop {r1-r4,pc}
.align 2
iAdrClockStatus:       .int CLOCKS_BASE + FC0_STATUS
iAdrClockRefKLZ:       .int CLOCKS_BASE + FC0_REF_KHZ
iAdrClockInter:        .int CLOCKS_BASE + FC0_INTERVAL
iAdrClockMin:          .int CLOCKS_BASE + FC0_MIN_KHZ
iAdrClockMax:          .int CLOCKS_BASE + FC0_MAX_KHZ
iAdrClockSrc:          .int CLOCKS_BASE + FC0_SRC
iAdrClockResult:       .int CLOCKS_BASE + FC0_RESULT
iBitsRun:              .int CLOCKS_FC0_STATUS_RUNNING_BITS
iFresRef:              .int 12000
iAdrsZoneConv:         .int sZoneConv
/******************************************************************/
/*     Début comptage systick                                         */ 
/******************************************************************/
.thumb_func
debutSystick:                  @ INFO: debutSystick
    ldr r0,iAdrSystick_RVR     @ adresse Systick_RVR voir ch 2.4.8
    ldr r1,iParam              @ Reload Value Register
    str r1,[r0]                @ valeur de départ
    adds r2,r0,4               @ adresse Systick_CVR Current Value Register
    movs r1,0                  @ init compteur
    str r1,[r2]
    subs r0,4                  @ adresse Systick_CSR Control and Status Register
    movs r1,5                  @ processeur et activation 
    str r1,[r0]
    ldr r1,iAdriValDepSys
    ldr r0,[r2]                @ lecture valeur
    str r0,[r1]                @ stockage valeur début   2 cycles
100:
    bx lr                      @ 3 cycles
.align 2
iParam:           .int 0x00ffffff
/******************************************************************/
/*     Fin comptage systick                                         */ 
/******************************************************************/
.thumb_func
finSystick:                  @ INFO: finSystick
    push {lr}                @ 2 cycles
    ldr r0,iAdrSystick_CVR   @ adresse Systick_RVR voir ch 2.4.8   2 cycles
    ldr r2,[r0]              @ lecture valeur
    ldr r1,iAdriValDepSys
    ldr r0,[r1]
    subs r0,r2                @ calcul différence
    ldr r1,iAdrsZoneDecSys    @ conversion
    bl conversion10
    ldr r0,iAdrszMessSystick  @ et affichage
    bl envoyerMessage
100:
    pop {pc}
    bx lr
.align 2
iAdriValDepSys:       .int iValDepSys
iAdrSystick_RVR:      .int PPB_BASE + SYST_RVR
iAdrSystick_CVR:      .int PPB_BASE + SYST_CVR
iAdrsZoneDecSys:      .int sZoneDecSys
iAdrszMessSystick:    .int szMessSystick
/******************************************************************/
/*     Début du chrono                                          */ 
/******************************************************************/
/*                    */
.thumb_func
debutChrono:                  @ INFO: debutChrono
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMELR]
    ldr r2,[r0,TIMEHR]
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
stopChrono:                   @ INFO: stopChrono
    push {r0-r4,lr} 
    ldr r0,iAdrTimerBase      @ lecture des registres compteurs bas et haut
    ldr r1,[r0,TIMELR]
    ldr r2,[r0,TIMEHR]
    ldr r0,iAdrdwDebut
    ldr r4,[r0,4]             @ stockage dans zones
    ldr r3,[r0]
    subs r0,r1,r4             @ calcul de la différence
    sbcs r2,r3
    ldr r1,iAdrsZoneDec       @ conversion
    bl conversion10
    ldr r0,iAdrszMessChrono   @ et affichage
    bl envoyerMessage
    pop {r0-r4,pc} 
.align 2
iAdrdwDebut:       .int dwDebut
iAdrTimerBase:     .int TIMER_BASE
iAdrsZoneDec:      .int sZoneDec
iAdrszMessChrono:  .int szMessChrono
