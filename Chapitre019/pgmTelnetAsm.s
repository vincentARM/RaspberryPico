/* Programme assembleur ARM Raspberry pico */
/*  gestion terminal telnet ultra léger */

/* compiler avec le sdk C  pour insertion bibliotheque wifi et lwip */
/* 5 eclairs de la led si la connexion WIFI est OK */
/* 10 eclairs il y a un problème */
/* lancer avec putty picotelnet   */
 

.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"

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
szLibCmdTest:      .asciz "test"
szLibCmdHelp:      .asciz "help"
szLibCmdTemp:      .asciz "temp"
szLibCmdFin:       .asciz "fin"
szLibCmdLedon:     .asciz "ledon"
szLibCmdLedoff:    .asciz "ledoff"
szListeCom:        .asciz "\r\ntest\r\ntemp\r\nledon\r\nledoff\r\nhelp\r\nfin"
szFinCommande:     .asciz "Fin telnet."

szSSSID:           .asciz "XXXX"
szMdp:             .asciz "abcdefghijklm"
szAnnonce:         .asciz "\r\nEntrez une commande : help pour la liste >"
szCommandeInc:     .asciz "\r\nCommande inconnue, help pour la liste."                
szCommandeTest:    .asciz "\r\nCommande test OK.\r\n"
szRetourCodes:     .asciz " "

szMessTemp:       .ascii "\r\nTemperature (en dixieme de degres) = "
sZoneTempDec:     .asciz "             "
.align 4
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iServeurActif:  .skip 4
sBuffer:        .skip 20 
state:          .skip tcp_end
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main
.thumb_func
main:                           @ routine
    bl stdio_init_all

    bl cyw43_arch_init
    cmp r0,0
    beq 1f

    bkpt 5

1:
    bl initADC
    bl lancementServeur
                                @  reset du pico 
    movs r0,'U'                 @ code reset USB
    movs r1,'B'
    movs r2,0
    movs r3,0
    movs r4,0
    bl appelFctRom
 

100:                            @ boucle pour fin de programme standard  
    b 100b
.align 2


/******************************************************************/
/*     Lancement du serveur web  WIFI                                 */ 
/******************************************************************/
/* test commande aff */
.thumb_func
lancementServeur:                @ INFO: lancementServeur
    push {lr}
    bl cyw43_arch_enable_sta_mode
    ldr r0,iadrszSSID
    ldr r1,iadrszMdp
    ldr r2,iAuthConn
    ldr r3,iAttente
    bl cyw43_arch_wifi_connect_timeout_ms
    cmp r0,0
    beq 1f
    bkpt 10
1:
    
    ldr r0,iAdrstate
    bl tcp_server_open

2:
    bl sys_check_timeouts
    bl cyw43_arch_poll
    movs r0,100
    bl sleep_ms
    ldr r0,iAdriServeurActif1     @ fin de session reçue ?
    ldr r1,[r0]
    cmp r1,1
    bne 2b
    
    ldr r0,iAdrstate
    bl tcp_server_close

    bl cyw43_arch_deinit
100:
    pop {pc}
.align 2
iadrszMdp:     .int szMdp
iAttente:     .int 30000
iAuthConn: .int CYW43_AUTH_WPA2_AES_PSK
iAdriServeurActif1:      .int iServeurActif
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
    mov r5,r0      @ pcb
    mov r0,r5
    movs r1,0
    movs r2,23       @ port   
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

    movs r0,5       // serveur OK
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
    
    movs r0,0       // return ERR_OK
100:
    pop {r4,r5,pc}
.align 2 
iAdrstate:        .int state
iAdrszAnnonce1:   .int szAnnonce
/******************************************************************/
/*     fonction envoi appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 longueur message */
.thumb_func
tcp_server_sent:           @ INFO:   tcp_server_sent
    push {lr} 
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
tcp_server_recv:              @ INFO:   tcp_server_recv
    push {r4-r7,lr} 
    movs r7,0
    mov r4,r0
    mov r5,r1
    cmp r2,0                 @ buffer packet null ?
    beq 5f
    mov r6,r2
 
    ldr r0,[r2,pbuf_payload] @ récup des données envoyées
    movs r7,0
    ldrb r2,[r0]
    cmp r2,255                @ codes commandes telnet
    bne 1f            
    mov r0,r6                 @ raz buffer pour liberer place
    bl pbuf_free
    mov r0,r4                 @ state
    mov r1,r5                 @ tcp pcb 
    ldr r2,iAdrszAnnonce2
    bl envoyer_message_telnet
    
    b 99f
1:
    ldrb r2,[r0]
    cmp r2,0x0D                @ code
    bne 2f
    ldrb r2,[r0,1]
    cmp r2,0x0A                @ code
    bne 2f    
    mov r0,r6                 @ raz buffer pour liberer place
    bl pbuf_free  
    b 99f
2:  
    ldrh r2,[r6,pbuf_len]     @ longueur chaine reçue
    bl execCommande
    mov r7,r0
4:
    mov r0,r6                 @ raz buffer pour liberer place
    bl pbuf_free
  
5:                            @ envoi données
    mov r0,r4                 @ state
    mov r1,r5                 @ tcp pcb 
    ldr r2,iAdrszAnnonce2
    bl envoyer_message_telnet
    
99:
    movs r0,0                 @ return ERR_OK 
100:
    pop {r4-r7,pc}
.align 2  
iAdrszRetourCodes:      .int szRetourCodes
iAdrszAnnonce2:         .int szAnnonce
 /******************************************************************/
/*     fonction erreur appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_server_err:                 @ INFO:    tcp_server_err
    push {lr} 
    mov r2,r0
    movs r0,10
    bl ledEclats
    mov r0,r2
    bl tcp_server_close

    movs r0,0                   @ return ERR_OK
100:
    pop {pc}
.align 2 
/******************************************************************/
/*     fonction pooling appelé par moteur lwip                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
.thumb_func
tcp_server_pool:                      @ INFO:    tcp_server_pool
    push {lr} 

    movs r0,0       @ return ERR_OK
100:
    pop {pc}
.align 2

/******************************************************************/
/*     execution des commandes                                */ 
/******************************************************************/
/* r0  adresse commande saisie*/
/* r1  tcp  */
/* r2  longueur commande reçue */
.thumb_func
execCommande:                      @ INFO:    execCommande
    push {r4-r6,lr} 
    mov r6,sp
    subs r6,80              @ reserve 80 caractères pour stocker commande
    mov sp,r6
    mov r5,r1
    movs r3,0
1:
    ldrb  r7,[r0,r3]
    strb  r7,[r6,r3]    
    adds r3,1
    cmp r3,r2
    blt 1b
    movs r7,0
    strb  r7,[r6,r3]
    mov r4,r6
    
    mov r0,r4
    ldr r1,iAdrszLibCmdTest
    bl comparerChaines
    cmp r0,0
    bne 1f
    mov r0,r4
    mov r1,r5
    ldr r2,iAdrszCommandeTest
    bl envoyer_message_telnet
    movs r0,0
    b 100f
1:
    mov r0,r4
    ldr r1,iAdrszLibCmdHelp
    bl comparerChaines
    cmp r0,0
    bne 2f
    mov r0,r4
    mov r1,r5
    ldr r2,iAdrszListeCom
    bl envoyer_message_telnet
    movs r0,0
    b 100f
2:
    mov r0,r4
    ldr r1,iAdrszLibCmdFin
    bl comparerChaines
    cmp r0,0
    bne 3f
    mov r0,r4
    mov r1,r5
    ldr r2,iAdrszFinCommande
    bl envoyer_message_telnet
    ldr r1,iAdriServeurActif      @ fermeture cession
    movs r0,1
    str r0,[r1]
    movs r0,0
    b 100f
3:
    mov r0,r4
    ldr r1,iAdrszLibCmdLedon
    bl comparerChaines
    cmp r0,0
    bne 4f
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,1
    bl cyw43_arch_gpio_put
    movs r0,0
    b 100f
4:
    mov r0,r4
    ldr r1,iAdrszLibCmdLedoff
    bl comparerChaines
    cmp r0,0
    bne 5f
    movs r0,CYW43_WL_GPIO_LED_PIN
    movs r1,0
    bl cyw43_arch_gpio_put
    movs r0,0
    b 100f
5:
    mov r0,r4
    ldr r1,iAdrszLibCmdTemp
    bl comparerChaines
    cmp r0,0
    bne 6f
    bl testTemp
    mov r0,r4
    mov r1,r5
    ldr r2,iAdrszMessTemp
    bl envoyer_message_telnet
    movs r0,0
    b 100f
6:
    mov r0,r4
    mov r1,r5
    ldr r2,iAdrszCommandeInc
    bl envoyer_message_telnet
    movs r0,0
100:
    movs r6,80
    add sp,r6
    pop {r4-r6,pc}
.align 2    
iAdrszLibCmdTest:      .int szLibCmdTest
iAdrszCommandeTest:    .int szCommandeTest
iAdrszLibCmdHelp:      .int szLibCmdHelp
iAdrszListeCom:        .int szListeCom
iAdrszFinCommande:     .int szFinCommande
iAdrszLibCmdFin:        .int szLibCmdFin
iAdrszLibCmdLedon:      .int szLibCmdLedon
iAdrszLibCmdLedoff:     .int szLibCmdLedoff
iAdrszLibCmdTemp:       .int szLibCmdTemp
iAdrszCommandeInc:      .int szCommandeInc
iAdriServeurActif:      .int iServeurActif 
/******************************************************************/
/*     fonction envoi des données                                 */ 
/******************************************************************/
/* r0 argument structure state */
/* r1 tcp pcb   */
/* r2 adresse du message */
.thumb_func
envoyer_message_telnet:        @ INFO: envoyer_message_telnet
    push {r1-r7,lr} 
    movs r3,0             @ taille message
1:                        @ calcul taille message
    ldrb r4,[r2,r3]
    cmp r4,0
    beq 2f
    adds r3,1
    b 1b
2:
    adds r3,1
    mov r0,r1             @ tcp 
    mov r1,r2             @ adresse message 
    movs r2,r3            @ taille message
    movs r3,TCP_WRITE_FLAG_COPY
    bl tcp_write
    cmp r0,0
    beq 3f
    bkpt 20
3:
    movs r0,10
    bl attendre
    
    movs r0,0             @ return ERR_OK
100:
    pop {r1-r7,pc}    
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
    movs r0,0       @ return ERR_OK
100:
    pop {r1-r5,pc}
.align 2 
 
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
/*       boucle attente            */
/***********************************/
/* r0 valeur en milliseconde   */
/* r1 non sauvegardé */
.thumb_func
attendre:                     @ INFO: attendre
    lsls r1,r0,15             @ approximatif 
    lsls r0,r0,13
    adds r0,r1
1:
    subs r0,r0, 1
    bne 1b
    bx lr
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
//ptRom_table_lookup:     .int 0x18
ptDatasTable:           .int 0x16

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
appelFctRom:                  @ INFO: appelFctRom
    push {r2-r5,lr}           @ save  registers 
    lsls r1,#8                @ conversion des codes
    orrs r0,r1
    ldr r1,ptRom_table_lookup
    movs r2,#0
    ldrh r2,[r1]
    ldr r1,ptFunctionTable
    movs r3,#0
    ldrh r3,[r1]
    movs r1,r0
    movs r0,r3        // init des valeurs
    blx r2            // recherche fonction à appeler
    movs r5,r0
    ldr r0,[sp]       // Comme r2 et r3 peuvent être écrasés par l'appel précedent
    ldr r1,[sp,4]       // récupération des paramétres 1 et  2 pour la fonction
    movs r2,r4        // parametre 3 fonction
    blx r5            // et appel de la fonction trouvée 

    pop {r2-r5,pc}             @ restaur registers
.align 2
ptFunctionTable:        .int 0x14
ptRom_table_lookup:     .int 0x18 
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
    
