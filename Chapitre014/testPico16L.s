/* Programme assembleur ARM Raspberry pico */
/* test connexion USB OK sans utilisation du SDK */
/* utilise Putty pour connexion série 9600 bauds */
/* utilise les routinesPicoARM et routinesUSBCDC  */
/* Attention encodage du programme en UTF-8 pour éviter pb des accents */
.syntax unified
.cpu cortex-m0plus 
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ ADDRESSEPILE,    0x20042000
.equ GPIO_25_CTRL,    IO_BANK0_BASE + 8 * 25 + 4


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
szMessEnvoi:        .asciz "Envoi du Pico pour test\r\n"
szMessFinPgm:       .asciz "Fin du programme.\r\n"
szMessCommande:     .asciz "Tapez une commande : \r\n"
szLibCmdAide:       .asciz "aide"
szLibCmdAff:       .asciz "aff"
szLibCmdMem:       .asciz "mem"
szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "fct"
szLibCmdBin:       .asciz "bin"
szMessSaisieReg:   .asciz "Adresse du registre en hexa ?:\r\n"

szMessAide:        .asciz "Liste des commandes disponibles : \r\n"
szMessAideListe:   .asciz "aide\r\nfin\r\nfct\r\n"

szMessLongSup64:   .asciz "Pour test message de plus de 64 caractères car fonction envoi limitée à 64 caractères.123456789ABCDEFGH\r\n"

.align 4

/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
sBuffer:    .skip 80 

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
    ldr r0,iAdrszMessAide
    bl envoyerMessage
    ldr r0,iAdrszMessAideListe
    bl envoyerMessage
    b 10f

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
    ldr r0,iAdrszMessLongSup64    @ test message long
    bl envoyerMessage
    b 10f                         @ fin du programme
    
5:  
    afficherLib "Commande inconnue! tapez aide"
    //ldr r0,iAdrsBuffer
    //bl envoyerMessage
10:
    b 2b                          @ boucle commande


.thumb_func
loop:                             @ boucle pour fin de programme standard  
    b loop
 

/************************************/
.align 2
iAdrszMessDebPgm:       .int  szMessDebPgm
iAdrszMessEnvoi:        .int  szMessEnvoi
iAdrszMessFinPgm:       .int  szMessFinPgm
iAdrStack:              .int ADDRESSEPILE
iAdriHostOK:            .int iHostOK
iAdrsBuffer:            .int sBuffer
iAdrszMessCommande:     .int szMessCommande
iAdrszLibCmdAide:       .int szLibCmdAide
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszMessAide:         .int szMessAide
iAdrszMessAideListe:    .int szMessAideListe
iAdrszMessLongSup64:    .int szMessLongSup64
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

