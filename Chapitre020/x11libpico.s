/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal  */
/* commandes  afficher un registre memoire en binaire */
/* afficher une zone mémoire */
/* fct teste un serveur web wifi */
/* compiler avec le sdk C  pour insertion bibliotheque wifi et lwip */
/* lancer avec putty picowusb9 ou avec puttyextra picousb9 ex  */
 

.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ LGBUFFERREQ,   80
.equ LGBUFFEVENT,   2000
.equ CYW43_AUTH_WPA2_AES_PSK,  0x00400004

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
.align 4
iAdrCallEvent:      .int calldefEvent
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
sIPserveur:         .skip 24
.align 4
sBufferReq:         .skip LGBUFFERREQ
.align 4
sBufferEvent:       .skip LGBUFFEVENT
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global XDrawLine,XCreateSimpleWindow,XCloseWindow,XMapWindow,XChangeWindowAttributs,XDrawString,XCreateGC
.global XSelectInput,XRectangle,XFillRectangle,XOpenDisplay,openConnexion,closeConnexion,addProcEvent,XNextEvent
.global ledEclats,XDrawMultiLine,XChangeGC,XUnMapWindow,XFreeGC,XDrawArc,XDrawFillArc
.global XCreatePixmap,XCopyArea,XConfigureWindow,XListFont,XOpenFont,XCloseFont
.global XCloseServer
.thumb_func
/******************************************************************/
/*     fonction  Connexion Wifi tcp_ip                               */ 
/******************************************************************/
/* r0  adresse status  */
/* r1  adresse string IP et serveur */
/* r2  adresse SSID  */
/* r3  adresse MDP  */
/* r0 return status or 0 */
.thumb_func
openConnexion:                       @ INFO:    openConnexion
    push {r1-r7,lr} 
    afficherLib "openConnexion"
    mov r4,r0
    mov r0,r1
    bl copieIP
    ldr r1,iAdrsIPserveur
    mov r0,r1
    mov r0,r4
    bl initStatusTcp
    mov r5,r2
    mov r6,r3
    bl extractIP
    cmp r0,0
    bne 1f
    b 99f
1:
    bl cyw43_arch_init
    cmp r0,0
    beq 2f
    b 99f
2:
    bl cyw43_arch_enable_sta_mode
    mov r0,r5                @ SSID
    mov r1,r6                @ MDP
    ldr r2,iAuthConn
    ldr r3,iAttente
    bl cyw43_arch_wifi_connect_timeout_ms
    cmp r0,0
    bne 98f
    movs r1,0
    movs r0,tcp_serveur_actif
    str r1,[r4,r0]
    ldr r0,[r4,tcp_IP]        @ adresse ip serveur X11
    bl tcp_new_ip_type        @ load tcp_pcb 
    cmp r0,0
    beq 98f
    str r0,[r4,tcp_pcb]
    mov r5,r0                 @ tcp_pcb
    mov r1,r4                 @ argument = status
    bl tcp_arg
    mov r0,r5                 @ tcp_pcb
    adr r1,tcp_client_pool 
    adds r1,1
    movs r2,POLL_TIME_S
    bl tcp_poll
    mov r0,r5
    adr r1,tcp_client_sent 
    adds r1,1
    bl tcp_sent
    mov r0,r5
    adr r1,tcp_client_recv
    adds r1,1
    bl tcp_recv
 
    mov r0,r5
    adr r1,tcp_client_err
    adds r1,1
    bl tcp_err
    movs r0,0
    str r0,[r4,tcp_client_connected]
    bl cyw43_thread_enter       @ = à cyw43_arch_lwip_begin
    mov r0,r5  @ pcb
    mov r1,r4
    adds r1,tcp_IP           @ adresse ip
    ldr r2,iTcpport         @ port  
    ldr r3,[r4,tcp_codeServer]
    add r2,r3
    adr r3,tcp_client_connect
    adds r3,1
    bl tcp_connect
    cmp r0,0
    bne 98f
    bl cyw43_thread_exit  @ = à cyw43_arch_lwip_end
    adr r0,calldefEvent
    adds r0,1
    str r0,[r4,tcp_call_event]
    afficherLib "Connexion OK"
    mov r0,r4
    b 100f
98:    
     affregtit codeerreur
     afficherLib "ERREUR connection"
     movs r0,0              @ erreur
     b 100f
99:    
     afficherLib "ERREUR Xopen"
     movs r0,0              @ erreur
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
iAttente:                .int 30000
iAuthConn:               .int CYW43_AUTH_WPA2_AES_PSK
iTcpport:                .int TCPPORT
iAdrsIPserveur:          .int sIPserveur
/******************************************************************/
/*     fonction  Connexion serveur X11                               */ 
/******************************************************************/
/* r0  adresse status  */
/* r1 adresse gestion evenement */
/* r0 return status or 0 */
.thumb_func
initStatusTcp:                       @ INFO:    initStatusTcp
    push {r0-r2,lr} 
    movs r1,0
    movs r2,0
1:
    strb r2,[r0,r1]
    adds r1,1
    cmp r1,tcp_end
    blt 1b
    pop {r0-r2,pc}          @ restaur des registres

.align 2    
/******************************************************************/
/*     fonction  Connexion serveur X11                               */ 
/******************************************************************/
/* r0  adresse status  */
/* r1 adresse gestion evenement */
/* r0 return status or 0 */
.thumb_func
XOpenDisplay:                       @ INFO:    XOpenDisplay
    push {r1-r4,lr} 
    afficherLib "XOpenDisplay"
    mov r4,r0
1:
    ldr r0,[r4,tcp_status]      @ attente reponse serveur X11
    cmp r0,2
    bne 1b
    mov r0,r4
    b 100f
99:
    movs r0,0
100:   
    pop {r1-r4,pc}          @ restaur des registres

.align 2    


/******************************************************************/
/*     function defaut appel gestion event                       */ 
/******************************************************************/
/* r0 event */ 
.thumb_func
calldefEvent:               @ INFO: calldefEvent
    push {r1,r2,lr}         @ save des registres
    afficherLib "Appel defaut event"
    
    pop {r1,r2,pc}          @ restaur des registres
.align 2 

/******************************************************************/
/*     fonction accept appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 state */
/* r1 tcp pcb  */
/* r2 erreur */
.thumb_func
tcp_client_connect:           @ INFO:   tcp_server_connected
    push {r4,r5,lr}  
    afficherLib "tcp_client_connect"
    mov r4,r0
    cmp r2,0
    beq 1f
    afficherLib "ERREUR client connexion"
    movs r1,2
    str r1,[r0,tcp_client_connected]
    movs r0,0
    b 100f
1:                   @ connexion client OK
 
    ldr r5,iAdrsBufferReq1
    movs r2,0154           @ en octal 102 ou 154
    strb r2,[r5,prefix_byteOrder]
    movs r2,11
    strh r2,[r5,prefix_majorVersion]
    movs r2,0
    strh r2,[r5,prefix_minorVersion]
    strh r2,[r5,prefix_nbytesAuthProto]
    strh r2,[r5,prefix_nbytesAuthString]
 
    mov r0,r4
    ldr r1,[r4,tcp_pcb]
    mov r2,r5
    movs r3,prefix_end
    bl envoyer_datas_serveur

    movs r1,1
    str r1,[r4,tcp_client_connected]
    str r1,[r4,tcp_status]
    movs r0,2
    bl ledEclats
    
    movs r0,0
100:
    pop {r4,r5,pc}
.align 2 
iAdrsBufferReq1:      .int sBufferReq
/******************************************************************/
/*     fonction pooling appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_client_pool:                      @ INFO:    tcp_client_pool
    push {lr} 
    movs r0,0       @ return ERR_OK
100:
    pop {pc}
.align 2
/******************************************************************/
/*     fonction envoi appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 longueur message */
.thumb_func
tcp_client_sent:           @ INFO:   tcp_server_sent
    push {lr} 
    movs r0,0       // return ERR_OK
100:
    pop {pc}
.align 2  
/******************************************************************/
/*     fonction erreur appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_client_err:                      @ INFO:    tcp_client_err
    push {lr} 
    afficherLib "tcp_client_err"
    affmemtit Erreur r0 4
    affregtit erreurdansr1
    //bl tcp_server_close
    movs r0,0       // return ERR_OK
100:
    pop {pc}
.align 2 
/******************************************************************/
/*     fonction reception appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 buffer packet */
/* r3 erreur  */
.thumb_func
tcp_client_recv:                       @ INFO:   tcp_client_recv
    push {r4-r7,lr} 
    mov r7,r8
    push {r7} 
    mov r4,r0
    mov r5,r1
    cmp r2,0        @ buffer packet null ?
    bne 1f
    b 9f
 1:
    mov r6,r2       @ save pbuf address
    mov r0,r2
    ldr r0,[r2,pbuf_payload] @ récup des données envoyées
    movs r7,r0                 @ save address payload 
    ldrb r0,[r7]
    cmp r0,0                    @ erreur X11
    bne 2f
    afficherLib "Erreur retour serveur X11"
    b 8f
2:  
    cmp r0,2                @ event ?
    bge 6f 
    ldr r3,[r4,tcp_status]
    cmp r3,1
    bne 4f                       @ retour open serveur
    mov r0,r4                    @ status 
    mov r1,r5                    @ tcp_pcb
    mov r2,r7                    @ payload
    bl traiterInfoServeur
    movs r3,2
    str r3,[r4,tcp_status]
    b 8f
4:
    cmp r3,4                   @  retour ListFont
    bne 5f
    mov r0,r7
    adds r0,32
    movs r3,2
    str r3,[r4,tcp_status]
    b 8f
5:
    afficherLib "Autres reponses du serveur "
    b 8f
6:                     @ event
    ldrh r2,[r6,pbuf_tot_len]
    ldr r1,iAdrsBufferEvent
    mov r8,r4
    ldr r4,iLgBuffEvent
    movs r0,0
7:                      @ copy loop payload for alignement
    ldrb r3,[r7,r0]
    strb r3,[r1,r0]
    adds r0,1
    cmp r0,r4            @ buffer size
    bge 98f
    cmp r0,r2
    blt 7b
    mov r0,r1
    mov r4,r8
    mov r0,r4
    ldr r2,[r4,tcp_call_event]
    blx r2
    b 8f
    
8:
    mov r0,r5
    ldrh r1,[r6,pbuf_tot_len]
    bl tcp_recved
    mov r0,r6                 @ raz buffer pour liberer place
    bl pbuf_free
    b 99f
9:                         @ reception paquet null
    afficherLib "Fermeture session"
    movs r0,1               @ fermeture cession
    movs r2,tcp_serveur_actif
    str r0,[r4,r2]
    b 99f
98:
    afficherLib "Buffer Event trop petit"
    movs r0,1
    b 100f    
99:
    movs r0,0       @ return ERR_OK 
100:
    pop {r7}
    mov r8,r7
    pop {r4-r7,pc}
.align 2  
iAdrsBufferEvent:      .int sBufferEvent
iLgBuffEvent:          .int LGBUFFEVENT

/******************************************************************/
/*     récupération des infos du serveur X11                                */ 
/******************************************************************/
/* r0  status */
/* r1  tcp  */
/* r2  adresse donnees reçue */
.thumb_func
traiterInfoServeur:                      @ INFO:    traiterInfoServeur
    push {r4-r7,lr} 
    mov r7,r0
    mov r5,r1
    mov r4,r2                @ info reçue
    ldrb r3,[r4]
    cmp r3,1                 @ code succes ?
    beq 1f
    afficherLib "Erreur init connexion"
    movs r0,0
    b 100f    
1:    
    ldrh r3,[r4,conn_majorVersion]     @
    cmp r3,11
    bne 2f
    afficherLib "Version majeure OK"
2:
    ldrh r3,[r4,conn_minorVersion]     @
    ldrh r3,[r4,conn_residbase]
    strh r3,[r7,tcp_ressource_ID]
    ldrh r3,[r4,conn_residbase+2]
    strh r3,[r7,tcp_ressource_ID+2]

    ldrh r3,[r4,conn_residmask]
    ldrh r3,[r4,conn_residmask+2]
    mov r0,r4
    adds r0,conn_Fournisseur
    mov r6,r0          @ save adresse fin fournisseur
    ldrh r0,[r4,conn_lgFournisseur]
    movs r1,4
    bl divisionEntiere
    cmp r3,0
    beq 3f
    movs r0,4
    subs r0,r3      // calcul du pad
    add r6,r0       // ajout du pad
3:
    mov r0,r6
    ldrh r2,[r4,conn_lgFournisseur]
    add r0,r2                     @ ajout longueur fournisseur
    movs r3,0                     @ taille des formats
    ldrb r2,[r4,conn_nbFormats]   @ ATTENTION 
    cmp r2,0
    beq 4f
    ldrb r1,[r0]
    strh r1,[r7,tcp_depth]
    movs r3,8
    muls r3,r3,r2
4:
    add r0,r3               @ ajout taille des formats
    ldrh r3,[r0]            @  root window      
    strh r3,[r7,tcp_parent]
    ldrh r3,[r0,2]
    strh r3,[r7,tcp_parent+2]
    adds r0,20
    ldrh r3,[r0]
    strh r3,[r7,tcp_screen_width]
    ldrh r3,[r0,2]
    strh r3,[r7,tcp_screen_height]
    adds r0,18
    ldrb r3,[r0]
    strh r3,[r7,tcp_bitpixel]
    movs r0,1
    afficherLib "fin traitement infos serveur"

100:

    pop {r4-r7,pc}
.align 2 
 
/******************************************************************/
/*     fonction close                                */ 
/******************************************************************/
/* r0 argument structure state */
.thumb_func
closeConnexion:                      @ INFO:    closeConnexion
    push {r1-r5,lr} 
    afficherLib "tcp_server_close"
    mov r5,r0
    ldr r1,[r0,tcp_pcb]
    cmp r1,0                   @ pointeur pcb  nul ?
    beq 2f
    mov r4,r1
    mov r0,r4
    movs r1,0
    bl tcp_arg
    mov r0,r4
    movs r1,0
    bl tcp_poll
    mov r0,r4
    movs r1,0
    bl tcp_sent
    mov r0,r4
    movs r1,0
    bl tcp_recv
    mov r0,r4
    movs r1,0
    bl tcp_err
    mov r0,r4
    bl tcp_close
    cmp r0,0
    beq 1f
    afficherLib "Erreur close tcp client"
    mov r0,r4
    bl tcp_abort
1:
    movs r1,0                      @ raz pointeur client  
    str r1,[r5,tcp_pcb]
2:
    bl cyw43_arch_deinit
    movs r0,0       // return ERR_OK
100:
    pop {r1-r5,pc}
.align 2 

/******************************************************************/
/*     create simple window                    */ 
/******************************************************************/
/* r0 status */
/* r1 Parent  */
/* r2 X */
/* r3 Y  */
/* height,width sur la pile */
.thumb_func 
XCreateSimpleWindow:                 @ INFO: XDrawLine
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
 
    ldr r5,iAdrsBufferReq2
    movs r0,1                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,8                   @ length
    strh r0,[r5,req_len]
    mov r0,r4
    bl createID
    str r0,[r5,reqwin_Id]
    mov r6,r0                   @ ident fenetre
    str r1,[r5,reqwin_Parent]
   
    strh r2,[r5,reqwin_X]
    strh r3,[r5,reqwin_Y]
    ldr r3,[r7,4]
    strh r3,[r5,reqwin_width]
    ldr r3,[r7]
    strh r3,[r5,reqwin_height]
    movs r3,1
    strh r3,[r5,reqwin_border]
    movs r3,0
    strh r3,[r5,reqwin_class]
    str  r3,[r5,reqwin_visual]
    str  r3,[r5,reqwin_bitmask]
    str r3,[r5,reqwin_values]
  
    movs r3,32                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    mov r0,r6                  @ return window ID
 1:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2

/******************************************************************/
/*     display window                    */ 
/******************************************************************/
/* r0 status */
/* r1 ID window  */
.thumb_func 
XMapWindow:                 @ INFO: XMapWindow
    push {r1-r7,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,8                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,2                   @ length
    strh r0,[r5,req_len]
    str r1,[r5,reqmap_Id]
    movs r3,8                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    mov r0,r6                  @ return window ID
 100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     masquage fenetre                    */ 
/******************************************************************/
/* r0 status */
/* r1 ID window  */

.thumb_func 
XUnMapWindow:                 @ INFO: XUnMapWindow
    push {r1-r5,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,10                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,2                   @ length
    strh r0,[r5,req_len]
    str r1,[r5,requnmap_Id]
    movs r3,8                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    mov r0,r6                  @ return window ID
 100:   
    pop {r1-r5,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*      appel poll                 */ 
/******************************************************************/
/* r0 status */
.thumb_func 
XNextEvent:                    @ INFO: XNextEvent
    push {r1-r4,lr}            @ save des registres
    mov r4,r0
1:
    bl sys_check_timeouts
    bl cyw43_arch_poll
    movs r0,10
    bl sleep_ms
    
100:   
    pop {r1-r4,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     create Graphic Context                  */ 
/******************************************************************/
/* r0 status */
/* r1 drawable  */
/* r2 value number */
/* r3 bits mask */

/* value 1 value 2 on stack */
.thumb_func 
XCreateGC:                    @ INFO: XCreateGC
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,55                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,4                   @ length
    add r0,r2
    strh r0,[r5,req_len]
    mov r0,r4
    bl createID
    str r0,[r5,reqGC_Id]
    mov r6,r0
    str r1,[r5,reqGC_drawable]
    str r3,[r5,reqGC_bitmask]
    
    movs r0,0
    adds r5,reqGC_value1
    lsls r2,2     @ *4 
1:
    ldr r3,[r7,r0]
    str r3,[r5,r0]
    adds r0,4
    cmp r0,r2
    blt 1b
    subs r5,reqGC_value1
    ldrh r3,[r5,req_len]                    @ length request in byte
    lsls r3,2
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    movs r0,10
    bl attendre
    mov r0,r6                  @ return GC identi
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     change Graphic Context                  */ 
/******************************************************************/
/* r0 status */
/* r1 ident GC  */
/* r2 bits mask */
/* r3 value   */
.thumb_func 
XChangeGC:                    @ INFO: XChangeGC
    push {r1-r5,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,56                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,4                   @ length
    strh r0,[r5,req_len]
    str r1,[r5,reqChgGC_Id]
    str r2,[r5,reqChgGC_bitmask]
    str r3,[r5,reqChgGC_value1]
    
    movs r3,16                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    movs r0,10
    bl attendre
    mov r0,r4
100:   
    pop {r1-r5,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     free Graphic Context                  */ 
/******************************************************************/
/* r0 status */
/* r1 ident GC  */
.thumb_func 
XFreeGC:                    @ INFO: XFreeGC
    push {r1-r5,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,60                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,2                   @ length
    strh r0,[r5,req_len]
    str r1,[r5,reqChgGC_Id]
    
    movs r3,8                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    movs r0,10
    bl attendre
100:   
    pop {r1-r5,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     create pixmap                  */ 
/******************************************************************/
/* r0 status */
/* r1 drawable  */
/* r2 width */
/* r3 height  */
.thumb_func 
XCreatePixmap:                    @ INFO: XCreatePixmap
    push {r1-r7,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq2
    movs r0,53                  @ opcode
    strb r0,[r5,req_code]
    ldrh r0,[r4,tcp_bitpixel]      @ complement  Bits by color
    strb r0,[r5,req_compl]
    movs r0,4                   @ length
    strh r0,[r5,req_len]
    mov r0,r4
    bl createID
    str r0,[r5,reqpix_Id]
    mov r6,r0
    str r1,[r5,reqpix_drawable]
    strh r2,[r5,reqpix_width]
    strh r3,[r5,reqpix_height]

    movs r3,16                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    mov r0,r6                  @ return GC identi
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
iAdrsBufferReq2:         .int sBufferReq
/******************************************************************/
/*     change windows attribut                   */ 
/******************************************************************/
/* r0 status */
/* r1 ID window  */
/* r2 values number
/* r3 bits mask */
/* values on stack */

.thumb_func 
XChangeWindowAttributs:                 @ INFO: XChangeWindowAttributs
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
    ldr r5,iAdrsBufferReq4
    movs r0,2                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,3                   @ length
    add r0,r2
    strh r0,[r5,req_len]
    mov r6,r0
    str r1,[r5,reqattrib_Id]
    str r3,[r5,reqattrib_bitmask]
    mov r0,r5
    adds r0,reqattrib_values
    lsls r2,2
    movs r1,r2
    subs r1,4
 1:
    ldr r3,[r7,r1]
    str r3,[r0,r1]
    subs r1,4
    bge 1b
    
    mov r3,r6                    @ length request in byte
    lsls r3,2
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
iAdrsBufferReq4:           .int sBufferReq
/******************************************************************/
/*     configure windows                    */ 
/******************************************************************/
/* r0 status */
/* r1 ID window  */
/* r2 number of values
/* r3 bits mask */
/* mask and value  on stack */

.thumb_func 
XConfigureWindow:                 @ INFO: XConfigureWindow
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
    ldr r5,iAdrsBufferReq
    movs r0,12                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,3                   @ length
    add  r0,r2
    mov r6,r0
    strh r0,[r5,req_len]
    str r1,[r5,reqconf_Id]
    str r3,[r5,reqconf_bitmask]
    mov r0,r5
    adds r0,reqconf_values
    lsls r2,2
    
    movs r1,r2
    subs r1,4
    
 1:
    ldr r3,[r7,r1]
    str r3,[r0,r1]
    subs r1,4
    bge 1b
    mov r3,r6
    lsls r3,2                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     copy rectangle area                   */ 
/******************************************************************/
/* r0 status */
/* r1 ID src  */
/* r2 ID dest */
/* r3 GC  */
/* Xsrc Ysrc  Xdest Ydest width height  sur la pile */   

.thumb_func 
XCopyArea:                 @ INFO: XCopyArea
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
    ldr r5,iAdrsBufferReq
    movs r0,62                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,7                   @ length
    strh r0,[r5,req_len]
    str r1,[r5,reqcopy_Idsrc]
    str r2,[r5,reqcopy_Iddest]
    str r3,[r5,reqcopy_GC]
    ldr r3,[r7,20]
    strh r3,[r5,reqcopy_height]
    ldr r3,[r7,16]
    strh r3,[r5,reqcopy_width]
    ldr r3,[r7,12]
    strh r3,[r5,reqcopy_Ydest]
    ldr r3,[r7,8]
    strh r3,[r5,reqcopy_Xdest]
    ldr r3,[r7,4]
    strh r3,[r5,reqcopy_Ysrc]
    ldr r3,[r7]
    strh r3,[r5,reqcopy_Xsrc]
    movs r3,28                   @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     selection input event                  */ 
/******************************************************************/
/* r0 status */
/* r1 ID window  */
/* r2 bits mask */
/* r3 value 1  */
/* value 2 sur la pile */

.thumb_func 
XSelectInput:                 @ INFO: XMapWindow
    push {lr}            @ save des registres
    bl XChangeWindowAttributs
100:   
    pop {pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     Dessin ligne                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 x  */
/* Y x1 y1  sur la pile */
.thumb_func 
XDrawLine:                    @ INFO: XDrawLine
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
 
    ldr r5,iAdrsBufferReq
    movs r0,65                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,5                   @ length
    strh r0,[r5,req_len]
    str r2,[r5,reqline_drawable]
   
    str r1,[r5,reqline_GC]
    strh r3,[r5,reqline_X]
    ldr r3,[r7]
    strh r3,[r5,reqline_Y1]
    ldr r3,[r7,4]
    strh r3,[r5,reqline_X1]
    ldr r3,[r7,8]
    strh r3,[r5,reqline_Y]
    lsls r0,2                    @ 4 bytes * length
    mov r3,r0                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
 1:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     Dessin multi lignes                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 nombre de points */
/* x y x1 y1 x2 y2 etc on stack */
.thumb_func 
XDrawMultiLine:                    @ INFO: XDrawMultiLine
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
 
    ldr r5,iAdrsBufferReq
    movs r0,65                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,3                   @ length
    add r0,r3
    mov r6,r0          
    strh r0,[r5,req_len]
    str r2,[r5,reqline_drawable]
    str r1,[r5,reqline_GC]
    movs r0,0
    adds r5,reqline_X
    movs r1,0
    lsls r3,2     @ *4 x+y sur 2 bytes
1:
    ldr r2,[r7,r0]
    strh r2,[r5,r1]
    adds r0,4
    adds r1,2
    cmp r1,r3
    blt 1b
    lsls r6,2                    @ 4 bytes * length
    mov r3,r6                    @ length request in byte
    mov r0,r4                    @ status
    ldr r2,iAdrsBufferReq        @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
 1:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     Dessin rectangle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 x  */
/* Y width height  on stack */
.thumb_func 
XFillRectangle:                  @ INFO: XFillRectangle
    push {r4-r5,lr}            @ save des registres
    ldr r5,iAdrsBufferReq
    movs r4,70                  @ opcode
    strb r4,[r5,req_code]
    bl XFunctRectangle
    pop  {r4-r5,pc}
/******************************************************************/
/*     Dessin rectangle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 x  */
/* Y width height  on stack */
.thumb_func 
XRectangle:                    @ INFO: XRectangle
    push {r4-r5,lr}            @ save des registres
    ldr r5,iAdrsBufferReq
    movs r4,67                  @ opcode
    strb r4,[r5,req_code]
    bl XFunctRectangle
    pop  {r4-r5,pc}
/******************************************************************/
/*     Dessin rectangle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 x  */
/* Y width height  on stack */
.thumb_func 
XFunctRectangle:               @ INFO: XFuncRectangle
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,44 
    mov r4,r0
 
    movs r0,0                   @ complement
    strb r0,[r5,req_compl]
    movs r0,5                   @ length
    strh r0,[r5,req_len]
    str r2,[r5,reqrect_drawable]
   
    str r1,[r5,reqrect_GC]
    strh r3,[r5,reqrect_X]
    ldr r3,[r7,8]
    strh r3,[r5,reqrect_height]
    ldr r3,[r7,4]
    strh r3,[r5,reqrect_width]
    ldr r3,[r7]
    strh r3,[r5,reqrect_Y]

    lsls r0,2                    @ 4 bytes * length
    mov r3,r0                    @ length request in byte
    mov r0,r5
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
 1:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     Dessin arc de cercle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 nombre d'arc  */
/* X Y width height start angle length angle on stack */
.thumb_func 
XDrawArc:                    @ INFO: XDrawArc
    push {r4,r5,lr}            @ save des registres
    ldr r5,iAdrsBufferReq
    movs r4,68                  @ opcode
    strb r4,[r5,req_code]
    bl XfuncDrawArc
    pop {r4,r5,pc}
 .align 2 
/******************************************************************/
/*     Dessin arc de cercle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 nombre d'arc  */
/* X Y width height start angle length angle on stack */
.thumb_func 
XDrawFillArc:                    @ INFO: XDrawFillArc
    push {r4,r5,lr}            @ save des registres
    ldr r5,iAdrsBufferReq
    movs r4,71                  @ opcode
    strb r4,[r5,req_code]
    bl XfuncDrawArc
    pop {r4,r5,pc}
 .align 2  
/******************************************************************/
/*     Dessin arc de cercle                    */ 
/******************************************************************/
/* r0 status */
/* r1 GC  */
/* r2 Windows */
/* r3 nombre d'arc  */
/* X Y width height start angle length angle on stack */
.thumb_func 
XfuncDrawArc:                    @ INFO: XfuncDrawArc
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,44                @ car ajout des 3 push fonction appelante
    mov r4,r0
    mov r0,r7
    ldr r5,iAdrsBufferReq
    movs r0,0                     @ complement
    strb r0,[r5,req_compl]
    str r1,[r5,reqarc_GC]
    str r2,[r5,reqarc_drawable]
    movs r0,3                     @ length of each arc
    movs r1,r3
    lsls r1,1                     @ * 2
    adds r1,r3                     @ 3 fois N
    adds r0,r1
    strh r0,[r5,req_len]
    mov r6,r5
    adds r6,reqarc_arc            @ begin area arc parameters 
    ldr r3,[r7]                   @ load X
    strh r3,[r6,arc_x]
    ldr r3,[r7,4]
    strh r3,[r6,arc_y]
    ldr r3,[r7,8]
    strh r3,[r6,arc_width]
    ldr r3,[r7,12]
    strh r3,[r6,arc_height]
    ldr r3,[r7,16]
    strh r3,[r6,arc_anglestart]
    ldr r3,[r7,20]
    strh r3,[r6,arc_anglelen]

    lsls r0,2                    @ 4 bytes * length
    mov r3,r0                    @ length request in byte
    
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
 100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     write text                   */ 
/******************************************************************/
/* r0 status */
/* r1 ID drawable  */
/* r2 ID GC */
/* r3 X   */
/* value Y string len sur la pile */

.thumb_func 
XDrawString:                 @ INFO: DrawString
    push {r1-r7,lr}            @ save des registres
    mov r7,sp
    adds r7,32 
    mov r4,r0
    ldr r5,iAdrsBufferReq
    movs r0,76                  @ opcode
    strb r0,[r5,req_code]
   
    str r1,[r5,reqtext_drawable]
    str r2,[r5,reqtext_GC]
    strh r3,[r5,reqtext_X]
    ldr r3,[r7,0]
    strh r3,[r5,reqtext_Y]
    ldr r0,[r7,8]                 @ string length
    strb r0,[r5,req_compl]
    mov r6,r0
    //calcul du pad
    movs r1,4
    bl divisionEntiere
    cmp r3,0
    beq 1f
    movs r1,4
    subs r1,r3
    mov r3,r1             @ pad
1:
    add r3,r6                  @ length + pad
    mov r0,r3
    adds r0,16                @ request length
    lsrs r0,2
    strh r0,[r5,req_len]
    adds r3,16                @ request length
    movs r2,0
    ldr r1,[r7,4]         @ string address
    mov r0,r5
    adds r0,reqtext_text
2:                          @ copy string in request
    ldrb r7,[r1,r2]
    strb r7,[r0,r2]
    adds r2,1
    cmp r2,LGTEXTMAX
    bge 99f
    cmp r2,r6
    blt 2b
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    movs r1,4                   @ code retour listFont
    str r1,[r4,tcp_status]
    
    b 100f
99:
    afficherLib "LONGUEUR STRING TROP GRANDE"
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
iAdrsBufferReq:         .int sBufferReq

/******************************************************************/
/*     list font                  */ 
/******************************************************************/
/* r0 status */
/* r1 number of font */
/* r2 pattern size */
/* r3 pattern address  */
.thumb_func 
XListFont:                     @ INFO: XListFont
    push {r1-r7,lr}            @ save des registres

    mov r4,r0
    ldr r5,iAdrsBufferReq3
    movs r0,49                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement 
    strb r0,[r5,req_compl]
    strh r1,[r5,reqlistF_maxnames]
    strh r2,[r5,reqlistF_lenPattern]
    mov r6,r2                 @ pattern size
    mov r7,r3                 @ patern address
    mov r0,r2
    //calcul du pad
    movs r1,4
    bl divisionEntiere
    cmp r3,0              @ no pad if zero
    beq 1f
    movs r1,4             @ pad compute
    subs r1,r3
    mov r3,r1             @ pad
1:
    add r3,r6                  @ length + pad
    mov r0,r3
    adds r0,8                @ add request first bytes 
    lsrs r0,2                @ divide by 4
    strh r0,[r5,req_len]     @ store length 
    adds r3,8                @ request length parameter
    
    movs r0,0
    mov r1,r5
    adds r1,reqlistF_Pattern
2:                          @ copy patern
    ldrb r2,[r7,r0]
    strb r2,[r1,r0]
    adds r0,1
    cmp r0,r6
    blt 2b
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     list font                  */ 
/******************************************************************/
/* r0 status */
/* r1 lenght font name */
/* r2 font name address */
/* r0 return font ident */
.thumb_func 
XOpenFont:                     @ INFO: XOpenFont
    push {r1-r7,lr}            @ save des registres

    mov r4,r0
    ldr r5,iAdrsBufferReq3
    movs r0,45                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement 
    strb r0,[r5,req_compl]
    strh r1,[r5,reqopenF_len]
    mov r0,r4
    bl createID
    str r0,[r5,reqopenF_Id]
    mov r6,r1                 @ name size
    mov r7,r2                 @ name address
    mov r0,r1
    //calcul du pad
    movs r1,4
    bl divisionEntiere
    cmp r3,0
    beq 1f
    movs r1,4
    subs r1,r3
    mov r3,r1             @ pad
1:
    add r3,r6                  @ length + pad
    mov r0,r3
    adds r0,12                @ request length
    lsrs r0,2
    strh r0,[r5,req_len]
    adds r3,12                @ request length
    movs r0,0
    mov r1,r5
    adds r1,reqopenF_name
2:                          @ copy patern
    ldrb r2,[r7,r0]
    strb r2,[r1,r0]
    adds r0,1
    cmp r0,r6
    blt 2b
    mov r0,r5
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    ldr r0,[r5,reqopenF_Id]      @ return ID font
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     close font                  */ 
/******************************************************************/
/* r0 status */
/* r1 font ID */
.thumb_func 
XCloseFont:                     @ INFO: XCloseFont
    push {r1-r7,lr}            @ save des registres
    mov r4,r0
    ldr r5,iAdrsBufferReq3
    movs r0,46                  @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement 
    strb r0,[r5,req_compl]
    movs r0,2                   @ length request
    strh r0,[r5,req_len]
    str r1,[r5,reqopenF_Id]
    movs r3,8                    @ length request in byte
    mov r0,r4                    @ status
    mov r2,r5                    @ request buffer
    ldr r1,[r4,tcp_pcb]          @ pcb
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
    movs r0,20
    bl attendre
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2
/******************************************************************/
/*     Close window                                */ 
/******************************************************************/
/* r0 status address */
/* r1  Window ident address */
.thumb_func
XCloseWindow:                      @ INFO:    XCloseWindow
    push {r4-r5,lr} 
    mov r4,r0
    ldr r5,iAdrsBufferReq3
    movs r0,4                   @ opcode
    strb r0,[r5,req_code]
    movs r0,0                   @ complement 
    strb r0,[r5,req_compl]
    movs r0,2                   @ length request
    strh r0,[r5,req_len]
    str r1,[r5,reqwin_Id]
    mov r0,r5
    mov r0,r4    
    ldr r1,[r4,tcp_pcb]
    mov r2,r5
    movs r3,8
    bl envoyer_datas_serveur
    ldr r0,[r4,tcp_pcb]
    bl tcp_output
 
    afficherLib "fin close window"
100:
    pop {r4-r5,pc}
.align 2 
/******************************************************************/
/*     Close server                               */ 
/******************************************************************/
/* r0 status address */
.thumb_func
XCloseServer:                      @ INFO:    XCloseServer
    push {r1,r2,lr} 
    movs r1,1               @ fermeture cession
    movs r2,tcp_serveur_actif
    str r1,[r0,r2]
 100:
    pop {r1,r2,pc}
.align 2   
iAdrsBufferReq3:         .int sBufferReq
/******************************************************************/
/*     fonction envoi des données                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 adresse données */
/* r3 longueur donnees */
.thumb_func
envoyer_datas_serveur:        @ INFO: envoyer_datas_serveur
    push {r1-r3,lr} 
    //afficherLib "envoyer_datas_serveur "
    mov r0,r1             @ tcp 
    mov r1,r2             @ adresse message 
    movs r2,r3            @ taille message
    movs r3,TCP_WRITE_FLAG_COPY
    bl tcp_write
    cmp r0,0
    beq 3f
    afficherLib "ERREUR ecriture donnees"
    bkpt 20
3:
    movs r0,10
    bl attendre
    
    movs r0,0       // return ERR_OK
100:
    pop {r1-r3,pc}    
.align 2
/******************************************************************/
/*     creation identification ressources                       */ 
/******************************************************************/
/* r0 status */
.thumb_func
createID:                  @ INFO: createID
    push {r1,r2,lr}         @ save des registres
    mov r1,r0
    ldr r0,[r1,tcp_ressource_ID]
    mov r2,r0
    adds r2,1
    str r2,[r1,tcp_ressource_ID]
    pop {r1,r2,pc}          @ restaur des registres
.align 2
/******************************************************************/
/*     fonction  Connexion serveur X11                                */ 
/******************************************************************/
/* r0  adresse status  */
/* r1  adresse string IP et serveur */
.thumb_func
extractIP:                       @ INFO:    extractIP
    push {r1-r7,lr} 
    mov r4,r1
    mov r5,r0
    movs r6,0
1:
    ldrb r3,[r4,r6]
    cmp r3,0
    beq 99f
    cmp r3,':'
    beq 2f
    adds r6,1
    b 1b
2:
    movs r3,0
    strb r3,[r4,r6]
    mov r0,r4
    bl ipaddr_addr         @  TODO: voir si erreur 
    cmp r0,0               @ error ?
    ble 99f
    str r0,[r5,tcp_IP]
    adds r6,1
    ldrb r3,[r4,r6]        @ 
    cmp r3,'0'
    blt 98f
    cmp r3,'9'
    bgt 98f
    subs r3,48
    str r3,[r5,tcp_codeServer]
    b 100f
98:
    afficherLib "Erreur code serveur (0-9)"
    movs r0,0
    b 100f
99:
    afficherLib "Error address IP (IP:code)"
    movs r0,0
100:   
    pop {r1-r7,pc}          @ restaur des registres

.align 2 
/******************************************************************/
/*     fonction  copie zone IP                              */ 
/******************************************************************/
/* r0  adresse IP  */
.thumb_func
copieIP:                       @ INFO:    copieIP
    push {r0-r3,lr} 
    movs r1,0
    ldr r3,iAdrsIPserveur1
1:
    ldrb r2,[r0,r1]
    strb r2,[r3,r1]
    adds r1,1
    cmp r2,0
    bne 1b
    pop {r0-r3,pc}          @ restaur des registres
.align 2    
iAdrsIPserveur1:          .int sIPserveur
/******************************************************************/
/*     fonction  Connexion serveur X11                                */ 
/******************************************************************/
/* r0  adresse status  */
/* r1  adresse fonction gestion evenement */
.thumb_func
addProcEvent:                       @ INFO:    addProcEvent
    push {lr} 
    movs r2,1
    eors r2,r0
    cmp r2,1
    bne 1f
    adds r1,1                   @ for align thumb function
 1:
    str r1,[r0,tcp_call_event]  @ address function events
    pop {pc} 
.align 2
/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.thumb_func
ledEclats:                     @ INFO: ledEclats
    push {r0-r4,lr}
    movs r4,r0
1:
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,1
    bl cyw43_arch_gpio_put
    movs r0, #250
    bl attendre                @ appel fonction librairie
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,0
    bl cyw43_arch_gpio_put
    movs r0, #250
    bl attendre 
    subs r4,1
    bgt 1b 
    
    pop {r0-r4,pc}
    
