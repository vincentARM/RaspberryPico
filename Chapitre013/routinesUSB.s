/* Routines gestion communication USB */
/* il faut lancer le script python sous pico/projets.P_USB */
/*  Envoi message après reception du Pret */ 
/* gestion réponse */
.syntax unified
.cpu cortex-m0plus
.thumb
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPico.inc"
.equ MAIN_CTRL,          0x40
.equ SIE_CTRL,           0x4C
.equ SIE_STATUS,         0x50

.equ PPB_BASE,   0xe0000000
.equ PPB_CPUID,  0xed00
.equ PPB_VTOR,   0xed08
.equ M0PLUS_NVIC_ISER_OFFSET, 0x0000e100
.equ M0PLUS_NVIC_ICPR_OFFSET, 0x0000e280
.equ M0PLUS_NVIC_ICER_OFFSET, 0x0000e180


.equ USB_BUFF_STATUS,    0x58
.equ USB_MUXING,         0x74
.equ USB_PWR,            0x78
.equ USB_INTR,           0x8C
.equ USB_INTE,           0x90
.equ USB_INTF,           0x94
.equ USB_INTS,           0x98
.equ USB_NUM_ENDPOINTS, 16

.equ USBCTRL_DPRAM_BASE, 0x50100000
.equ USB_DPRAM_SIZE,     4096
.equ USBCTRL_BASE,       0x50100000
.equ USBCTRL_REGS_BASE,  0x50110000

.equ USB_USB_MUXING_TO_PHY_BITS,   0x00000001
.equ USB_USB_MUXING_SOFTCON_BITS,   0x00000008
.equ USB_MAIN_CTRL_CONTROLLER_EN_BITS,   0x00000001
.equ USB_SIE_CTRL_EP0_INT_1BUF_BITS,   0x20000000
.equ USB_SIE_CTRL_PULLUP_EN_BITS,    0x00010000
.equ USB_SIE_STATUS_SETUP_REC_BITS,   0x00020000
.equ USB_SIE_STATUS_BUS_RESET_BITS,   0x00080000

.equ USB_INTS_BUFF_STATUS_BITS,   0x00000010
.equ USB_INTS_BUS_RESET_BITS,     0x00001000
.equ USB_INTS_SETUP_REQ_BITS,     0x00010000
 

.equ USB_USB_PWR_VBUS_DETECT_BITS,   0x00000004
.equ USB_USB_PWR_VBUS_DETECT_OVERRIDE_EN_BITS,   0x00000008
.equ USBCTRL_IRQ,      5

.equ USB_DT_DEVICE,    0x01
.equ USB_DT_CONFIG,    0x02
.equ USB_DT_STRING,    0x03
.equ USB_DT_INTERFACE, 0x04
.equ USB_DT_ENDPOINT,  0x05

.equ USB_TRANSFER_TYPE_CONTROL,     0x0
.equ USB_TRANSFER_TYPE_ISOCHRONOUS, 0x1
.equ USB_TRANSFER_TYPE_BULK,        0x2
.equ USB_TRANSFER_TYPE_INTERRUPT,   0x3
.equ USB_TRANSFER_TYPE_BITS,        0x3

.equ USB_BUF_CTRL_FULL,      0x00008000
.equ USB_BUF_CTRL_LAST,      0x00004000
.equ USB_BUF_CTRL_DATA0_PID, 0x00000000
.equ USB_BUF_CTRL_DATA1_PID, 0x00002000
.equ USB_BUF_CTRL_SEL,       0x00001000
.equ USB_BUF_CTRL_STALL,     0x00000800
.equ USB_BUF_CTRL_AVAIL,     0x00000400
.equ USB_BUF_CTRL_LEN_MASK,  0x000003FF
.equ USB_BUF_CTRL_LEN_LSB,   0

.equ USB_REQUEST_GET_STATUS, 0x0
.equ USB_REQUEST_CLEAR_FEATURE, 0x01
.equ USB_REQUEST_SET_FEATURE, 0x03
.equ USB_REQUEST_SET_ADDRESS, 0x05
.equ USB_REQUEST_GET_DESCRIPTOR, 0x06
.equ USB_REQUEST_SET_DESCRIPTOR, 0x07
.equ USB_REQUEST_GET_CONFIGURATION, 0x08
.equ USB_REQUEST_SET_CONFIGURATION, 0x09
.equ USB_REQUEST_GET_INTERFACE, 0x0a
.equ USB_REQUEST_SET_INTERFACE, 0x0b
.equ USB_REQUEST_SYNC_FRAME, 0x0c

.equ USB_DIR_OUT, 0x00
.equ USB_DIR_IN,  0x80

.equ EP0_IN_ADDR,  (USB_DIR_IN  | 0)
.equ EP0_OUT_ADDR, (USB_DIR_OUT | 0)
.equ EP1_OUT_ADDR, (USB_DIR_OUT | 1)
.equ EP2_IN_ADDR,  (USB_DIR_IN  | 2)

.equ EP_CTRL_ENABLE_BITS, (1u << 31u)
.equ EP_CTRL_DOUBLE_BUFFERED_BITS, (1u << 30)
.equ EP_CTRL_INTERRUPT_PER_BUFFER, (1u << 29)
.equ EP_CTRL_INTERRUPT_PER_DOUBLE_BUFFER, (1u << 28)
.equ EP_CTRL_INTERRUPT_ON_NAK, (1u << 16)
.equ EP_CTRL_INTERRUPT_ON_STALL, (1u << 17)
.equ EP_CTRL_BUFFER_TYPE_LSB, 26
.equ EP_CTRL_HOST_INTERRUPT_INTERVAL_LSB, 16

.equ CLOCKS_BASE, 0x40008000

.equ SPINLOCK9,    0x124 
/********************************************/
/*        STRUCTURES                  */
/********************************************/
/* structures USB device dpram  */
    .struct  0
udpd_setup_packet:                                 @ 
    .struct  udpd_setup_packet + 8 
udpd_ctrl:                                 @ In + out 
    .struct  udpd_ctrl + 8 * (USB_NUM_ENDPOINTS - 1)
udpd_buf_ctrl:                                 @ In + out 
    .struct  udpd_buf_ctrl + 8 * (USB_NUM_ENDPOINTS)
udpd_ep0_buf_a:                                 @ 
    .struct  udpd_ep0_buf_a + 64                @  0x40
udpd_ep0_buf_b:                                 @ 
    .struct  udpd_ep0_buf_b + 64                @  0x40
udpd_epx_data:                                  @ 
    .struct  udpd_epx_data + ( USB_DPRAM_SIZE - 0x180)          @ 
udpd_fin:

/* structures USB setup packet  */
    .struct  0
pkt_bmRequestType:                                 @ 
    .struct  pkt_bmRequestType + 1
pkt_bRequest:                                 @ 
    .struct  pkt_bRequest + 1
pkt_wValue:                                 @ 
    .struct  pkt_wValue + 2
pkt_wIndex:                                 @ 
    .struct  pkt_wIndex + 2
pkt_wLength:                                 @ 
    .struct  pkt_wLength + 2

/* structure usb_device_descriptor  */
    .struct  0
udd_bLength:                                 @ taille de la structure
    .struct  udd_bLength + 1 
udd_bDescriptorType:                         @ 
    .struct  udd_bDescriptorType + 1 
udd_bcdUSB:                         @ 
    .struct  udd_bcdUSB + 2
udd_bDeviceClass:                         @ 
    .struct  udd_bDeviceClass + 1 
udd_bDeviceSubClass:                         @ 
    .struct  udd_bDeviceSubClass + 1 
udd_bDeviceProtocol:                         @ 
    .struct  udd_bDeviceProtocol + 1 
udd_bMaxPacketSize0:                         @ 
    .struct  udd_bMaxPacketSize0 + 1 
udd_idVendor:                         @ 
    .struct  udd_idVendor + 2 
udd_idProduct:                         @ 
    .struct  udd_idProduct + 2
udd_bcdDevice:                         @ 
    .struct  udd_bcdDevice + 2
udd_iManufacturer:                         @ 
    .struct  udd_iManufacturer + 1
udd_iProduct:                         @ 
    .struct  udd_iProduct + 1
udd_iSerialNumber:                         @ 
    .struct  udd_iSerialNumber + 1
udd_bNumConfigurations:                         @ 
    .struct  udd_bNumConfigurations + 1
udd_fin:

/* structure usb_endpoint_descriptor  */
    .struct  0
ued_bLength:                                 @ taille de la structure 7
    .struct  ued_bLength + 1 
ued_bDescriptorType:                         @ 
    .struct  ued_bDescriptorType + 1 
ued_bEndpointAddress:                        @ 
    .struct  ued_bEndpointAddress + 1 
ued_bmAttributes:                            @ 
    .struct  ued_bmAttributes + 1 
ued_wMaxPacketSize:                          @ 
    .struct  ued_wMaxPacketSize + 2 
ued_bInterval:                               @ 
    .struct  ued_bInterval + 1 
ued_fin:

/* structure usb_endpoint_configuration      */ 
    .struct  0
uec_descriptor:                       @ 
    .struct  uec_descriptor + 4
uec_handler:                       @ 
    .struct  uec_handler + 4
uec_endpoint_control:                       @ 
    .struct  uec_endpoint_control + 4
uec_buffer_control:                       @ 
    .struct  uec_buffer_control + 4
uec_data_buffer:                       @ 
    .struct  uec_data_buffer + 4
uec_next_pid:                       @ 
    .struct  uec_next_pid + 4
uec_fin:
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szLibPret:        .asciz "#Pret#"   @ host est pret
szLibAtt:         .asciz "#Att#"    @ host attend message
szLibRep:         .asciz "#Rep#"     @ client attend reponse du host
.align 4
.global iHostOK
iHostOK:             .int 0
iAdrEnvoiHost:       .int 0
iAdrReponseHost:     .int 0
should_set_address:  .int FALSE
iConfigured:         .int FALSE

bDev_addr:           .byte  0
device_descriptor:
bLength:             .byte         18  @ longueur structure device
bDescriptorType:     .byte  USB_DT_DEVICE
bcdUSB:              .hword 0x0110 // USB 1.1 device
bDeviceClass:        .byte 0      // Specified in interface descriptor
bDeviceSubClass:     .byte  0      // No subclass
bDeviceProtocol:     .byte  0      // No protocol
bMaxPacketSize0:     .byte  64     // Max packet size for ep0
idVendor:            .hword 0x0000 // Your vendor id
idProduct:           .hword 0x0001   // Your product ID
bcdDevice:           .hword   0      // No device revision number
iManufacturer:       .byte   1      // Manufacturer string index
iProduct:            .byte   2      // Product string index
iSerialNumber:       .byte   0        // No serial number
bNumConfigurations:  .byte  1    // One configuration
.equ LGDEVICE,    . - device_descriptor

interface_descriptor:
int_bLength:            .byte  9
int_bDescriptorType:    .byte USB_DT_INTERFACE
int_bInterfaceNumber:   .byte 0
int_bAlternateSetting:  .byte 0
int_bNumEndpoints:      .byte 2    // Interface has 2 endpoints
int_bInterfaceClass:    .byte 0xff // Vendor specific endpoint
int_bInterfaceSubClass: .byte 0
int_bInterfaceProtocol: .byte 0
int_iInterface:         .byte 0
.equ LGINTERFACE,    . - interface_descriptor

.align 4
config_descriptor:
confd_bLength:          .byte   9
confd_bDescriptorType:  .byte  USB_DT_CONFIG
confd_wTotalLength:     .hword  32 @ 9 + 9 + 14 @ =(sizeof(config_descriptor) +
                           @ sizeof(interface_descriptor) +
                           @ sizeof(ep1_out) +
                           @ sizeof(ep2_in)),
confd_bNumInterfaces:      .byte  1
confd_bConfigurationValue: .byte  1 // Configuration 1
confd_iConfiguration:      .byte 0     // No string
confd.bmAttributes:        .byte 0x80   // attributes: self powered, no remote wakeup
                                        // TODO: Modif ancien 0xC0
confd.bMaxPower:           .byte 0x32         // 100 ma
.equ  LGCONFDESC,    . - config_descriptor

stVendor:   .asciz        "Raspberry Pi"    // Vendor
stProduct:  .asciz        "Pico Test Device" // Product

ep0_out: 
             .byte 7   @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_OUT_ADDR // EP number 0, OUT from host (rx to device)
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  64
             .byte  0
  .equ LGDESCRIPT,   . - ep0_out
ep0_in: 
             .byte 7   @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_IN_ADDR // EP number 0, OUT from host (rx to device)
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  64
             .byte  0
ep1_out: 
             .byte 7   @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP1_OUT_ADDR // EP number 0, OUT from host (rx to device)
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64
             .byte  0

ep2_in: 
             .byte 7   @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP2_IN_ADDR // EP number 0, OUT from host (rx to device)
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64
             .byte  0
.align 4
dev_config:
cfg_device_descriptor:     .int device_descriptor
cfg_interface_descriptor:  .int interface_descriptor
cfg_config_descriptor:     .int config_descriptor
cfg_lang_descriptor:       .byte   4,  0x03, 0x09, 0x04 @ length, bDescriptorType == String Descriptor,
                                        @ language id = us english
cfg_descriptor_strings:    .int stVendor
                           .int stProduct
cfg_endpoints:
                        .int ep0_out            @ type EP0 reception
                        .int ep0OutHandler      @ adresse fonction à appeler 
                        .int 0                  @ NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl + 4
                        @ EP0 in and out share a data buffer
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
    .equ LGCFGENDPOINT, . - cfg_endpoints
             //2ième
                        .int ep0_in            @ type EPO émission
                        .int ep0inhandler
                        .int 0                 @  NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl
                        @ EP0 in and out share a data buffer
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
             //3ième
                        .int ep1_out
                        .int ep1OutHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl+4   @ out
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+8+4  @ poste 1 out
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data  @ 
                        .int 0
             // 4ième
                        .int ep2_in
                        .int ep2InHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl+8   @ in poste 1
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+16 @ in poste 2
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data+64
                        .int 0
             // fin
                        .fill LGCFGENDPOINT * 28,1,0  @ 28 + les 4 endpoints définis ci dessus = 32 
sEp0_buf:    .fill 64,1,0      @ buffer intermèdiaire pour les envois de données

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global initUsbDevice
/*****************************************************************************/
/*   initialisation UDB voir chapitre 4.1.3 datasheet RP2040                 */
/*****************************************************************************/
.thumb_func
initUsbDevice:                           @ INFO: initUsbDevice
    push {r4-r6,lr}

                                    @ initialisation horloge USB
    ldr r3,iAdrClocksSet
    movs r1,0x43
    lsls r1,5                       @ pour 860   OK Ok

    movs r0,0
    ldr r2,iAdrDpramBase @ adresse dram
    ldr r4,iUdpd_fin     @ taille 
    movs r3,0            @ valeur
1:
    str r3,[r2,r0]
    adds r0,4
    cmp r0,r4
    blt 1b
    
    //movs r0,5          @ USB IRQ
    //ldr r1,iAdrIsrIRQ
    //bl setIRQ
    movs r0,5+16         @ N° du poste IRQ USB dans la table des vecteurs
    lsls r0,2            @ 4 octets par poste 
    ldr r1,iAdrIsrIRQ    @ adresse de la fonction à appeler
    ldr r2,iAdrVtor      @ adresse du registre contenant l'adresse table des vecteurs
    ldr r2,[r2]          @ charge l'adresse de la table
    str r1,[r2,r0]       @ stocke l'adresse de la fonction dans le bon poste 

    movs r1,1            @  autoriser IRQ 
    lsls r1,USBCTRL_IRQ
    ldr r0,iAdrNvicIcpr
    str r1,[r0]
    ldr r0,iAdrNvicIser
    str r1,[r0]
    
    ldr r0,iAdrUsbRegsBase   @ ?????
    ldr r1,iUsbMuxing
    str r1,[r0,USB_MUXING]
    
    ldr r1,iParVbus
    str r1,[r0,USB_PWR]
    
    movs r1,USB_MAIN_CTRL_CONTROLLER_EN_BITS
    str r1,[r0,MAIN_CTRL]
    
    ldr r1,iParSie
    str r1,[r0,SIE_CTRL]
    
    ldr r1,iParInte         @ autorise l'interruption usb 
    ldr r0,iAdrUsbInte
    str r1,[r0]

    bl usbSetupEndpoints    @ met à jour les endpoints en fonction de la table 
    
    ldr r1,iParSieCtrl
    ldr r0,iAdrSieCtrl
    str r1,[r0]
    
    //movs r0,2
    //bl ledEclats
att:                         @ boucle d'attente de la validié de la connexion USB
    ldr r0,iAdriConfigured1  @ pendant ce temps le host envoie les messages de configuration
    ldr r1,[r0]              @ qui sont traités par la fonction d'interruption
    cmp r1,TRUE
    bne att
                               @ envoi ready au host 
    movs r0,EP1_OUT_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,64
    bl usbstarttransfert
    
    pop {r4-r6,pc} 
.align 2
iAdriConfigured1:      .int iConfigured
iAdrIsrIRQ:           .int isrIrq5
iAdrClocksSet:        .int CLOCKS_BASE + 0x2000
iAdrSieCtrl:          .int USBCTRL_REGS_BASE + 0x2000 + SIE_CTRL
iUsbMuxing:           .int USB_USB_MUXING_TO_PHY_BITS | USB_USB_MUXING_SOFTCON_BITS
iUdpd_fin:            .int udpd_fin / 4
iAdrPPBBase:          .int PPB_BASE
iParVbus:             .int USB_USB_PWR_VBUS_DETECT_BITS | USB_USB_PWR_VBUS_DETECT_OVERRIDE_EN_BITS
iParSie:              .int USB_SIE_CTRL_EP0_INT_1BUF_BITS
iParInte:             .int USB_INTS_BUFF_STATUS_BITS | USB_INTS_BUS_RESET_BITS | USB_INTS_SETUP_REQ_BITS
iParSieCtrl:          .int USB_SIE_CTRL_PULLUP_EN_BITS
iAdrUsbInte:          .int USBCTRL_REGS_BASE + USB_INTE
iAdrNvicIser:         .int PPB_BASE  + M0PLUS_NVIC_ISER_OFFSET
iAdrNvicIcpr:         .int PPB_BASE  + M0PLUS_NVIC_ICPR_OFFSET
iAdrVtor:             .int PPB_BASE + PPB_VTOR
/*****************************************************************************/
/*   initialisation EndPoints voir chapitre 4.1.3 datasheet RP2040                 */
/*****************************************************************************/
.thumb_func
usbSetupEndpoints:                           @ INFO: usbSetupEndpoints
    push {r4-r6,lr}
    ldr  r4,iAdrEndpoints      @ dev_config.endpoints
    movs r5,0
    movs r6,uec_fin           @ longueur
1:                            @ début de boucle de balayage des endpoints
    mov r3,r6
    muls r3,r5,r3
    add r3,r4                  @ calcul adresse de chaque endpoint
    
    ldr r1,[r3,uec_descriptor] @ descriptor présent ?
    cmp r1,0
    beq 2f
    ldr r1,[r3,uec_handler]    @ handler présent
    cmp r1,0
    beq 2f
    mov r0,r3
    bl usbSetupEndpoint        @ traitement de chaque endpoint
2:
    adds r5,r5,1
    cmp r5,USB_NUM_ENDPOINTS
    blt 1b                     @ et boucle
    
    pop {r4-r6,pc} 

/*****************************************************************************/
/*   initialisation un seul  EndPoint voir chapitre 4.1.3 datasheet RP2040                 */
/*****************************************************************************/
/* r0 contient usb_endpoint_configuration  */
.thumb_func
usbSetupEndpoint:                 @ INFO: usbSetupEndpoint
    push {r4-r6,lr}
    mov r4,r0
 
    ldr r1,[r4,uec_endpoint_control]
    cmp r1,0
    beq 100f 
    
    ldr r3,[r4,uec_data_buffer]
    ldr r1,iAdrDpramBase
    subs r3,r1  
    ldr r1,iValCtrlEnable
    orrs r3,r1
    ldr r1,iValCtrlInter
    orrs r3,r1
    ldr r1,[r4,uec_descriptor]
    adds r1,ued_bmAttributes
    
    ldrb r1,[r1]
    
    lsls r1,EP_CTRL_BUFFER_TYPE_LSB
    orrs r3,r1
    ldr r4,[r4,uec_endpoint_control]
    str r3,[r4]                    @  
    
100: 
    pop {r4-r6,pc} 
.align 2
iValCtrlInter:     .int EP_CTRL_INTERRUPT_PER_BUFFER
iValCtrlEnable:    .int EP_CTRL_ENABLE_BITS
iAdrDpramBase:     .int USBCTRL_DPRAM_BASE
/******************************************************************/
/*     envoi message                                              */ 
/*  ATTENTION : longueur des messages limité à 64 caractères     */
/******************************************************************/
/*    r0 contient l'adresse du message                */
.global envoyerMessage
.thumb_func
envoyerMessage:               @ INFO: envoyerMessage
    push {r1-r3,lr}
    movs r2,r0
    ldr r3,iAdriAdrEnvoiHost    @ adresse du message à envoyer au Host
1:                            @ boucle attente que message précédent soit parti
    movs r0,1
    bl attendre 
    ldr r0,[r3]
    cmp r0,0
    bne 1b
    str r2,[r3]                 @ stockage adresse du nouveau message

    pop {r1-r3,pc}
/******************************************************************/
/*     demande de reponse message                                              */ 
/*  ATTENTION : longueur des messages limité à 64 caractères     */
/******************************************************************/
/*    r0 contient l'adresse du buffer de reception                */
.global recevoirReponse
.thumb_func
recevoirReponse:               @ INFO: recevoirReponse
    push {r0-r3,lr}
    movs r2,r0
    ldr r3,iAdriAdrReponseHost    @ adresse du buffer 
    str r0,[r3]
1:                            @ boucle attente que message précédent soit parti
    movs r0,1
    bl attendre 
    ldr r0,[r3]
    cmp r0,0
    bne 1b
    movs r0,0
    str r0,[r3]                 @ stockage adresse du nouveau message

    pop {r0-r3,pc}
.align 2
/******************************************************************/
/*     fonction endpoint 0 In                                      */ 
/******************************************************************/
/*  r0 adresse buffer r1 taille                  */
.thumb_func
ep0inhandler:                    @ INFO: ep0inhandler
    push {r4,lr}

    ldr r2,iAdrShould_set_address @ adresse attribuée doit être stockée ?
    ldr r3,[r2] 
    cmp r3,FALSE                  @ non
    beq 1f

    ldr r3,iAdrbDev_addr          @ oui donc on la stocke 
    ldrb r3,[r3]
    ldr r0,iAdrUsbRegsBase        @ dans ce registre mémoire
    str r3,[r0]                   @ correspond au registre dev_addr_ctrl
    movs r1,FALSE                 @ et on met le top à faux
    str r1,[r2]
    b 100f
1:
    movs r0,EP0_OUT_ADDR      @ envoi Ok
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,0
    bl usbstarttransfert

100:

    pop {r4,pc}
.align 2
iAdrUsbRegsBase:      .int USBCTRL_REGS_BASE
/******************************************************************/
/*     recherche endpoint correspondant à l adresse                                       */ 
/******************************************************************/
/*  r0 adresse                   */
/* r0 retourne adresse du endpoint trouvé */
.thumb_func
usbgetendpointconfiguration:          @ INFO: usbgetendpointconfiguration
    push {r4,r5,lr}
    ldr r1,iAdrEndpoints              @ adresse des endpoints
    movs r3,0
    movs r2,uec_fin                   @ longueur
1:                                    @ boucle de recherche
    movs r4,r3
    muls r4,r2,r4
    adds r4,r1                        @ calcul adresse du endpoint courant
    ldr r5,[r4,uec_descriptor]
    ldrb r5,[r5,ued_bEndpointAddress]
    cmp r5,r0                         @ pas d'adresse ?
    beq 2f
    adds r3,1
    cmp r3,USB_NUM_ENDPOINTS
    blt 1b
    b 100f
2:
    mov r0,r4                         @ retourne adresse du endpoint trouvé
100:
    pop {r4,r5,pc}
.align 2
iAdrEndpoints:    .int cfg_endpoints
/******************************************************************/
/*     debut transfert                                        */ 
/******************************************************************/
/*  r0 pointeur uec r1 buffer r2 longueur                  */
.thumb_func
usbstarttransfert:                    @ INFO: usbstarttransfert
    push {r4-r6,lr}
    
    @ les transferts sont limités à 64 caractères 
    cmp r2,64
    ble 1f
    movs r2,64
1:
    movs r6,r0                    @ adresse uec
    ldr r5,iCtrlAvail    @ val
    orrs r5,r5,r2
    ldr r4,[r6,uec_descriptor]    @ adresse descriptor uec
    adds r4,ued_bEndpointAddress
    ldrb r4,[r4]
    movs r3,USB_DIR_IN
    ands r4,r3
    beq 3f
    ldr r4,[r6,uec_data_buffer]
    movs r0,0
2:
    ldrb r3,[r1,r0]
    strb r3,[r4,r0]
    adds r0,1
    cmp r0,r2                   @ longueur ?
    blt 2b
    ldr r1,iCtrlFull
    orrs r5,r5,r1
3:
    ldr r2,[r6,uec_next_pid]
    cmp r2,0
    beq 4f
    ldr r2,iCtrlPid
    orrs r5,r5,r2
    b 5f
4:
    movs r2,USB_BUF_CTRL_DATA0_PID
    orrs r5,r5,r2
5:
    ldr r2,[r6,uec_next_pid]
    movs r1,1
    eors r2,r2,r1
    str r2,[r6,uec_next_pid]
    ldr r6,[r6,uec_buffer_control]
    str r5,[r6]
100:
    pop {r4-r6,pc}
.align 2
iCtrlFull:        .int USB_BUF_CTRL_FULL
iCtrlAvail:       .int USB_BUF_CTRL_AVAIL
iCtrlPid:         .int USB_BUF_CTRL_DATA1_PID
/******************************************************************/
/*     fonction  endpoint 1 OUT   reception                       */ 
/******************************************************************/
/*  r0 adresse buffer r1 longueur                  */
.thumb_func
ep1OutHandler:                @ INFO: ep1OutHandler
    push {r1-r5,lr}
    movs r4,r0
    movs r5,r1

    /* test si le buffer contient Pret */
    movs r3,0
    strb r3,[r4,r5]    @ ajout 0 final
    movs r0,r4
    ldr r1,iAdrszLibPret
    bl comparerChaines
    cmp r0,0
    bne 1f
    movs r1,1            @ host est pret 
    ldr r0,iAdriHostOK   @ maj du top à 1
    str r1,[r0]
    b 10f
1:
    movs r0,r4
    ldr r1,iAdrszLibAtt   @ hote attend un message ?
    bl comparerChaines
    cmp r0,0
    bne 5f               @ ce doit être une réponse
    ldr r2,iAdriAdrEnvoiHost
    ldr r3,[r2]
    cmp r3,0               @ pas de message 
    beq 4f
    movs r4,r3
    movs r5,0
2:                       @ boucle calcul longueur
    ldrb r1,[r4,r5]
    cmp r1,0
    beq 3f
    adds r5,1
    b 2b
3:
    movs r0,0
    str r0,[r2]           @ raz message 
    b 10f
4:
    ldr r2,iAdriAdrReponseHost
    ldr r3,[r2]
    cmp r3,0           @ demande de réponse à envoyer ?
    beq 10f
    ldr r4,iAdrszLibRep @ envoi du libelle
    movs r5,5         @ longueur
    b 10f
5:
    ldr r2,iAdriAdrReponseHost
    ldr r3,[r2]
    cmp r3,0           @ reponse à traiter ?
    beq 10f
    movs r0,0
6:
    ldrb r1,[r4,r0]
    strb r1,[r3,r0]
    adds r0,1
    cmp r0,r5
    blt 6b
    movs r1,0
    strb r1,[r3,r0]   @ 0 final
    str r1,[r2]       @ raz pointeur
    ldr r4,iAdrszLibAtt @ envoi libelle attente
    movs r5,5          @ longueur
10:                        @ et envoi réponse
    movs r0,EP2_IN_ADDR
    bl usbgetendpointconfiguration 
    movs r1,r4
    movs r2,r5
    bl usbstarttransfert
100:
    pop {r1-r5,pc}
.align 2
iAdrszLibPret:     .int szLibPret
iAdriHostOK:       .int iHostOK
iAdrszLibAtt:      .int szLibAtt
iAdrszLibRep:      .int szLibRep
iAdriAdrEnvoiHost:   .int iAdrEnvoiHost
iAdriAdrReponseHost:     .int iAdrReponseHost 
/******************************************************************/
/*     fonction Endpoint 2  IN envoi                                      */ 
/******************************************************************/
/*                    */
.thumb_func
ep2InHandler:                    @ INFO: ep2InHandler
    push {lr}
    movs r0,EP1_OUT_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,64
    bl usbstarttransfert
    pop {pc}
/******************************************************************/
/*     fonction vide  Endpoint 0 Out reception                    */ 
/******************************************************************/
/*                    */
.thumb_func
ep0OutHandler:             @ INFO: ep0OutHandler
    bx lr
/******************************************************************/
/*     gestion interruption                                       */ 
/******************************************************************/
/*                    */
.thumb_func
isrIrq5:                         @ INFO: isrIrq5
    push {r4,r5,lr}    
    ldr r0,iAdrUsbInts
    ldr r4,[r0]                  @ status
    movs r5,0                    @ handled
    ldr r1,iParInts  
    movs r0,r4
    ands r0,r1
    beq 1f
    orrs r5,r1                    @ reception setup packet
    ldr r1,iParSieSta
    ldr r0,iAdrUsbBaseClear
    str r1,[r0,SIE_STATUS]
    bl usbHandleSetupPacket
1:
    ldr r1,iParInts1              @ reception d'une demande
    movs r0,r4
    ands r0,r1
    beq 2f
    orrs r5,r1
    bl usbhandlebuffstatus
2:

    ldr r1,iParInts2
    movs r0,r4
    ands r0,r1
    beq 3f
    orrs r5,r1                    @ bus reset
    ldr r1,iParSieSta1
    ldr r0,iAdrUsbBaseClear
    str r1,[r0,SIE_STATUS]
    bl usbbusreset

3:
    eors r5,r4
    beq 100f
    movs r0,10                  @ cas non prévu !!!
    //bl ledEclats
100:
    pop {r4,r5,pc}
.align 2
iAdrUsbInts:          .int USBCTRL_REGS_BASE + USB_INTS
iAdrUsbBaseClear:     .int USBCTRL_REGS_BASE + 0x3000
iAdrWatchDogBase3:    .int WATCHDOG_BASE
iParSieSta:           .int USB_SIE_STATUS_SETUP_REC_BITS
iParSieSta1:          .int USB_SIE_STATUS_BUS_RESET_BITS
iParInts:             .int USB_INTS_SETUP_REQ_BITS
iParInts1:            .int USB_INTS_BUFF_STATUS_BITS
iParInts2:            .int USB_INTS_BUS_RESET_BITS
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*                    */
.thumb_func
usbHandleSetupPacket:                @ INFO: usbHandleSetupPacket
    push {r4,r5,lr}
    ldr r4,iAdrDpramBase3            @ adresse DPRAM
    ldrb r5,[r4,pkt_bmRequestType]   @ direction
    ldrb r6,[r4,pkt_bRequest]        @ req
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,1
    str r1,[r0,uec_next_pid]         @ reset pid
    movs r1,USB_DIR_OUT
    cmp r5,r1                        @ direction ?
    bne 4f

    movs  r1,USB_REQUEST_SET_ADDRESS
    cmp r6,r1
    bne 1f

    mov r0,r4                      @ adresse setup packet
    bl usbsetdeviceaddress
    b 100f
1:
    movs r1,USB_REQUEST_SET_CONFIGURATION
    cmp r6,r1
    bne 99f
    mov r0,r4                      @ adresse setup packet
    bl usbsetdeviceconfiguration
    b 100f
4: 
    movs r1,USB_DIR_IN
    cmp r5,r1                       @ direction ?
    bne 99f
    movs  r1,USB_REQUEST_GET_DESCRIPTOR
    cmp r6,r1
    bne 99f
    ldrh r3,[r4,pkt_wValue]
    lsrs r3,8
    movs r1,USB_DT_DEVICE
    cmp r3,r1
    bne 5f
    bl usbhandledevicedescriptor
    b 100f
5:
    movs r1,USB_DT_CONFIG
    cmp r3,r1
    bne 6f
    mov r0,r4                      @ adresse setup packet
    bl usbhandleconfigdescriptor
    b 100f
6:
    movs r1,USB_DT_STRING
    cmp r3,r1
    bne 99f                        @ non implanté  -> signal 
    mov r0,r4                      @ adresse setup packet
    bl usbhandlestringdescriptor
    b 100f
99:
    movs r0,10                     @ cas non prévu !!!
    //bl ledEclats
100:

    pop {r4,r5,pc}
.align 2
iAdrDpramBase3:     .int USBCTRL_DPRAM_BASE
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  R0 = adresse setup packet                  */
.thumb_func
usbsetdeviceaddress:              @ INFO: usbsetdeviceaddress
    push {r4,r5,lr}
    mov r4,r0
    ldrh r1,[r4,pkt_wValue]
    movs r2,0xFF
    ands r2,r1
    ldr  r3,iAdrbDev_addr
    strb r2,[r3]
    ldr r3,iAdrShould_set_address
    movs r2,TRUE
    str r2,[r3]            @ true -> Should_set_address

    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0
    bl usbstarttransfert

100:
    pop {r4,r5,pc}
.align 2
iAdrbDev_addr:            .int bDev_addr
iAdrShould_set_address:   .int should_set_address
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*                    */
.thumb_func
usbhandledevicedescriptor:         @ INFO: usbhandledevicedescriptor
    push {lr}
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,1
    str r1,[r0,uec_next_pid]       @
    ldr r1,iAdrdevice_descriptor
    ldr r1,[r1]
    movs r2,LGDEVICE
    bl usbstarttransfert

100:
    pop {pc}
.align 2
iAdrdevice_descriptor:     .int cfg_device_descriptor

/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  R0 contient l adresse du setup packet                  */
.thumb_func
usbhandleconfigdescriptor:        @ INFO: usbhandleconfigdescriptor
    push {r4-r7,lr}
    mov r7,r0

    ldr r5,iAdrsEp0_buf            @ adresse buffer
    ldr r2,iAdrcfg_config_descriptor
    ldr r3,[r2]                      @ adresse config descriptor
    movs r0,0
1:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGCONFDESC
    blt 1b

    adds r5,LGCONFDESC                @ adresse fin de la copie
    ldrh r1,[r7,pkt_wLength]
    ldr r2,iAdrconfd_wTotalLength
    ldrh r2,[r2]
    cmp r1,r2
    blt 5f
    mov r2,r5
    ldr r3,iAdrcfg_interface_descriptor
    ldr r3,[r3]
    movs r0,0
11:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGINTERFACE
    blt 11b
    adds r5,LGINTERFACE

2:
    ldr r6,iAdrEndpoints1      @ adresse endpoints configuration
    movs r7,2
3:                              @ boucle de copie des endpoints
    movs r3,r7
    movs r4,LGCFGENDPOINT
    muls r3,r3,r4
    adds r0,r6,r3                @ adresse de chaque endpoint

    ldr r3,[r0,uec_descriptor]
    cmp r3,0
    beq 4f
    movs r0,0
31:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGDESCRIPT
    blt 31b
    adds r5,LGDESCRIPT
4:
    adds r7,1
    movs r1,USB_NUM_ENDPOINTS
    cmp r7,r1
    blt 3b
5:   
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrsEp0_buf   @ adresse du buffer 
    mov r2,r5
    subs r2,r1            @ calcul longueur buffer
    bl usbstarttransfert
100:
    pop {r4-r7,pc}
.align 2
iAdrcfg_config_descriptor:   .int cfg_config_descriptor
iAdrconfd_wTotalLength:      .int confd_wTotalLength
iAdrcfg_interface_descriptor: .int cfg_interface_descriptor
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*   r0 contient packet                 */
.thumb_func
usbhandlestringdescriptor:       @ INFO: usbhandlestringdescriptor
    push {r4,lr}
    movs r4,0            @ len
    ldrh r1,[r0,pkt_wValue]
    movs r2,0xFF
    ands r2,r1                    @ i
    bne 1f
    movs r4,4                     @ longueur 4 octets 
    ldr r2,iAdrsEp0_buf
    ldr r3,iAdrLangDescriptor     @ buffer
    movs r0,0
0:
    ldrb r1,[r3,r0]
    strb r1,[r2,r0]
    adds r0,1
    cmp r0,4
    blt 0b
    b 2f
1:
    ldr r0,iAdrcfg_descriptor_strings
    subs r2,1
    lsls r2,2                 @ car 4 octets pour chaque adresse
    ldr r0,[r0,r2]            @ adresse de chaque chaine
    bl usbpreparestringdescriptor
    mov r4,r0                 @ retourne la longueur 
2:
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrsEp0_buf       @ adresse buffer
    movs r2,r4                @ longueur
    bl usbstarttransfert

100:
    pop {r4,pc}
.align 2
iAdrLangDescriptor:  .int cfg_lang_descriptor
iAdrcfg_descriptor_strings: .int cfg_descriptor_strings
/******************************************************************/
/*     preparation chaine                                      */ 
/******************************************************************/
/*  r0 contient adresse chaine                   */
.thumb_func
usbpreparestringdescriptor:     @ INFO: usbpreparestringdescriptor
    push {r4-r6,lr}
    movs r1,0
1:                       @ boucle calcul longueur
   ldrb r2,[r0,r1]
   cmp r2,0
   beq 2f
   adds r1,1
   b 1b
2:
   lsls r1,1               @ car unicode à vérifier
   adds r1,2
   ldr r3,iAdrsEp0_buf
   strb r1,[r3]            @ longueur
   movs r6,3               @ type descripteur
   strb r6,[r3,1]
   movs r6,0
   movs r2,2               @ car 2 caractères déjà stockés
   movs r5,0
3:
   ldrb r4,[r0,r6]         @ lit un caractère
   cmp r4,0                @ fin de chaine ?
   beq 4f
   strb r4,[r3,r2]         @ le stocke dans 1er octet
   adds r2,1               
   strb r5,[r3,r2]         @ stocke zéro dans 2ième octet
   adds r2,1 
   adds r6,1
   b 3b
4:
    movs r0,r1        @ retourne la longueur
100:
    pop {r4-r6,pc}
.align 2
iAdrsEp0_buf:        .int sEp0_buf
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*                   */
.thumb_func
usbsetdeviceconfiguration:    @ INFO: usbsetdeviceconfiguration
    push {lr}
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0
    bl usbstarttransfert
    ldr r0,iAdriConfigured
    movs r1,TRUE
    str r1,[r0]

100:
    pop {pc}
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*                   */
.thumb_func
usbhandlebuffstatus:           @  INFO: usbhandlebuffstatus
    push {r4-r7,lr}
    mov r7,r8
    push {r7}                  @ save du registre r8
    ldr r4,iAdrBuffStatus
    ldr r4,[r4]                @ buffers
 
    movs r5,r4                 @ r buffers
    movs r6,0                  @ i
    movs r7,USB_NUM_ENDPOINTS
    lsls r7,1                  @ car pas possible par r8 directement
    mov r8,r7                  @ maxi endpoint * 2
    movs r7,1                  @ départ avec bit 0 à 1
1:                             @ debut de boucle 
    movs r1,r5                 @ r buffers
    ands r1,r7                 @ and bit
    beq 2f
    ldr r4,iAdrBuffStatusClr
    str r7,[r4]                @ remise à 0 du bit par avance

    movs r0,r6                 @ TODO calcul à revoir 
    lsrs r0,1                 @ car plus simple à faire
    movs r1,1
    ands r1,r6
    mvns r1,r1
    bl usbhandlebuffdone
    mvns r0,r7
    ands r5,r0
2:
    lsls r7,1                  @ déplacement du bit à gauche
    adds r6,1                  @ et boucle 
    cmp r6,r8                  @ fin ?
    blt 1b
3:

100:
    pop {r7}
    mov r8,r7           @ restaur du registre r8
    pop {r4-r7,pc}
.align 2
iAdrBuffStatus:       .int USBCTRL_REGS_BASE + USB_BUFF_STATUS
iAdrBuffStatusClr:    .int USBCTRL_REGS_BASE + 0x3000 + USB_BUFF_STATUS
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  r0 =  ep_num    et r1  =  in               */
.thumb_func
usbhandlebuffdone:            @ INFO: usbhandlebuffdone
    push {r4-r6,lr}

    movs r2,0
    movs r3,1
    tst r1,r3                 @ test bit 0
    beq 1f                    @ TODO: test a revoir
    movs r2,USB_DIR_IN
1:
    orrs r2,r0
    movs r5,0                 @ i
    movs r4,LGCFGENDPOINT
    ldr  r6,iAdrEndpoints1    @ adresse début endpoints configuration
2:                            @ début de boucle 
    movs r3,r5
    muls r3,r3,r4
    adds r0,r6,r3             @ adresse de chaque endpoint
    ldr r1,[r0,uec_handler]   @ handler present ?
    cmp r1,0
    beq 3f
    ldr r1,[r0,uec_descriptor] @ descriptor présent ?
    cmp r1,0
    beq 3f
    ldrb r3,[r1,ued_bEndpointAddress] @ adresse identique ?
    cmp r3,r2
    bne 3f
    bl usbhandleepbuffdone

    b 100f
3:
    adds r5,1
    movs r3,USB_NUM_ENDPOINTS
    cmp r5,r3
    blt 2b
100:
    pop {r4-r6,pc}
.align 2
iAdrEndpoints1:    .int cfg_endpoints
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  r0 =  ep               */
.thumb_func
usbhandleepbuffdone:           @ INFO: usbhandleepbuffdone
    push {lr}
    ldr r1,[r0,uec_buffer_control]
    ldr r1,[r1]                     @ adresse controle de la dpram
    ldr r2,iParBufCtrl
    ands r1,r2                      @ longueur
    ldr r3,[r0,uec_handler]         @ charge la procédure du endpoint à executer
    ldr r0,[r0,uec_data_buffer]     @ avec ces donnees
    blx r3
 
100: 
    pop {pc}
.align 2
iParBufCtrl:        .int USB_BUF_CTRL_LEN_MASK
/******************************************************************/
/*     gestion setup packet                                       */ 
/******************************************************************/
/*  r0 =  ep               */
.thumb_func
usbbusreset:               @ INFO: usbbusreset
    movs r1,0
    ldr r0,iAdrbDev_addr1
    strb r1,[r0]
    ldr r0,iAdrShould_set_address1
    str r1,[r0]
    ldr r0,iAdrUsbRegsBase1
    str r1,[r0]
    ldr r0,iAdriConfigured
    str r1,[r0]
100: 
    bx lr 
.align 2
iAdriConfigured:         .int iConfigured
iAdrShould_set_address1: .int should_set_address
iAdrbDev_addr1:          .int bDev_addr
iAdrUsbRegsBase1:       .int USBCTRL_REGS_BASE
/************************************/
/*       préparation interruption        */
/***********************************/
/* r0  contient le N° de l'interruption ici 5  */
/* r1  contient l'adresse de la fonction à appeler */
.thumb_func
setIRQ:                       @ INFO: setIRQ
    push    {r4, r5, r6, lr}
    movs    r5, r1
    mrs    r6, PRIMASK
    cpsid    i
    ldr    r2,iAdrSpinlock  @ 
1:
    ldr    r3, [r2, #0]
    cmp    r3, #0
    beq 1b
    dmb    sy
    ldr    r3,iAdrPPBCpuid  @ 
    adds    r0, #16
    ldr    r3, [r3, #8]    @  recup adresse table VTOR !!
    lsls    r4, r0, #2     @ car 4 octets par poste de la table des vecteurs 
    //ldr    r3, [r3, r4]

    //ldr    r3,iAdrPPBCpuid   @
    //ldr    r3, [r3, #8]
    str    r5, [r3, r4]    @ stocke adresse fonction dans le bon poste de vtor
    dmb    sy
    dmb    sy
    movs   r2, #0
    ldr    r3,iAdrSpinlock   @ 
    str    r2, [r3, #0]
    msr    PRIMASK, r6

100:
    pop    {r4, r5, r6, pc}
.align 2
iAdrSpinlock:             .int    SIO_BASE +  SPINLOCK9
iAdrPPBCpuid:             .int PPB_BASE + PPB_CPUID
