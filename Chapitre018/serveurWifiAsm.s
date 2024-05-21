/* Programme assembleur ARM Raspberry pico */
/* Serveur web wifi pour le pico W */
/* compiler avec le sdk C  pour insertion bibliotheque wifi et lwip */
/* Init Ok : 2 eclats Led  Connexion Ok 5 eclats   */
/* se connecter avec un navigateur IP 192.168.1.18 (à changer suivant l'IP de votre Pico)

.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ CYW43_WL_GPIO_LED_PIN, 0

.equ   PICO_OK,              0
.equ   PICO_ERROR_NONE,      0
.equ   PICO_ERROR_TIMEOUT,  -1
.equ   PICO_ERROR_GENERIC,  -2
.equ   PICO_ERROR_NO_DATA,  -3

.equ CYW43_WPA2_AUTH_PSK,      0x0080
.equ CYW43_AUTH_WPA2_AES_PSK,  0x00400004
.equ IPADDR_TYPE_ANY,          0x2e
.equ BUF_SIZE, 2048
.equ POLL_TIME_S, 5
.equ TCP_WRITE_FLAG_COPY, 1

.equ RESETS_BASE,       0x4000c000
.equ RESETS_RESET,      0
.equ RESETS_WDSEL,      4
.equ RESETS_RESET_DONE, 8

.equ ADC_BASE,          0x4004c000
.equ ADC_CS,          0
.equ ADC_RESULT,      4
.equ ADC_FCS,         8
.equ ADC_FIFO,        0xC
.equ ADC_DIV,        0x10
.equ ADC_INTR,        0x14
.equ ADC_INTE,        0x18
.equ ADC_INTF,        0x1C
.equ ADC_INTS,        0x20

.equ PLL_USB_BASE,    0x4002c000

/*******************************************/
/*         Structures                      */
/*******************************************/
/*  définitions tcp */
    .struct  0
tcp_server_pcb:                     @  
    .struct  tcp_server_pcb + 4 
tcp_client_pcb:                     @  
    .struct  tcp_client_pcb + 4 
tcp_complete:                     @  
    .struct  tcp_complete + 4 
tcp_buffer_sent:                     @  
    .struct  tcp_buffer_sent + BUF_SIZE 
tcp_buffer_recv:                     @  
    .struct  tcp_buffer_recv + BUF_SIZE 
tcp_sent_len:                     @  
    .struct  tcp_sent_len + 4 
tcp_recv_len:                     @  
    .struct  tcp_recv_len + 4
tcp_end:
/*  définitions packet buffer */
    .struct  0
pbuf_next:                     @  
    .struct  pbuf_next + 4        
pbuf_payload:                     @  
    .struct  pbuf_payload + 4
pbuf_tot_len:                     @  
    .struct  pbuf_tot_len + 2
pbuf_len:                     @  
    .struct  pbuf_len + 2
pbuf_type:                     @  
    .struct  pbuf_type + 1
pbuf_flags:                     @  
    .struct  pbuf_flags + 1
pbuf_ref:                     @  
    .struct  pbuf_ref + 2    
    

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data

szFavicon:         .asciz "GET /favicon.ico"
.equ LGFAVICON,    . - szFavicon
szCommandeWeb:     .asciz "GET /commande?com="
.equ LGCOMMANDEWEB,   . - szCommandeWeb
szCommandeStop:    .asciz "GET /stop?"
.equ LGCOMMANDESTOP,   . - szCommandeStop

szLibCmdTest:      .asciz "test"
szLibCmdHelp:      .asciz "help"
szLibCmdTemp:      .asciz "temp"             @ affiche la temperature    
szLibCmdLedon:     .asciz "ledon"            @ allume la Led
szLibCmdLedoff:    .asciz "ledoff"           @ eteint la Led
szCommandeInc:     .asciz "Commande inconnue, help pour la liste." 
szListeCom:        .asciz "test <br>temp <br>ledon<br>ledoff<br>help<br>             "

szSSSID:           .asciz "Votre code reseau"
szMdp:             .asciz "Votre mot de passe"
szAnnonce:         .asciz "Entrez une commande : help pour la liste.<BR>"
szEntete:          .asciz "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n";
.equ TAILLEENTETE, . - szEntete

// Description html du formulaire
szLigne1:          .ascii " <!DOCTYPE html> <html> <body>Bienvenue sur le Pico W. <br>"
                   .asciz " <form action=\"./commande\"> <br> Commande : <br><input type=\"Commande\" id=\"commande\" name=\"com\" /> <br> </form> <br>"
.equ TAILLELIGNE1,  . - szLigne1             
szLigne2:   .ascii "<br><br><form action=\"./stop\"><input type=\"submit\" value=\"STOP\" />"
            .ascii "</form><br>"
            .asciz "</body></html>\r\n\r\n"
.equ TAILLELIGNE2,  . - szLigne2

szMessageRetour:  .fill 80,1,' '  
                  .int 0  
.equ LGMESSAGE,    . -  szMessageRetour - 1 

szCommandeTest:    .asciz "Commande test OK."

szMessTemp:       .ascii "Temperature (en dixieme de degres) = "
sZoneTempDec:     .asciz "             <br>"
.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iServeurActif:  .skip 4
sBuffer:        .skip 20 
state:          .skip tcp_end
netif_list:     .skip BUF_SIZE
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ initialisations
    bl stdio_init_all

    bl cyw43_arch_init
    cmp r0,0
    beq 1f
    bkpt 5                      @ erreur init

1: 
    bl initADC
    movs r0,2
    bl ledEclats

    bl lancementServeur
    movs r0,'U'                 @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
 
100:                            @ boucle pour fin de programme standard  
    b 100b
/************************************/
.align 2
//iAdrsBuffer:         .int sBuffer

/******************************************************************/
/*     Lancement du serveur web  WIFI                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
lancementServeur:                @ INFO: lancementServeur
    push {lr}
    bl cyw43_arch_enable_sta_mode
 
    ldr r0,iadrszSSID            @ etablissement de la connection
    ldr r1,iadrszMdp
    ldr r2,iAuthConn
    ldr r3,iAttente
    bl cyw43_arch_wifi_connect_timeout_ms
    cmp r0,0
    beq 1f
    bkpt 10
1:
    ldr r0,iAdrstate             @ ouverture du serveur 
    bl tcp_server_open
2:                               @ boucle 
    bl sys_check_timeouts
    bl cyw43_arch_poll
    movs r0,100
    bl sleep_ms
    ldr r0,iAdriServeurActif    @ fin de session reçue ?
    ldr r1,[r0]
    cmp r1,1
    bne 2b 
    ldr r0,iAdrstate
    bl tcp_server_close
    bl cyw43_arch_deinit
100:
    pop {pc}
.align 2
//iadrszSSID:      .int szSSSID
iadrszMdp:     .int szMdp
iAttente:     .int 30000
iAuthConn: .int CYW43_AUTH_WPA2_AES_PSK
//iAdriServeurActif:      .int iServeurActif
/******************************************************************/
/*     affichage registre systeme                                 */ 
/******************************************************************/
/* r0 contient la structure state tcp */
.thumb_func
tcp_server_open:            @ INFO:   tcp_server_open
    push {lr}
    mov r4,r0
   
    movs r0,IPADDR_TYPE_ANY
    bl tcp_new_ip_type
    cmp r0,0
    bne 1f
    bkpt 20
1:
    mov r5,r0               @ pcb
    mov r0,r5
    movs r1,0
    movs r2,80              @ port   
    bl tcp_bind
    cmp r0,0
    beq 2f
    bkpt 20
2:   
    mov r0,r5
    movs r1,1
    bl tcp_listen_with_backlog
    mov r4,r0
    cmp r0,0
    bne 3f
    bkpt 20
3:   
    mov r5,r0
 
    ldr r1,iAdrstate
    str r0,[r1,tcp_server_pcb]
    bl tcp_arg
    mov r0,r4
    adr r1,tcp_server_accept
    adds r1,1
    bl tcp_accept
    movs r0,5
    bl ledEclats
    
    movs r0,0
100:
    pop {pc}
.align 2 

iadrszSSID:      .int szSSSID
/******************************************************************/
/*     fonction accept appelé par moteur lwip                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
tcp_server_accept:           @ INFO:   tcp_server_accept
    push {r4,r5,lr}  
    mov r4,r0
    mov r5,r1        @ client_pcb
    cmp r2,0
    beq 1f
    bkpt 25
1:
    cmp r1,0
    bne 2f
    bkpt 25
2:
    ldr r1,iAdrstate
    mov r0,r5
    str r0,[r1,tcp_client_pcb]
    bl tcp_arg
    mov r0,r5
    adr r1,tcp_server_sent
    adds r1,1
    bl tcp_sent
    mov r0,r5
    adr r1,tcp_server_recv
    adds r1,1
    bl tcp_recv
    mov r0,r5
    adr r1,tcp_server_pool
    adds r1,1
    movs r2,POLL_TIME_S
    bl tcp_poll
    mov r0,r5
    adr r1,tcp_server_err
    adds r1,1
    bl tcp_err
    
    ldr r0,iAdrszAnnonce
    bl copieMessage
    movs r0,0       // return ERR_OK sinon lwip signale une erreur
100:
    pop {r4,r5,pc}
.align 2 
iAdrstate:       .int state
iAdrszAnnonce:   .int szAnnonce
/******************************************************************/
/*     fonction envoi appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 longueur message */
.thumb_func
tcp_server_sent:        @ INFO:   tcp_server_sent
    push {lr} 
    
    movs r0,0           @ return ERR_OK sinon lwip signale une erreur
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
tcp_server_recv:             @ INFO:   tcp_server_recv
    push {r4-r7,lr} 
    movs r7,0
    mov r4,r0
    mov r5,r1
    cmp r2,0                 @ buffer packet null ?
    beq 5f
    mov r6,r2
    ldr r0,[r2,pbuf_payload] @ récup des données envoyées
    
    movs r2,0                @ pour eliminer cet envoi
    ldr r1,iAdrszFavicon
1:                           @ boucle pour comparer les caractères 
    ldrb r7,[r0,r2]
    ldrb r3,[r1,r2]
    cmp r3,r7
    bne 2f
    adds r2,1
    cmp r2,LGFAVICON - 1
    blt 1b
    b 4f                     @ libellé egaux on ne fait rien 
2:  
    bl analyserCommande
    mov r7,r0                @ on garde le code retour
4:
    mov r0,r6                @ raz buffer pour liberer place
    bl pbuf_free             @ obligatoire
  
5:                           @ envoi page html 
    mov r0,r4      @ state
    mov r1,r5      @ tcp pcb 
    bl tcp_server_sent_datas
    
    cmp r7,1                 @ si saisie stop ?
    bne 99f
    ldr r1,iAdriServeurActif  @ fermeture cession
    movs r0,1                @ pour indiquer à la boucle principale
    str r0,[r1]              @ qu'il faut s'arrêter
99:
    movs r0,0               @ return ERR_OK sinon lwip signale une erreur
100:
    pop {r4-r7,pc}
.align 2  
iAdrszFavicon:    .int szFavicon
iAdriServeurActif:      .int iServeurActif
/******************************************************************/
/*     fonction pooling appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 pointeur pbuf   */
/* r0 retourne 0 Ok ou 1 fin */
.thumb_func
analyserCommande:                 @ INFO:    analyserCommande
    push {r1-r5,lr} 
    mov r5,sp
    subs r5,80                    @ reserve 80 caractères pour stocker commande
    mov sp,r5                     @ sur la pile
    ldrb r1,[r0,4]                @ si / suivi d'un blanc retour routine
    cmp r1,'/'
    bne 1f
    ldrb r1,[r0,5]
    cmp r1,' '
    bne 1f
    movs r0,0
    b 100f
1:
    movs r2,0                     @ pour analyse commande
    ldr r1,iAdrszCommandeWeb      @ libellé commande
2:                                @ boucle comparaison
    ldrb r4,[r0,r2]
    ldrb r3,[r1,r2]
    cmp r3,r4
    bne 10f
    adds r2,1
    cmp r2,LGCOMMANDEWEB - 1
    blt 2b   
    adds r0,LGCOMMANDEWEB - 1

    movs r2,0
3:                           @ boucle de copie du texte de la commande
    ldrb r3,[r0,r2]
    cmp r3,' '               @ si espace fin texte
    beq 4f
    strb r3,[r5,r2]
    adds r2,1
    b 3b
4:                           @ stocke fin de chaine
    movs r3,0
    strb r3,[r5,r2]
    mov r0,r5                @ debut texte commande 
    bl execCommande          @ pour execution 
    movs r0,0 
    b 100f
    
10:                          @ commande stop ?
    movs r2,0                @ pour analyse commande
    ldr r1,iAdrszCommandeStop
11:                          @ boucle de comparaison
    ldrb r4,[r0,r2]
    ldrb r3,[r1,r2]
    cmp r3,r4
    bne 12f
    adds r2,1
    cmp r2,LGCOMMANDESTOP - 1
    blt 11b   
    // 
    movs r0,1                @ indicateur de fin 
    b 100f
12:                          @ Autre cas  
    movs r0,0  
100:
    movs r5,80               @ libére l'espace reservée
    add sp,r5
    pop {r1-r5,pc}
.align 2 
iAdrszCommandeWeb:  .int szCommandeWeb
iAdrszCommandeStop:  .int szCommandeStop
/******************************************************************/
/*     execution des commandes                                */ 
/******************************************************************/
/* r0  adresse commande saisie*/
.thumb_func
execCommande:                      @ INFO:    tcp_server_pool
    push {r4,lr} 
    mov r4,r0
    ldr r1,iAdrszLibCmdTest
    bl comparerChaines
    cmp r0,0
    bne 1f
    ldr r0,iAdrszCommandeTest      @ commande text
    bl copieMessage
    b 100f
1:
    mov r0,r4
    ldr r1,iAdrszLibCmdHelp
    bl comparerChaines
    cmp r0,0
    bne 2f
    ldr r0,iAdrszListeCom          @ commande help 
    bl copieMessage
    b 100f
2:
    mov r0,r4
    ldr r1,iAdrszLibCmdTemp1
    bl comparerChaines
    cmp r0,0
    bne 3f
    bl testTemp                    @ commande temperature
    ldr r0,iAdrszMessTemp1
    bl copieMessage
    b 100f
3:
    mov r0,r4
    ldr r1,iAdrszLibCmdLedon
    bl comparerChaines
    cmp r0,0
    bne 4f
    movs r0,CYW43_WL_GPIO_LED_PIN  @ commande allumage Led
    movs r1,1
    bl cyw43_arch_gpio_put
    b 100f
4:
    mov r0,r4
    ldr r1,iAdrszLibCmdLedoff       
    bl comparerChaines
    cmp r0,0
    bne 5f                         @ commande extinction Led
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,0
    bl cyw43_arch_gpio_put
    b 100f
5:
    ldr r0,iAdrszCommandeInc
    bl copieMessage

100:
    pop {r4,pc}
.align 2    
iAdrszLibCmdTest:      .int szLibCmdTest
iAdrszCommandeInc:     .int szCommandeInc
iAdrszCommandeTest:    .int szCommandeTest
iAdrszLibCmdHelp:      .int szLibCmdHelp
iAdrszLibCmdLedon:     .int szLibCmdLedon
iAdrszLibCmdLedoff:    .int szLibCmdLedoff
iAdrszListeCom:        .int szListeCom
iAdrszLibCmdTemp1:     .int szLibCmdTemp
iAdrszMessTemp1:       .int szMessTemp
/******************************************************************/
/*     fonction pooling appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_server_pool:        @ INFO:    tcp_server_pool
    push {lr} 

    movs r0,0           @ return ERR_OK
100:
    pop {pc}
.align 2    
/******************************************************************/
/*     fonction envoi des données                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_server_sent_datas:        @ INFO: tcp_server_sent_datas
    push {r1-r7,lr} 
    mov r6,r1
    ldr r4,iOftcp_buffer_sent
    adds r4,r0
    movs r3,0
    movs r2,' '
    ldr r7,iBufSize           @ taille buffer 
1:
    strb r2,[r4,r3]           @ initialise le buffer avec des blancs 
    adds r3,1                 @ pour effacer tout envoi précedent.
    cmp r3,r7
    blt 1b
    movs r3,0
    ldr r5,iAdrszEntete
2:                            @ boucle de recopie de l'entête dans le buffer 
    ldrb r2,[r5,r3]
    strb r2,[r4,r3]
    adds r3,1 
    cmp  r3,TAILLEENTETE    
    blt 2b
   // bl cyw43_arch_lwip_check
    mov r0,r6             @ tcp 
    mov r1,r4
    movs r2,r7
    movs r3,TCP_WRITE_FLAG_COPY
    bl tcp_write                @ envoi message
    cmp r0,0
    beq 3f

    bkpt 20
3:
    movs r0,10
    bl attendre
    movs r3,0
    movs r2,' '
4:
    strb r2,[r4,r3]
    adds r3,1
    cmp r3,r7
    blt 4b
    movs r3,0
    ldr r5,iAdrszLigne1
5:
    ldrb r2,[r5,r3]
    strb r2,[r4,r3]
    adds r3,1 
    cmp  r3,TAILLELIGNE1   
    blt 5b
    movs r1,0
    ldr r5,iAdrszMessageRetour
6:
    ldrb r2,[r5,r1]
    cmp r2,0
    beq 7f
    strb r2,[r4,r3]
    adds r3,1  
    adds r1,1 
    b 6b  
7:
    movs r1,0
    ldr r5,iAdrszLigne2
8:
    ldrb r2,[r5,r1]
    strb r2,[r4,r3]
    adds r3,1 
    adds r1,1
    cmp  r1,TAILLELIGNE2   
    blt 8b 
    
   // bl cyw43_arch_lwip_check
    mov r0,r6         @ tcp 
    mov r1,r4         @ buffer message
    movs r2,r7        @ taille
    movs r3,TCP_WRITE_FLAG_COPY
    bl tcp_write
    cmp r0,0
    beq 6f
    movs r0,100
    bl attendre
    bkpt 20
6:   
    
    movs r0,0         @ return ERR_OK
100:
    pop {r1-r7,pc}
.align 2   
 iAdrszEntete:       .int szEntete
 iAdrszLigne1:       .int szLigne1
 iAdrszLigne2:       .int szLigne2
 iOftcp_buffer_sent:  .int tcp_buffer_sent
 iBufSize:            .int BUF_SIZE   
 /******************************************************************/
/*     fonction erreur appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_server_err:                      @ INFO:    tcp_server_pool
    push {lr} 

    movs r0,0       // return ERR_OK
100:
    pop {pc}
.align 2  
 /******************************************************************/
/*     fonction close                                */ 
/******************************************************************/
/* r0 argument structure state */
.thumb_func
tcp_server_close:                      @ INFO:    tcp_server_close
    push {r1-r5,lr} 
    mov r5,r0
    ldr r1,[r0,tcp_client_pcb]
    cmp r1,0                   @ pointeur pcb client nul ?
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
    mov r0,r4
    bl tcp_abort
1:
    movs r1,0                      @ raz pointeur client  
    str r1,[r5,tcp_client_pcb]
2:
    ldr r4,[r5,tcp_server_pcb]
    cmp r4,0                   @ pointeur pcb serveur nul ?
    beq 3f
    mov r0,r4
    movs r1,0
    bl tcp_arg
    mov r0,r4
    bl tcp_close 
    movs r1,0
    str r1,[r5,tcp_server_pcb]         @ raz pointeur serveur pcb
3:
    movs r0,0       // return ERR_OK
100:
    pop {r1-r5,pc}
.align 2 
 /******************************************************************/
/*     fonction copie dans zone message retour                                 */ 
/******************************************************************/
/* r0 adresse du message */
.thumb_func
copieMessage:                      @ INFO:   copieMessage
    push {r1-r3,lr} 
    ldr r3,iAdrszMessageRetour
    movs r1,0
1:                     @ boucle de copie du message
    ldrb r2,[r0,r1]
    cmp r2,0
    beq 2f
    strb r2,[r3,r1]
    adds r1,1
    cmp r1,LGMESSAGE    @ tronqué à la longeur de la zone  
    bge 100f
    b 1b
2:
    movs r2,' '
3:                      @ raz reste du message
    strb r2,[r3,r1]
    adds r1,1
    cmp r1,LGMESSAGE
    blt 3b
100:
    pop {r1-r3,pc}
.align 2 
iAdrszMessageRetour:  .int szMessageRetour

/******************************************************************/
/*     Température                                           */ 
/******************************************************************/
.thumb_func
testTemp:                  @ INFO: testTemp
    push {r4-r6,lr}
0:
    ldr r2,iAdrAdcBase      @ lancement mesure 
    ldr r1,[r2,ADC_CS]
    ldr r3,iParam           
    orrs r3,r3,r1           @ à revoir utilisation autre adresse
    str r3,[r2,ADC_CS]
    movs r1,1
    lsls r1,8               @ pour bit 8 à 1
1:                          @ boucle attente ok
    ldr r0,[r2,ADC_CS]
    tst r0,r1
    beq 1b
    
    str r3,[r2,ADC_CS]       @ lancement mesure
    
    ldr r4,[r2,ADC_RESULT]

    movs r0,'S'
    movs r1,'F'
    bl appelDatasRom         @ recherche début float fonctions
    mov r5,r0
    ldr r2,[r5,0x34]         @ conversion en float
    movs r0,r4
    blx r2
    
    ldr r1,iCst4
    ldr r2,[r5,8]            @ operateur multiplication
    blx r2
    
    ldr r2,[r5,4]            @ operateur soustraction
    ldr r1,iCst1
    blx r2

    ldr r2,[r5,0xC]          @ opérateur division
    ldr r1,iCst3
    blx r2

    ldr r2,[r5,4]            @ operateur soustraction
    movs r1,r0
    ldr r0,iCst2
    blx r2
    
    mov r6,r0
    
    ldr r2,[r5,0x24]         @ conversion vers entier
    blx r2
    mov r4,r0
    cmp r0,100
    bge 0b
    
    mov r0,r6
    ldr r1,iCst5              @ 10      pour avoir un résultat en dizième de degré
    ldr r2,[r5,8]             @ operateur multiplication
    blx r2
    ldr r2,[r5,0x24]          @ conversion vers entier
    blx r2
                                @ affichage final
    ldr r1,iAdrsZoneTempDec
    bl conversion10
    ldr r0,iAdrszMessTemp
    
    pop {r4-r6,pc}
.align 2
iParam:           .int 0x100007
iCst1:            .float 0.706
iCst2:            .float 27.0
iCst3:            .float 0.001721
iCst4:            .float 0.000805664
iCst5:            .float 10.0
iAdrBasePllUsb:   .int PLL_USB_BASE
iAdrszMessTemp:   .int szMessTemp
iAdrsZoneTempDec: .int sZoneTempDec
/******************************************************************/
/*     initialisation ADC                                         */ 
/******************************************************************/
.thumb_func
initADC:                           @ INFO: initADC 
    push {lr}
    ldr r0,iAdrResetBaseMskSet      @ reset 
    movs r1,2
    str r1,[r0]                     @ reset des zones
    ldr r0,iAdrResetBaseMskClear
    str r1,[r0]
    ldr r2,iAdrResetBase
    movs r0,r1
1:                                  @ boucle attente du reset
    ldr r3,[r2,RESETS_RESET_DONE]
    tst r0,r3
    beq 1b
    
    movs r1,7
    ldr r2,iAdrAdcBase
    str r1,[r2]
    movs r1,1
    lsls r1,8
2:                                 @ boucle attente init 
    ldr r3,[r2]
    tst r3,r1
    beq 2b
    pop {pc}
.align 2
iAdrResetBase:            .int RESETS_BASE
iAdrResetBaseMskSet:      .int RESETS_BASE + 0x2000
iAdrResetBaseMskClear:    .int RESETS_BASE + 0x3000
iAdrAdcBase:              .int ADC_BASE
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
ptDatasTable:           .int 0x16

/************************************/       
/* comparaison de chaines           */
/************************************/      
/* r0 et r1 contiennent les adresses des chaines */
/* retour 0 dans r0 si egalite */
/* retour -1 si chaine r0 < chaine r1 */
/* retour 1  si chaine r0> chaine r1 */
.thumb_func
comparerChaines:          @ INFO: comparerChaines
    push {r2-r4,lr}       @ save des registres
    movs r2, 0            @ indice
1:    
    ldrb r3,[r0,r2]       @ octet chaine 1
    ldrb r4,[r1,r2]       @ octet chaine 2
    cmp r3,r4
    blt 2f
    bgt 3f
    cmp r3, 0             @ 0 final
    beq 4f                @ c est la fin
    adds r2,r2, 1         @ sinon plus 1 dans indice
    b 1b                  @ et boucle
2:
    movs r0, 0            @ plus petite
    subs r0, 1
    b 100f
3:
    movs r0, 1             @ plus grande
    b 100f
4:
    movs r0, 0             @ égale
100:
    pop {r2-r4,pc}

/************************************/
/*       LED  Eclat               */
/***********************************/
/* r0 contient le nombre d éclats   */
.thumb_func
ledEclats:
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


/******************************************************************/
/*     conversion hexa                       */ 
/******************************************************************/
/* r0 contient la valeur */
/* r1 contient la zone de conversion  */
.thumb_func
conversion16:               @ INFO: affRegHexa
    push {r1-r4,lr}         @ save des registres

    movs r2, 28              @ start bit position
    movs r4, 0xF             @ mask
    lsls r4, 28
    movs r3,r0               @ save entry value
1:                           @ start loop
    movs r0,r3
    ands r0,r0,r4            @ value register and mask
    lsrs r0,r2               @ move right 
    cmp r0, 10               @ compare value
    bge 2f
    adds r0, 48              @ <10  ->digit 
    b 3f
2:    
    adds r0, 55              @ >10  ->letter A-F
3:
    strb r0,[r1]             @ store digit on area and + 1 in area address
    adds r1, 1
    lsrs r4, 4               @ shift mask 4 positions
    subs r2,r2, 4            @  counter bits - 4 <= zero  ?
    bge 1b                   @  no -> loop
    movs r0, 8
    pop {r1-r4,pc}           @ restaur des registres


/************************************/
/*       appel des fonctions de la Rom            */
/***********************************/
/* r0 Code 1  */
/* r1 code 2  */
/* r2 parametre fonction 1 */
/* r3 parametre fonction 2 */
/* r4 parametre fonction 3 */
/* TODO: voir si plus de 3 paramètres */
.thumb_func
appelFctRom:
    push {r2-r5,lr}            @ save  registers 
    lsls r1,#8                 @ conversion des codes
    orrs r0,r1
    ldr r1,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r1]               @ sur 2 octets seulement
    ldr r1,ptFunctionTable
    movs r3,#0
    ldrh r3,[r1]               @ sur 2 octets seulement
    movs r1,r0
    movs r0,r3                 @ init des valeurs
    blx r2                     @ recherche fonction à appeler
    movs r5,r0
    ldr r0,[sp]                @ Comme r2 et r3 peuvent être écrasés par l appel précedent
    ldr r1,[sp,4]              @ récupération des paramétres 1 et  2 pour la fonction
    movs r2,r4                 @ parametre 3 fonction
    blx r5                     @ et appel de la fonction trouvée 

    pop {r2-r5,pc}             @ restaur registers
.align 2
ptRom_table_lookup:     .int 0x18
ptFunctionTable:        .int 0x14
/************************************/
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
.thumb_func
attendre:
    lsls r0,r0,16             @ approximatif TODO: à verifier avec le timer
1:
    subs r0,r0, 1
    bne 1b
    bx lr
/******************************************************************/
/*     Conversion base 10               */ 
/******************************************************************/
/* r0 contains value and r1 address area   */
/* r0 return size of result (no zero final in area) */
/* area size => 11 bytes          */
.equ LGZONECAL,   10
conversion10:                @ INFO: conversion10
    push {r1-r4,lr}          @ save registers 
    movs r3,r1
    movs r2,#LGZONECAL
1:                           @ start loop
    bl divisionpar10U        @ unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    adds r1,#48              @ digit
    strb r1,[r3,r2]          @ store digit on area
    cmp r0,#0                @ stop if quotient = 0 
    beq 11f
    subs r2,#1               @ else previous position
    b 1b                     @ and loop
                             @ and move digit from left of area
11:
    movs r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    adds r2,#1
    adds r4,#1
    cmp r2,#LGZONECAL
    ble 2b
                             @ and move spaces in end on area
    movs r0,r4               @ result length 
    movs r1,#' '             @ space
3:
    strb r1,[r3,r4]          @ store space in area
    adds r4,#1               @ next position
    cmp r4,#LGZONECAL
    ble 3b                   @ loop if r4 <= area size
 
100:
    pop {r1-r4,pc}                                    @ restaur registres    
/***************************************************/
/*   division par 10   non signé                    */
/***************************************************/
/* r0 dividende   */
/* r0 quotient    */
/* r1 reste   */
divisionpar10U:                @ INFO: divisionpar10U
    push {r2,r3, lr}
    lsrs r1,r0,1
    lsrs r2,r0,2
    adds r1,r2
    lsrs r2,r1,4
    adds r1,r2
    lsrs r2,r1,8
    adds r1,r2
    lsrs r2,r1,16
    adds r1,r2
    lsrs r3,r1,3  @ q
    movs r2,10
    muls r2,r3,r2
    subs r1,r0,r2    @ r
    adds r0,r1,6
    lsrs r0,4
    add r0,r3
    cmp r1,10
    blt 1f
    subs r1,10
1:
    pop {r2,r3,pc}
    
    
