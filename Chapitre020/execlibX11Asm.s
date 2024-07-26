/* Programme assembleur ARM Raspberry pico */
/* test de la librairue X11 */

/* fct teste un client X11  */
/* compiler avec le sdk C  pour insertion bibliotheque wifi et lwip */
/* lancer avec putty picowusb9 ou avec puttyextra picousb9   */
/* IMPORTANT modifier l'adresse IP avec celle de votre serveur X11 
   modifier le nom du réseau et le mot de passe */
 
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"

.equ   PICO_OK,              0
.equ   PICO_ERROR_NONE,      0
.equ   PICO_ERROR_TIMEOUT,  -1
.equ   PICO_ERROR_GENERIC,  -2
.equ   PICO_ERROR_NO_DATA,  -3




.equ CWEventMask,		1<<11

/*********************************************/
/*           CONSTANTES X11                      */
/********************************************/
.include "./x11libpico.inc"

/*******************************************/
/*       Macros                      */
/*******************************************/
.include "./ficmacros.inc"


/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDebutPgm:    .asciz "Debut du programme."


szMessCmd:         .asciz "Entrez une commande ( ou help) :"

szLibCmdFin:       .asciz "fin"
szLibCmdFct:       .asciz "x11"
szLibCmdHelp:       .asciz "help"
           
szLibPico:         .asciz "Bienvenue sur le PICO W."
.equ LGLIBPICO,   . - szLibPico - 1
szIPServeur:       .asciz "192.168.1.21:0"         @ à modifier avec votre adresse du serveur X11
szListeCom:        .asciz "\r\nx11\r\nhelp\r\nfin"
szSSSID:           .asciz "Adresse_reseau"           @ à modifier
szMdp:             .asciz "mot de passe"     @ à modifier


szLibPatternFont:  .asciz "*-helvetica-bold-*-24-*"
.equ LGPATTERNFONT,   . -  szLibPatternFont -1

szLibFont1:  .asciz "*-helvetica-bold-o-normal--24-240-75-75-p-138-iso8859-1*"
.equ LGFONT1,   . -  szLibFont1 -1

szLibButtonOn:        .asciz "Led on"
szLibButtonOff:       .asciz "Led off"
.align 4
                   
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iIdentWin:           .skip 4
iIdentButtonOn:      .skip 4
iIdentButtonOff:     .skip 4
iIdentGCWin:         .skip 4
iIdentButtonPress:   .skip 4
iIdentFont1:         .skip 
sBuffer:             .skip 200 
state:               .skip tcp_end
.align 4


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
    ldr r0,iAdrszMessCmd
    bl __wrap_puts
    ldr r0,iAdrsBuffer
    bl lireChaine
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFct
    bl comparerChaines
    cmp r0, 0
    bne 4f
    bl testlibX11
    b 10f
4:                                @  reset du pico 
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdFin1
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

6:    @ suite éventuelle
    ldr r0,iAdrsBuffer
    ldr r1,iAdrszLibCmdHelp
    bl comparerChaines
    cmp r0, 0
    bne 7f
    ldr r0,iAdrszListeCom
    bl __wrap_puts
    
    b 10f
    
7:    @ suite éventuelle

10:
    b 3b                        @ boucle commande
 
100:                            @ boucle pour fin de programme standard  
    b 100b
/************************************/
.align 2
iAdrszMessCmd:          .int szMessCmd
iAdrszLibCmdFin1:       .int szLibCmdFin
iAdrszLibCmdFct:        .int szLibCmdFct
iAdrszLibCmdHelp:        .int szLibCmdHelp
iAdrszMessDebutPgm:     .int szMessDebutPgm
iAdrszListeCom:         .int szListeCom
iAdrsBuffer:            .int sBuffer
/******************************************************************/
/*     lire une commande                                          */ 
/******************************************************************/
/* r0 contient l'adresse du buffer                   */
.thumb_func
lireChaine:                @ INFO: lireChaine
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
/*     Lancement du serveur web  WIFI                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
testlibX11:                @ INFO: testlibX11
    push {r1-r7,lr}
    afficherLib "Connexion en cours ..."
    ldr r0,iAdrStatus0
    ldr r1,iAdrszIPServeur
    ldr r2,iadrszSSID1
    ldr r3,iadrszMdp
    bl openConnexion
    cmp r0,0
    bne 1f
    b 99f
1:
    ldr r0,iAdrStatus0
    bl XOpenDisplay
    cmp r0,0
    bne 2f
    b 99f
2:
    mov r4,r0               @ recup info serveur OK
    //affmemtit Status r0 5
                            @ création de la fenetre
    ldr r1,[r4,tcp_parent]
    movs r2,10              @ X
    movs r3,200             @ hauteur
    push {r3}
    movs r3,180             @ largeur
    lsls r3,1               @ * 2
    push {r3}
    movs r3,50              @ Y
    bl XCreateSimpleWindow  @ creation bouton
    mov r7,r0               @ recup id window
    ldr r1,iAdriIdentWin
    str r0,[r1]
    movs r2,8
    add sp,r2               @ 2 push 
    mov r0,r4
    adr r1,procTraitEvents
    adds r1,1
    bl addProcEvent
    mov r0,r4
    mov r1,r7
    movs r2,2
    movs r3,KeyPressed|ButtonPress
    push {r3}
    ldr r3,iColorGrey1
    push {r3}
    ldr r3,iValAttribMask
    bl XChangeWindowAttributs
    movs r2,8
    add sp,r2               @ 2 push 
    mov r1,r7
    mov r0,r4
    bl XMapWindow           @ affichage de la fenetre
    
    mov r0,r4
    movs r1,5                    @ nombre de police
    movs r2,LGPATTERNFONT        @ taille pattern
    ldr r3,iAdrszLibPatternFont
    bl XListFont
    
    mov r0,r4
    movs r1,LGFONT1
    ldr r2,iAdrszLibFont1
    bl XOpenFont
    //affregtit RETOURFONT
    ldr r1,iAdriIdentFont1
    str r0,[r1]        @ store ident font
    
    mov r0,r4
    mov r1,r7          @ window ident
    movs r2,3          @ values number
    ldr r3,iAdriIdentFont1
    ldr r3,[r3]        @ id font 
    push {r3}
    ldr r3,iColorGrey1
    push {r3}
    ldr r3,iColorWhite1
    push {r3}
    ldr r3,iGCParam
    bl XCreateGC
    ldr r1,iAdriIdentGCWin
    str r0,[r1]        @ ident GC  
    mov r6,r0          @ ident GC
    
    movs r0,12   
    add sp,r0           @ 3 push 
    
    
    mov r0,r4
    mov r1,r7              @ id window
    mov r2,r6              @ GC
    movs r3,LGLIBPICO      @  @ string length
    push {r3}
    ldr r3,iAdrszLibPico   @ texte 
    push {r3}
    movs r3,20             @ Y
    push {r3}
    movs r3,30             @ X    
    bl XDrawString
    movs r0,12
    add sp,r0              @ 3 push 
    
    mov r0,r4
    mov r1,r6              @ GC
    mov r2,r7              @ window
    bl dessiner
    mov r0,r4
    mov r1,r6              @ GC
    mov r2,r7              @ window
    bl dessinerCercles
    
    
5:                               @ loop sever event
    mov r0,r4
    bl XNextEvent
    ldr r1,[r4,tcp_serveur_actif]     @ end session ?
    cmp r1,1
    bne 5b
    
    
    mov r0,r4
    bl closeConnexion
    
    afficherLib "Fin fonction X11"
    b 100f
99: 
     afficherLib "ERREUR !!"
100:
    pop {r1-r7,pc}
 .align 2
 iAdrszIPServeur:   .int szIPServeur
 iAdrStatus0:       .int state
 iValAttribMask:     .int CWBackPixel|CWEventMask
 iColorGrey1:       .int 0x787878
 iColorWhite1:      .int 0xFFFFFF
 iadrszSSID1:      .int szSSSID
 iadrszMdp:        .int szMdp
 iAdrszLibPatternFont: .int szLibPatternFont
 iAdrszLibPico:        .int szLibPico
 iAdrszLibFont1:      .int szLibFont1
 iAdriIdentFont1:     .int iIdentFont1
 iGCFont:             .int GCFont
 iGCParam:            .int GCForeground|GCBackground|GCFont
 
/******************************************************************/
/*     fonction de traitement des évenements                      */ 
/******************************************************************/
/* r0 contient status */
/* r1 contient les données recues */
.thumb_func
procTraitEvents:                @ INFO: lancementServeur
    push {r1-r5,lr}
   // affmemtit procTraitEvents r1 4
    mov r4,r0
    mov r5,r1
    ldrb r1,[r5]
    cmp r1,ButtonPress
    bne 2f
    ldr r2,iAdriIdentButtonPress
    ldrh r3,[r5,event_winchild]
    strh r3,[r2]
    ldrh r3,[r5,event_winchild+2]
    strh r3,[r2,2]
    ldr r3,[r2]
    ldr r1,iAdriIdentButtonOn
    ldr r1,[r1]
    cmp r1,r3
    bne 1f
    afficherLib "Le bouton est pressé"
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,1
    bl cyw43_arch_gpio_put
    
    mov r0,r4
    ldr r1,iAdriIdentGCWin
    ldr r1,[r1]
    movs r2,GCForeground
    ldr r3,iColorGreen
    bl XChangeGC
    mov r0,r4
    ldr r1,iAdriIdentGCWin
    ldr r1,[r1]
    ldr r2,iAdriIdentWin
    ldr r2,[r2]
    bl dessiner
    b 100f    
1:
    ldr r1,iAdriIdentButtonOff
    ldr r1,[r1]
    cmp r1,r3
    bne 100f
    afficherLib "Le bouton off est pressé"
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,0
    bl cyw43_arch_gpio_put
    b 100f
2:    
   cmp r1,KeyPressEvt
   bne 3f
   ldrb r3,[r5,1]         @ position 2 = code touche
   cmp r3,0x26            @ touche q
   bne 3f
   afficherLib "Demande fermeture"
   mov r0,r4
   bl fermeture
   movs r0,0
3:
100:
    pop {r1-r5,pc}
 .align 2  
 iAdriIdentWin:          .int iIdentWin
 iAdriIdentButtonPress: .int iIdentButtonPress
 iAdriIdentGCWin:       .int iIdentGCWin
 iColorGreen:           .int 0xFF00
.align 2

/******************************************************************/
/*     dessin                     */ 
/******************************************************************/
/* r0 status */
/* r1 ident GC */
/* r2 ident fenetre */
.thumb_func
dessiner:                  @ INFO: dessiner
    push {r0-r7,lr}        @ save des registres
    mov r4,r0
    mov r5,r1
    mov r6,r2

    
    mov r0,r4
    mov r1,r5
    mov r2,r6            @ id window parent
    movs r3,50          @ height
    push {r3}
    movs r3,200           @ width
    push {r3}
    movs r3,40           @  Y
    push {r3}
    movs r3,80           @ X
    bl XRectangle
    movs r3,12
    add sp,r3           @ 3 push 
    
    
    mov r0,r4
    mov r1,r6            @ id window parent
    movs r2,120          @ X
    movs r3,20           @ hauteur
    push {r3}
    movs r3,45           @ largeur
    push {r3}
    movs r3,50           @ Y
    bl XCreateSimpleWindow  @ creation bouton
    mov r7,r0               @ recup id bouton
    ldr r2,iAdriIdentButtonOn
    str r7,[r2]
    movs r2,8
    add sp,r2               @ 2 push 
    mov r1,r0
    mov r0,r4
    bl XMapWindow
    mov r0,r4
    mov r1,r7               @ id bouton
    movs r2,3
    movs r3,EnterNotify
    push {r3}
    ldr r3,iColorRed          @ border color
    push {r3}
    ldr r3,iColorBlue         @ background color
    push {r3}
    ldr r3,iButtonMask
    bl XChangeWindowAttributs
    movs r0,12
    add sp,r0           @ 1 push 
    mov r0,r4
    mov r1,r7           @ id bouton
    movs r2,2
    ldr r3,iColorGrey
    push {r3}
    ldr r3,iColorWhite
    push {r3}
    movs r3,0xC
    bl XCreateGC
    mov r2,r0            @ GC bouton
    movs r0,8
    add sp,r0            @ 1 push 
    mov r0,r4
    mov r1,r7            @ id bouton
    movs r3,6            @ string length
    push {r3}
    ldr r3,iAdrszLibButtonOn   @ texte bouton
    push {r3}
    movs r3,15           @ Y
    push {r3}
    movs r3,5            @ X          
    bl XDrawString
    movs r0,12
    add sp,r0            @ 3 push 
    
    
    mov r0,r4
    mov r1,r6            @ id window parent
    movs r2,190          @ X
    movs r3,20           @ hauteur
    push {r3}
    movs r3,45           @ largeur
    push {r3}
    movs r3,50           @ Y
    bl XCreateSimpleWindow  @ creation bouton
    mov r7,r0               @ recup id bouton
    ldr r2,iAdriIdentButtonOff
    str r7,[r2]
    movs r2,8
    add sp,r2               @ 2 push 
    mov r1,r0
    mov r0,r4
    bl XMapWindow
    mov r0,r4
    mov r1,r7               @ id bouton
    movs r2,3
    movs r3,EnterNotify
    push {r3}
    ldr r3,iColorBlue          @ border color
    push {r3}
    ldr r3,iColorRed               @ background color
    push {r3}
    ldr r3,iButtonMask
    bl XChangeWindowAttributs
    movs r0,12
    add sp,r0           @ 3 push 
    mov r0,r4
    mov r1,r7           @ id bouton
    movs r2,2
    ldr r3,iColorGrey
    push {r3}
    ldr r3,iColorWhite
    push {r3}
    movs r3,0xC
    bl XCreateGC
    mov r2,r0            @ GC bouton
    movs r0,8
    add sp,r0            @ 1 push 
    mov r0,r4
    mov r1,r7            @ id bouton
    movs r3,7            @ string length
    push {r3}
    ldr r3,iAdrszLibButtonOff   @ texte bouton
    push {r3}
    movs r3,15           @ Y
    push {r3}
    movs r3,5            @ X          
    bl XDrawString
    movs r0,12
    add sp,r0            @ 3 push 
    
    afficherLib "Fin dessin"
100:   
    pop {r0-r7,pc}          @ restaur des registres
.align 2

iAdriIdentButtonOn:  .int iIdentButtonOn
iAdriIdentButtonOff:  .int iIdentButtonOff
iAdrszLibButtonOn:      .int szLibButtonOn
iAdrszLibButtonOff:    .int szLibButtonOff
iButtonMask:           .int CWBackPixel|CWBorderPixel|CWEventMask

.align 2
/******************************************************************/
/*     dessin                     */ 
/******************************************************************/
/* r0 status */
/* r1 ident GC */
/* r2 ident fenetre */
.thumb_func
dessinerCercles:                  @ INFO: dessiner
    push {r0-r7,lr}       @ save des registres
    mov r4,r0
    mov r0,r4
    mov r5,r1
    mov r6,r2
    mov r0,r4
    mov r1,r5             @ ident GC
    movs r2,GCForeground
    ldr r3,iColorRed
    bl XChangeGC
    mov r0,r4
    mov r0,r4
    mov r1,r5
    mov r2,r6
    ldr r3,iCircle
    push {r3}
    movs r3,0             @ angle start
    push {r3}
    movs r3,50            @ hauteur
    push {r3}
    movs r3,50            @ largeur
    push {r3}
    movs r3,100           @ Y
    push {r3}
    movs r3,100           @ X
    push {r3}
 
    movs r3,1             @ un seul arc
    
    bl XDrawFillArc
    movs r3,24
    add sp,r3             @ N points * 2 push 
    
 
    mov r0,r4
    mov r1,r5             @ ident GC
    movs r2,GCForeground
    ldr r3,iColorBlue
    bl XChangeGC
    mov r0,r4
    
    mov r0,r4
    mov r1,r5
    mov r2,r6
    ldr r3,iCircle
    push {r3}
    movs r3,0             @ angle start
    push {r3}
    movs r3,50            @ hauteur
    push {r3}
    movs r3,50            @ largeur
    push {r3}
    movs r3,100           @ Y
    push {r3}
    movs r3,150           @ X
    push {r3}
 
    movs r3,1             @ un seul arc
    
    bl XDrawFillArc
    movs r3,24
    add sp,r3             @ N points * 2 push 
    
 
    mov r0,r4
    mov r1,r5             @ ident GC
    movs r2,GCForeground
    ldr r3,iColorGreen1
    bl XChangeGC
    mov r0,r4
    mov r1,r5
    mov r2,r6
    ldr r3,iCircle
    push {r3}
    movs r3,0             @ angle start
    push {r3}
    movs r3,50            @ hauteur
    push {r3}
    movs r3,50            @ largeur
    push {r3}
    movs r3,100           @ Y
    push {r3}
    movs r3,200           @ X
    push {r3}
 
    movs r3,1            @ un seul arc
    
    bl XDrawFillArc
    movs r3,24
    add sp,r3            @ N points * 2 push 
    
100:   
    pop {r0-r7,pc}       @ restaur des registres
.align 2
iColorRed:          .int 0xFF0000
iColorGreen1:       .int 0xFF00
iColorBlue:         .int 0xFF
iColorWhite:        .int 0xFFFFFF
iColorGrey:         .int 0x282828
iCircle:            .int 360*64
/******************************************************************/
/*     fermeture des entités                     */ 
/******************************************************************/
/* r0 status */
.thumb_func
fermeture:                  @ INFO: fermeture
    push {r0-r7,lr}        @ save des registres
    mov r4,r0
    ldr r1,iAdriIdentFont11
    ldr r1,[r1]                   @ id font 
    mov r0,r4
    bl XCloseFont               @ engendre une erreur 
    
    mov r0,r4
    ldr r1,iAdriIdentGCWin1
    ldr r1,[r1]
    bl XFreeGC
    
    mov r0,r4
    ldr r1,iAdriIdentWin1
    ldr r1,[r1]
    bl XCloseWindow
    
    mov r0,r4
    bl XCloseServer
    movs r0,0
100:   
    pop {r0-r7,pc}          @ restaur des registres
.align 2
iAdriIdentFont11:   .int iIdentFont1
iAdriIdentGCWin1:   .int iIdentGCWin
iAdriIdentWin1:     .int iIdentWin
