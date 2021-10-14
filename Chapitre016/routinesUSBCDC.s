/* Routines gestion communication USB */
/*  CDC pour communication avec Putty */
/*  Attention : limité à 9600 baud !!! */ 
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
.equ USB_DT_QUALIFIER, 0x06
.equ USB_DT_INTERFACE_ASSOC,  0xB
.equ USB_DT_CDC,       0x24

.equ USB_CLASS_USE_INTERFACE, 0x00
.equ USB_CLASS_CDC_CONTROL,  0x02
.equ USB_CLASS_CDC_DATA,     0x0A

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

.equ USB_SET_CDC_LINE_CODING,         0x20
.equ USB_GET_CDC_LINE_CODING,         0x21
.equ USB_CDC_CONTROL_LINE_STATE,      0x22
.equ USB_CDC_SEND_BREAK,              0x23

.equ USB_DIR_OUT, 0x00
.equ USB_DIR_IN,  0x80

.equ EP0_IN_ADDR,  (USB_DIR_IN  | 0)
.equ EP0_OUT_ADDR, (USB_DIR_OUT | 0)
.equ EP1_IN_ADDR,  (USB_DIR_IN | 1)
.equ EP1_OUT_ADDR, (USB_DIR_OUT | 1)
.equ EP2_IN_ADDR,  (USB_DIR_IN  | 2)
.equ EP2_OUT_ADDR, (USB_DIR_OUT  | 2)
.equ EP3_IN_ADDR,  (USB_DIR_IN  | 3)


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
udpd_setup_packet:                                 @ setup packet
    .struct  udpd_setup_packet + 8 
udpd_ctrl:                                         @ In + out 
    .struct  udpd_ctrl + 8 * (USB_NUM_ENDPOINTS - 1)
udpd_buf_ctrl:                                     @ In + out 
    .struct  udpd_buf_ctrl + 8 * (USB_NUM_ENDPOINTS)
udpd_ep0_buf_a:                                    @ 
    .struct  udpd_ep0_buf_a + 64                   @  0x40
udpd_ep0_buf_b:                                    @ 
    .struct  udpd_ep0_buf_b + 64                  @  0x40
udpd_epx_data:                                     @ 
    .struct  udpd_epx_data + ( USB_DPRAM_SIZE - 0x180)          @ 
udpd_fin:

/* structures USB setup packet  */
    .struct  0
pkt_bmRequestType:                            @ 
    .struct  pkt_bmRequestType + 1
pkt_bRequest:                                 @ 
    .struct  pkt_bRequest + 1
pkt_wValue:                                   @ 
    .struct  pkt_wValue + 2
pkt_wIndex:                                   @ 
    .struct  pkt_wIndex + 2
pkt_wLength:                                  @ 
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
/* line_info   */
    .struct  0
line_dte_rate:                                 @ taux de transmission
    .struct  line_dte_rate + 4 
line_char_format:                              @ format
    .struct  line_char_format + 1
line_parity_type:                              @ parité
    .struct  line_parity_type + 1
line_data_bits:                                 @ 
    .struct  line_data_bits + 1
line_fin:
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data                 @ INFO: data
szRetourLigne:       .asciz "\r\n"
bDev_addr:           .byte  0          @ adresse du periphérique
.align 4
should_set_address:  .int FALSE        @ true si l'adresse du periphérique est renseignée
.global iHostOK                        @ pour utilisation par les programmes appelants
iHostOK:             .int 0

/* voir les descriptions de ces entités  https://www.usbmadesimple.co.uk  */
device_descriptor:
bLength:             .byte         18  @ longueur descriptif
bDescriptorType:     .byte  USB_DT_DEVICE
bcdUSB:              .hword 0x0200
bDeviceClass:        .byte USB_CLASS_USE_INTERFACE  @ Specified in interface descriptor
bDeviceSubClass:     .byte  0                       @ No subclass
bDeviceProtocol:     .byte  0                       @ No protocol
bMaxPacketSize0:     .byte  64                      @ Max packet size for ep0
idVendor:            .hword 0x2E8A                  @ Your vendor id
idProduct:           .hword 0x000A                  @ Your product ID
bcdDevice:           .hword  0x0100                 @ N° device revision number modif 01/09/2021 0x0100
iManufacturer:       .byte   0                      @ Manufacturer string index
iProduct:            .byte   0                      @ Product string index
iSerialNumber:       .byte   0                      @ No serial number
bNumConfigurations:  .byte  1                       @ One configuration
.equ LGDEVICE,    . - device_descriptor

interface_association_descriptor:
inta_bLength:            .byte  8
inta_bDescriptorType:    .byte USB_DT_INTERFACE_ASSOC 
inta_first_interface:    .byte 0
inta_interface_count:    .byte 2
inta_function_class:     .byte 2
inta_function_subclass:  .byte 2
inta_function_protocol:  .byte 1
inta_function:           .byte 0 
.equ LGINTASSO,    . - interface_association_descriptor

interface_descriptor:
int_bLength:            .byte  9
int_bDescriptorType:    .byte USB_DT_INTERFACE
int_bInterfaceNumber:   .byte 0
int_bAlternateSetting:  .byte 0
int_bNumEndpoints:      .byte 1    // Interface has 1 endpoints
int_bInterfaceClass:    .byte USB_CLASS_CDC_CONTROL
int_bInterfaceSubClass: .byte 2
int_bInterfaceProtocol: .byte 0
int_iInterface:         .byte 0
.equ LGINTERFACE,    . - interface_descriptor

cdc_header_descriptor:
cdch_bLength:            .byte  5
cdch_bDescriptorType:    .byte USB_DT_CDC
cdch_sub_type:           .byte 0
cdch_bcd:                .hword 0x1001
.equ LGCDCHEAD,       . - cdc_header_descriptor

cdc_acm_descriptor:
cdca_bLength:            .byte  4
cdca_bDescriptorType:    .byte USB_DT_CDC
cdca_sub_type:           .byte 2
cdca_capabilities:       .byte 0x6
.equ LGCDCACM,      . - cdc_acm_descriptor

cdc_union_descriptor:
cdcu_bLength:            .byte  5
cdcu_bDescriptorType:    .byte USB_DT_CDC
cdcu_sub_type:           .byte 6
cdcu_master_interface:   .byte 0
cdcu_slave_interface:    .byte 1
.equ LGCDCUNION,    . - cdc_union_descriptor

cdc_call_descriptor:
cdcca_bLength:            .byte  5
cdcca_bDescriptorType:    .byte USB_DT_CDC
cdcca_sub_type:           .byte 1
cdcca_capabilities:       .byte 0
cdcca_data_interface:     .byte 1
.equ LGCDCCALL,     . - cdc_call_descriptor
 
.align 4
config_descriptor:
confd_bLength:          .byte   9
confd_bDescriptorType:  .byte  USB_DT_CONFIG
confd_wTotalLength:     .hword  75        @ taille totale des descriptifs

confd_bNumInterfaces:      .byte  2
confd_bConfigurationValue: .byte  1       @ Configuration 1
confd_iConfiguration:      .byte 0        @ No string
confd.bmAttributes:        .byte 0xC0     @ attributes: self powered, no remote wakeup
                                        // TODO: Modif ancien 0x80
confd.bMaxPower:           .byte 0x32     @ 100 ma
.equ  LGCONFDESC,    . - config_descriptor

stVendor:   .asciz        "Raspberry Pi"    @ Nom vendeur : Ne fonctionne pas dans cette version
stProduct:  .asciz        "Pico Test Device2" @ Nom du produit : Ne fonctionne pas dans cette version

endpoint1: 
             .byte 7                @ taille structure
             .byte USB_DT_ENDPOINT  @ type
             .byte EP1_IN_ADDR      @ IN to host
             .byte USB_TRANSFER_TYPE_INTERRUPT
             .hword  16             @ taille du paquet
             .byte  64              @ intervalle
  .equ LGENDP1,   . - endpoint1
  
interface1_descriptor:
int1_bLength:            .byte  9
int1_bDescriptorType:    .byte USB_DT_INTERFACE
int1_bInterfaceNumber:   .byte 1
int1_bAlternateSetting:  .byte 0
int1_bNumEndpoints:      .byte 2    @ cet interface a 2 endpoints
int1_bInterfaceClass:    .byte USB_CLASS_CDC_DATA
int1_bInterfaceSubClass: .byte 0
int1_bInterfaceProtocol: .byte 0
int1_iInterface:         .byte 0
.equ LGINTERFACE1,    . - interface1_descriptor

endpoint2: 
             .byte 7               @ taille structure
             .byte USB_DT_ENDPOINT @ type
             .byte EP2_OUT_ADDR    @ OUT from host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64            @ taille maxi du paquet
             .byte  0
  .equ LGENDP2,   . - endpoint2

endpoint3: 
             .byte 7               @ taille structure
             .byte USB_DT_ENDPOINT @ type
             .byte EP3_IN_ADDR     @  IN to host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64            @ taille maxi du paquet
             .byte  0
  .equ LGENDP2,   . - endpoint2
ep0_out: 
             .byte 7               @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_OUT_ADDR    @  OUT from host
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  64
             .byte  0
  .equ LGDESCRIPT,   . - ep0_out
ep0_in: 
             .byte 7                @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP0_IN_ADDR      @ IN to host
             .byte USB_TRANSFER_TYPE_CONTROL
             .hword  64
             .byte  0
ep1_out: 
             .byte 7                @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP1_OUT_ADDR     @ OUT from host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64
             .byte  0

ep2_in: 
             .byte 7                @ taille structure
             .byte USB_DT_ENDPOINT
             .byte EP2_IN_ADDR      @ IN to host
             .byte USB_TRANSFER_TYPE_BULK
             .hword  64
             .byte  0
.align 4
dev_config:
//cfg_device_descriptor:     .int device_descriptor
cfg_interface_descriptor:  .int interface_descriptor
cfg_config_descriptor:     .int config_descriptor
cfg_lang_descriptor:       .byte   4,  0x03, 0x09, 0x04 @ length, bDescriptorType == String Descriptor,
                                        @ language id = us english
cfg_descriptor_strings:    .int stVendor
                           .int stProduct
cfg_endpoints:
                        .int ep0_out
                        .int ep0OutHandler
                        .int 0           // NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl + 4
                        // &usb_dpram->ep_buf_ctrl[0].out,
                        // EP0 in and out share a data buffer
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
 
    .equ LGCFGENDPOINT, . - cfg_endpoints
             //2ième
                        .int ep0_in
                        .int ep0inhandler
                        .int 0  // NA for EP0
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl
                        // &usb_dpram->ep_buf_ctrl[0].in,
                        // EP0 in and out share a data buffer
                        .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
                        .int 0
                         // &usb_dpram->ep0_buf_a[0],

            // 3ième nouveau
                        .int endpoint1
                        .int ep1InHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl       @ in poste 0 Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl + 8  @ in poste 1
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data        @ TODO revoir 
                        .int 0
 
             // 4ième nouveau
                        .int endpoint2
                        .int ep2OutHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl + 8 + 4  @ out poste 1 OUT Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+16 + 4 @ in poste 2 OUT
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data+64  @
                        .int 0
             // 5ième nouveau
                        .int endpoint3
                        .int ep3InHandler
                        .int USBCTRL_DPRAM_BASE+udpd_ctrl + 16   @ in poste 2 IN Modif
                        .int USBCTRL_DPRAM_BASE+udpd_buf_ctrl+24 @ in poste 2 IN
                        .int USBCTRL_DPRAM_BASE+udpd_epx_data+128
                        .int 0
             // fin
                        .fill LGCFGENDPOINT * 28,1,0 
stLine_info:
                        .int 115200        //
                        .byte 1
                        .byte 0
                        .byte 8
/*******************************************/
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
.align 4
iTopSaisieOk:  .skip 4
iCptCarSaisi:  .skip 4
//sBuffer:       .skip 100
sBufferRec:    .skip 100
sEp0_buf:      .skip 160
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global initUsbDevice,envoyerMessage,recevoirMessage

initUsbDevice:                      @ INFO: initUsbDevice
   push {r4,lr}

                                    @ initialisation horloge USB
    ldr r3,iAdrClocksSet
    movs r1,0x43
    lsls r1,5                       @ pour 860   OK Ok
    str r1,[r3]                     @ TODO: revoir utilité

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
    
    ldr r0,iAdrUsbRegsBase
    ldr r1,iUsbMuxing
    str r1,[r0,USB_MUXING]
    
    ldr r1,iParVbus
    str r1,[r0,USB_PWR]
    
    movs r1,USB_MAIN_CTRL_CONTROLLER_EN_BITS
    str r1,[r0,MAIN_CTRL]
    
    ldr r1,iParSie
    str r1,[r0,SIE_CTRL]
    
    
    ldr r1,iParInte
    ldr r0,iAdrUsbInte
    str r1,[r0]

    bl usbSetupEndpoints
    
    ldr r1,iParSieCtrl
    ldr r0,iAdrSieCtrl
    str r1,[r0]
    

    pop {r4,pc} 
.align 2
iAdrClocksSet:        .int CLOCKS_BASE + 0x2000
iAdrVtor:             .int PPB_BASE + PPB_VTOR
iAdrIsrIRQ:           .int isrIrq5
iUsbReset:            .int RESETS_RESET_USBCTRL_BITS
iAdrClocks:           .int CLOCKS_BASE
iAdrResetBase:        .int RESETS_BASE
iAdrResetBaseSet:     .int RESETS_BASE + 0x2000
iAdrResetBaseClr:     .int RESETS_BASE + 0x3000
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
iparReset:             .int (RESETS_RESET_IO_QSPI_BITS | RESETS_RESET_PADS_QSPI_BITS| RESETS_RESET_PLL_USB_BITS |  RESETS_RESET_PLL_SYS_BITS) 
/*****************************************************************************/
/*   initialisation EndPoints voir chapitre 4.1.3 datasheet RP2040                 */
/*****************************************************************************/
.thumb_func
usbSetupEndpoints:                           @ INFO: usbSetupEndpoints
    push {r4-r6,lr}
    ldr  r4,iAdrEndpoints      @ dev_config.endpoints
    movs r5,0
    movs r6,uec_fin
1:
    mov r3,r6
    muls r3,r5,r3
    add r3,r4
    
    ldr r1,[r3,uec_descriptor]
    cmp r1,0
    beq 2f
    ldr r1,[r3,uec_handler]
    cmp r1,0
    beq 2f
    mov r0,r3
    bl usbSetupEndpoint
2:
    adds r5,r5,1
    cmp r5,USB_NUM_ENDPOINTS
    blt 1b
    
    pop {r4-r6,pc} 
.align 2
/*****************************************************************************/
/*   initialisation un seul  EndPoint voir chapitre 4.1.3 datasheet RP2040                 */
/*****************************************************************************/
/* r0 contient usb_endpoint_configuration  */
.thumb_func
usbSetupEndpoint:                 @ INFO: usbSetupEndpoint
    push {r4,lr}
    mov r4,r0

    ldr r1,[r4,uec_endpoint_control]
    cmp r1,0
    beq 100f
    
    ldr r0,[r4,uec_data_buffer]
    ldr r1,iAdrDpramBase
    subs r0,r1  
    ldr r1,iValCtrlEnable
    orrs r0,r1
    ldr r1,iValCtrlInter
    orrs r0,r1
    ldr r1,[r4,uec_descriptor]
    adds r1,ued_bmAttributes
    
    ldrb r1,[r1]
    
    lsls r1,EP_CTRL_BUFFER_TYPE_LSB
    orrs r0,r1
    ldr r4,[r4,uec_endpoint_control]
    str r0,[r4]
   
100: 
    pop {r4,pc} 
.align 2
iValCtrlInter:     .int EP_CTRL_INTERRUPT_PER_BUFFER
iValCtrlEnable:    .int EP_CTRL_ENABLE_BITS
iAdrDpramBase:     .int USBCTRL_DPRAM_BASE
//iAdrWatchDogBase2:       .int WATCHDOG_BASE

/******************************************************************/
/*     recherche endpoint correspondant à l adresse                                       */ 
/******************************************************************/
/*  r0 adresse                   */
/* r0 retourne adresse du end point trouvé */
.thumb_func
usbgetendpointconfiguration:          @ INFO: usbgetendpointconfiguration
    push {r1-r5,lr}
    ldr r1,iAdrEndpoints
    movs r3,0
    movs r2,uec_fin
1:
    movs r4,r3
    muls r4,r2,r4
    adds r4,r1
    ldr r5,[r4,uec_descriptor]
    ldrb r5,[r5,ued_bEndpointAddress]
    cmp r5,r0
    beq 2f
    adds r3,1
    cmp r3,USB_NUM_ENDPOINTS
    blt 1b
    b 100f
2:
    mov r0,r4        @ retourne adresse du endpoint trouvé
100:
    pop {r1-r5,pc}
.align 2
iAdrEndpoints:    .int cfg_endpoints
/******************************************************************/
/*     préparation transfert                                        */ 
/******************************************************************/
/*  r0 pointeur uec r1 buffer r2 longueur                  */
.thumb_func
usbstarttransfert:                    @ INFO: usbstarttransfert
    push {r4-r6,lr}
    cmp r2,64                @ taille maxi d'un paquet ?
    ble 1f                   @ non 
    movs r3,64
    subs r4,r2,r3
    movs r2,r3
    adds r5,r1,r3
    movs r6,r0
    movs r0,r6
    bl usbTransfert
                               @ TODO: voir si attente courte
    movs r0,2                  @ attente obligatoire !!!
    bl attendre
    movs r0,r6                 @ pointeur uec 
    movs r1,r5                 @ nouveau début du buffer
    movs r2,r4                 @ longueur restante
1:
    bl usbTransfert

100:   
    pop {r4-r6,pc}
/******************************************************************/
/*     debut transfert                                        */ 
/******************************************************************/
/*  r0 pointeur uec r1 buffer r2 longueur                  */
.thumb_func
usbTransfert:                    @ INFO: usbTransfert
    push {r4-r6,lr}

    movs r6,r0                    @ adresse uec
    ldr r5,iCtrlAvail    @ val
    orrs r5,r5,r2
    ldr r4,[r6,uec_descriptor]    @ adresse descriptor uec
    adds r4,ued_bEndpointAddress
    ldrb r4,[r4]
    movs r3,USB_DIR_IN
    ands r4,r3
    beq 2f                         @ direction OUT
    ldr r4,[r6,uec_data_buffer]    @ direction IN
    movs r0,0
1:                                @ boucle copie buffer
    ldrb r3,[r1,r0]
    strb r3,[r4,r0]
    adds r0,1
    cmp r0,r2                      @ longueur ?
    blt 1b                         @ non -> boucle

    ldr r1,iCtrlFull
    orrs r5,r5,r1
2:                                @ TODO: rechercher explication sur cette partie
    ldr r2,[r6,uec_next_pid]
    cmp r2,0                       @ pid = zéro ?
    beq 3f
    ldr r2,iCtrlPid
    orrs r5,r5,r2
    b 4f
3:
    movs r2,USB_BUF_CTRL_DATA0_PID
    orrs r5,r5,r2
4:
    ldr r2,[r6,uec_next_pid]
    movs r1,1
    eors r2,r2,r1
    str r2,[r6,uec_next_pid]
    ldr r6,[r6,uec_buffer_control] @ charge l'adresse du controle buffer de la DPRAM
    str r5,[r6]                    @ et le met à jour

100:
    pop {r4-r6,pc}
.align 2
iCtrlFull:        .int USB_BUF_CTRL_FULL
iCtrlAvail:       .int USB_BUF_CTRL_AVAIL
iCtrlPid:         .int USB_BUF_CTRL_DATA1_PID
//iAdrWatchDogBase:       .int WATCHDOG_BASE
/******************************************************************/
/*     lecture d'un message du host                                       */ 
/******************************************************************/
/*  r0 adresse buffer de stockage                 */
.thumb_func
recevoirMessage:                    @ INFO: recevoirMessage
    push {r0-r4,lr}
    mov r4,r0
    movs r2,0
    ldr r3,iAdriCptCarSaisi
    str r2,[r3]         @ raz nombre caractères
    ldr r3,iAdriTopSaisieOk
    str r2,[r3]         @ raz top saisie
    
1:
    ldr r2,[r3]         @ lecture top saisie
    cmp r2,1
    beq  2f             @ la saisie est terminée 
    movs r0,5           @ sinon on attend
    bl attendre
    b 1b
2:                      @ recopie buffer de saisie dans buffer d'entrée
    ldr r1,iAdrsBufferRec
    movs r2,0
3:
    ldrb r0,[r1,r2]
    strb r0,[r4,r2]
    cmp r0,0            @ fin de chaine ?
    beq 100f
    adds r2,1
    b 3b
100:
    pop {r0-r4,pc}
.align 2
/******************************************************************/
/*     envoie les messages au host                                       */ 
/******************************************************************/
/*  r0 adresse buffer                  */
.thumb_func
envoyerMessage:                    @ INFO: envoyerMessage
    push {r0-r2,lr}
    movs r1,r0
    movs r2,0
1:                       @ boucle calcul longueur
    ldrb r0,[r1,r2]
    //adds r2,1        @ avec le zéro
    cmp r0,0
    beq 2f
    adds r2,1          @ sans le zéro 
    b 1b
2:
    movs r0,EP3_IN_ADDR
    bl usbgetendpointconfiguration 
    bl usbstarttransfert
    movs r0,1           @ TODO: voir plus petit
    bl attendre
    movs r0,EP3_IN_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,0
    bl usbstarttransfert
    movs r0,1           @ TODO: voir plus petit
    bl attendre
100:
    pop {r0-r2,pc}
.align 2
/******************************************************************/
/*     reception commande endpoint 0                                        */ 
/******************************************************************/
/*  r0 adresse buffer r1 taille                  */
.thumb_func
ep0inhandler:                    @ INFO: ep0inhandler
    push {r4,lr}
    ldr r2,iAdrShould_set_address
    ldr r3,[r2]
    cmp r3,FALSE
    beq 1f

    ldr r3,iAdrbDev_addr
    ldrb r3,[r3]
    ldr r0,iAdrUsbRegsBase
    str r3,[r0]          @ correspond au registre dev_addr_ctrl
    movs r1,FALSE
    str r1,[r2]
    b 100f
1:
    movs r0,EP0_OUT_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,0
    bl usbstarttransfert

100:
    pop {r4,pc}
.align 2
iAdrUsbRegsBase:      .int USBCTRL_REGS_BASE
/******************************************************************/
/*     fonction                                       */ 
/******************************************************************/
/*  r0 adresse buffer r1 longueur                  */
.thumb_func
ep1OutHandler:                @ INFO: ep1OutHandler
    push {lr}

    pop {pc}
/******************************************************************/
/*     fonction                                       */ 
/******************************************************************/
/*                    */
.thumb_func
ep2InHandler:                    @ INFO: ep2InHandler
    push {lr}
    movs r1,r0
    movs r2,r1
    movs r0,EP2_OUT_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,64
    bl usbstarttransfert
 
    pop {pc}
.align 2
/******************************************************************/
/*     voir utilité !!!                                       */ 
/******************************************************************/
/*                    */
.thumb_func
ep1InHandler:                    @ INFO: ep1InHandler
    push {lr}

    pop {pc}
/******************************************************************/
/*     fonction vide                                        */ 
/******************************************************************/
/*                    */
.thumb_func
ep0OutHandler:             @ INFO: ep0OutHandler
    push {lr}
   // ne fait rien
    pop {pc}
.align 2
/******************************************************************/
/*     réception du caractère envoyé par le host                  */ 
/******************************************************************/
/*                    */
.thumb_func
ep2OutHandler:             @ INFO: ep2OutHandler
    push {r4-r5,lr}
    mov r4,r0
    mov r5,r1
   // movs r0,2
   // bl ledEclats
    ldr r1,iAdrsBufferRec    @ charge l'adresse buffer
    ldr r2,iAdriCptCarSaisi  @ charge adresse du compteur de caractère
    ldr r3,[r2]
    ldrb r0,[r4]             @ charge le caractère
    cmp r0,0x0D              @ car = retour ligne ? x0D
    bne 1f
    // si oui stocker 0 et positionner top buffer
    movs r0,0
    strb r0,[r1,r3]
    ldr r1,iAdriTopSaisieOk
    movs r0,1
    str r0,[r1]
    movs r3,0
    str r3,[r2]          @ raz  nombre de caractères saisis
                         @ et renvoyer retour ligne
    movs r0,EP3_IN_ADDR
    bl usbgetendpointconfiguration 
    ldr r1,iAdrszRetourLigne1
    movs r2,2
    bl usbstarttransfert
    b 100f
1:
    strb r0,[r1,r3]       @ stocke le caractère reçu
    adds r3,1
    str r3,[r2]           @ stocke le nouveau nombre de caractères
    mov r2,r5              @  retourne le caractère saisi
    mov r1,r4              @ 
    movs r0,EP3_IN_ADDR
    bl usbgetendpointconfiguration 
    bl usbstarttransfert
100:
    pop {r4-r5,pc}
.align 2
iAdriTopSaisieOk:    .int iTopSaisieOk
iAdriCptCarSaisi:    .int iCptCarSaisi
iAdrsBufferRec:      .int sBufferRec
iAdrszRetourLigne1:  .int szRetourLigne
/******************************************************************/
/*     retour endpoint 3   retourne caractères host                    */ 
/******************************************************************/
/*                    */
.thumb_func
ep3InHandler:             @ INFO: ep3InHandler
    push {lr}             @
    movs r0,EP2_OUT_ADDR
    bl usbgetendpointconfiguration 
    movs r1,0
    movs r2,64            @ obligatoire
    bl usbstarttransfert
    pop {pc}
.align 2
/******************************************************************/
/*     gestion interruption                                       */ 
/******************************************************************/
/*                    */
.thumb_func
isrIrq5:                         @ INFO: isrIrq5
    push {r4,r5,lr}    
 
    ldr r0,iAdrUsbInts
    ldr r4,[r0]      @ status
    movs r5,0        @ handled
    
    ldr r1,iParInts  
    movs r0,r4
    ands r0,r1
    beq 1f
    orrs r5,r1
    ldr r1,iParSieSta
    ldr r0,iAdrUsbBaseClear
    str r1,[r0,SIE_STATUS]
    bl usbHandleSetupPacket   @ traitement des commandes
1:
    ldr r1,iParInts1
    movs r0,r4
    ands r0,r1
    beq 2f
    orrs r5,r1
    bl usbhandlebuffstatus   @ traitement des envois du host

2:
    ldr r1,iParInts2
    movs r0,r4
    ands r0,r1
    beq 3f
    orrs r5,r1               @ bus reset
    ldr r1,iParSieSta1
    ldr r0,iAdrUsbBaseClear
    str r1,[r0,SIE_STATUS]
    bl usbbusreset
3:
    eors r5,r4
    beq 100f

    //bl led10Eclats
    bl arretUrgent
100:
    pop {r4,r5,pc}
.align 2
iAdrUsbInts:          .int USBCTRL_REGS_BASE + USB_INTS
iAdrUsbBaseClear:     .int USBCTRL_REGS_BASE + 0x3000
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
    push {r4-r6,lr}
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,1
    str r1,[r0,uec_next_pid]         @ reset pid
    ldr r4,iAdrDpramBase3            @ adresse début DPRAM = adresse packet
    ldrb r5,[r4,pkt_bmRequestType]   @ type requete
    movs r3,0b01100000
    ands r3,r5
    cmp r3,0b0100000                 @ requête class ?
    bne 0f                           @
    mov r0,r4                        @ adresse setup packet
    bl usbClassCDC
    b 100f
0:
    ldrb r6,[r4,pkt_bRequest]        @ req
    cmp r5,USB_DIR_OUT                       @ direction ?
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
    bne 96f

    mov r0,r4                      @ adresse setup packet
    bl usbsetdeviceconfiguration
    b 100f
4: 

    //movs r0,2
    //bl ledEclats
    movs r1,USB_DIR_IN
    cmp r5,r1                       @ direction ?
    bne 97f                         @ autre cas non implémenté
    movs  r1,USB_REQUEST_GET_DESCRIPTOR
    cmp r6,r1
    bne 98f
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
    cmp r3,r1                     @ demande chaine caractères
    bne 7f

    mov r0,r4                      @ adresse setup packet
    bl usbhandlestringdescriptor
    b 100f
7:                               @ ajout 01/09/21
    cmp r3,USB_DT_QUALIFIER
    bne 99f                       @ non implanté  -> signal 
    
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrsEp0_buf1
    movs r2,1                @ retourne paquet stall
    strb r2,[r1]
    bl usbstarttransfert
    b 100f

96:

   // bl led10Eclats
    b arretUrgent
97:

    b arretUrgent
98:

    //bl led10Eclats
    b arretUrgent
99:

   // bl led10Eclats
    b arretUrgent
100:

    pop {r4-r6,pc}
.align 2
iAdrDpramBase3:      .int USBCTRL_DPRAM_BASE
iAdrsEp0_buf1:       .int sEp0_buf
/******************************************************************/
/*     gestion classe cdc                                       */ 
/******************************************************************/
/*  r0 = adresse setup packet                  */
.thumb_func
usbClassCDC:                         @ INFO: usbClassCDC
    push {r4,r5,lr}
    mov r4,r0
    ldrh r5,[r4,pkt_wValue]
    ldrb r1,[r4,pkt_bRequest]        @ requête
    ldrb r2,[r4,pkt_bmRequestType]   @ type requête

    movs r3,0x80
    tst r2,r3                        @ extraction direction
    beq 4f
                                     @ 1 = direction device to host
    cmp r1,USB_GET_CDC_LINE_CODING
    bne 1f
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrstLine_info
    movs r2,line_fin
    bl usbstarttransfert
    b 100f
1:
    cmp r1,USB_SET_CDC_LINE_CODING
    bne 3f
                          @ TODO: aucun effet à revoir
    ldr r0,iAdrBuffEP0
    movs r1,0
    ldr r2,iAdrstLine_info
2:
    ldrb r3,[r0,r1]
    strb r3,[r2,r1]
    adds r1,1
    cmp r1,line_fin
    blt 2b
    
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0
   // ldr r1,iAdrstLine_info
   // movs r2,line_fin
    bl usbstarttransfert

    b 100f
3:
    cmp r1,USB_CDC_CONTROL_LINE_STATE
    bne 8f                     @ erreur
                               @ OK
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0
    bl usbstarttransfert
    movs r0,5
    bl attendre                @ obligatoire
    b 100f

4:
                               @ direction host to device
    cmp r1,USB_GET_CDC_LINE_CODING
    bne 5f

    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrstLine_info
    movs r2,line_fin
    bl usbstarttransfert         @ TODO: aucun effet !!!
    b 100f
5:
    cmp r1,USB_SET_CDC_LINE_CODING
    bne 7f
    
    ldr r0,iAdrBuffEP0
    movs r1,0
    ldr r2,iAdrstLine_info
6:
    ldrb r3,[r0,r1]
    strb r3,[r2,r1]
    adds r1,1
    cmp r1,line_fin
    blt 6b
 
    
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0
    //ldr r1,iAdrstLine_info
   // movs r2,line_fin
    bl usbstarttransfert
    movs r0,2
    bl attendre
    b 100f
7:
    cmp r1,USB_CDC_CONTROL_LINE_STATE
    bne 8f                  @ sinon erreur !

    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0               @  OK 
    bl usbstarttransfert
    movs r0,5
    bl attendre             @ obligatoire
    cmp r5,3                @ configuré et connecté ?
    bne 100f                @ non
    movs r0,EP3_IN_ADDR     @ oui envoi message début
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0               @  OK 
    bl usbstarttransfert
    
    ldr r0,iAdriHostOK      @ positionne le top HOST OK
    movs r1,TRUE
    str r1,[r0]
    b 100f
8:
    b arretUrgent
100:

    pop {r4,r5,pc}
.align 2
iAdrstLine_info:       .int stLine_info
iAdrUsbRegsBase2:      .int USBCTRL_REGS_BASE
iAdrBuffEP0:           .int USBCTRL_DPRAM_BASE+udpd_ep0_buf_a
/******************************************************************/
/*     reception adresse device                                   */ 
/******************************************************************/
/*  r0 = adresse setup packet                  */
.thumb_func
usbsetdeviceaddress:              @ INFO: usbsetdeviceaddress
    push {lr}
    ldrh r1,[r0,pkt_wValue]
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
    pop {pc}
.align 2
iAdrbDev_addr:            .int bDev_addr
iAdrShould_set_address:   .int should_set_address
/******************************************************************/
/*     envoi du device descriptif                                 */ 
/******************************************************************/
/*    Aucun paramètre                */
.thumb_func
usbhandledevicedescriptor:         @ INFO: usbhandledevicedescriptor
    push {lr}
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,1
    str r1,[r0,uec_next_pid]       @ remise à 1 du pid
    ldr r1,iAdrdevice_descriptor   @ adresse descriptif device
    movs r2,LGDEVICE               @ longueur descriptif
    bl usbstarttransfert
100:
    pop {pc}
.align 2
iAdrdevice_descriptor:     .int device_descriptor

/******************************************************************/
/*     envoi des descriptifs de configuration                     */ 
/******************************************************************/
/*  r0 contient l adresse du setup packet                  */
.thumb_func
usbhandleconfigdescriptor:           @ INFO: usbhandleconfigdescriptor
    push {r4-r6,lr}
    ldrh r4,[r0,pkt_wLength]         @ nombre de caractères demandés
    ldr r5,iAdrsEp0_buf              @ adresse buffer
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
    
    ldr r2,iAdrconfd_wTotalLength     @ nombre de caractères des descriptifs
    ldrh r2,[r2]
    cmp r4,r2                          @ comparé au nombre de caractères demandés
    blt 20f                            @ si inférieur on envoie que l'entête
                                       @ sinon recopie de tous les éléments
                                       @ interface association
    ldr r3,iAdrinterface_association_descriptor
    movs r0,0
2:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGINTASSO
    blt 2b
    adds r5,LGINTASSO
                                @ interface communication
    ldr r3,iAdrcfg_interface_descriptor
    ldr r3,[r3]
    movs r0,0
3:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGINTERFACE
    blt 3b
    adds r5,LGINTERFACE
   
    ldr r3,iAdrcdc_header_descriptor
    movs r0,0
4:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGCDCHEAD
    blt 4b
    adds r5,LGCDCHEAD
    
    ldr r3,iAdrcdc_acm_descriptor
    movs r0,0
5:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGCDCACM
    blt 5b
    adds r5,LGCDCACM
    
    ldr r3,iAdrcdc_union_descriptor
    movs r0,0
6:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGCDCUNION
    blt 6b
    adds r5,LGCDCUNION
    
    ldr r3,iAdrcdc_call_descriptor
    movs r0,0
7:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGCDCCALL
    blt 7b
    adds r5,LGCDCCALL

    ldr r3,iAdrEndPoint1      @ adresse endpoints interruption 1
    movs r0,0
8:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGDESCRIPT
    blt 8b
    adds r5,LGDESCRIPT
    
    /********************************/
    ldr r3,iAdrinterface1_descriptor
    movs r0,0
9:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGINTERFACE
    blt 9b
    adds r5,LGINTERFACE
    
    ldr r6,iAdrCfgEndpoints1      @ adresse endpoints configuration
    movs r2,3                     @ debut endpoint
10:                                @ boucle de copie des endpoints
    movs r3,r2
    movs r4,LGCFGENDPOINT
    muls r3,r3,r4                 @ calcul adresse
    adds r0,r6,r3                 @ adresse de chaque endpoint

    ldr r3,[r0,uec_descriptor]
    cmp r3,0                     @ poste vide ?
    beq 12f

    movs r0,0                    @ sinon recopie du endpoint
11:
    ldrb r1,[r3,r0]
    strb r1,[r5,r0]
    adds r0,1
    cmp r0,LGDESCRIPT
    blt 11b
    adds r5,LGDESCRIPT

12:
    adds r2,1                @ incremente index endpoint
    cmp r2,5                 @ fin endpoints ?
    blt 10b

20:                       @ envoi descriptif simple ou complet
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrsEp0_buf   @ adresse début du buffer 
    mov r2,r5             @ adresse fin du buffer
    subs r2,r1            @ calcul longueur buffer
    bl usbstarttransfert
    b 100f

100:
    pop {r4-r6,pc}
.align 2
iAdrEndPoint1:                         .int endpoint1
iAdrcfg_config_descriptor:             .int cfg_config_descriptor
iAdrconfd_wTotalLength:                .int confd_wTotalLength
iAdrcfg_interface_descriptor:          .int cfg_interface_descriptor
iAdrinterface_association_descriptor:  .int interface_association_descriptor
iAdrcdc_header_descriptor:             .int cdc_header_descriptor
iAdrcdc_acm_descriptor:                .int cdc_acm_descriptor
iAdrcdc_union_descriptor:              .int cdc_union_descriptor
iAdrcdc_call_descriptor:               .int cdc_call_descriptor
iAdrinterface1_descriptor:             .int interface1_descriptor
iAdrCfgEndpoints1:                     .int cfg_endpoints

/******************************************************************/
/*     gestion requête demande chaine de caractères               */ 
/******************************************************************/
/*   r0 contient packet             */
.thumb_func
usbhandlestringdescriptor:       @ INFO: usbhandlestringdescriptor
    push {r4,lr}
    ldrh r1,[r0,pkt_wValue]
    movs r2,0xFF
    ands r2,r1                    @ verif 2 derniers caractères
    bne 1f
                                  @ envoi du code langage
    movs r4,4                     @ longueur 4 octets 
    ldr r2,iAdrsEp0_buf           @ buffer d'envoi
    ldr r3,iAdrLangDescriptor     @ code langage sur 4 octets
    ldr r1,[r3]                   @ charge les 4 octets
    str r1,[r2]                   @ et les stocke dans le buffer
    b 2f
    
1:                            @ recherche de la chaine à retourner
    ldr r0,iAdrcfg_descriptor_strings
    subs r2,1                 @ on enleve 1 à l'index à rechercher
    lsls r2,2                 @ car 4 octets pour chaque adresse
    ldr r0,[r0,r2]            @ adresse de chaque chaine
    bl usbpreparestringdescriptor
    mov r4,r0                 @ retourne la longueur 

2:                            @ envoi résultat
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    ldr r1,iAdrsEp0_buf       @ adresse buffer
    movs r2,r4                @ longueur
    bl usbstarttransfert

100:
    pop {r4,pc}
.align 2
iAdrLangDescriptor:          .int cfg_lang_descriptor
iAdrcfg_descriptor_strings: .int cfg_descriptor_strings
/******************************************************************/
/*     preparation chaine en caractères unicode                   */ 
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
/*     recup config device                                       */ 
/******************************************************************/
/*                   */
.thumb_func
usbsetdeviceconfiguration:    @ INFO: usbsetdeviceconfiguration
    push {lr}
    movs r0,EP0_IN_ADDR
    bl usbgetendpointconfiguration
    movs r1,0
    movs r2,0                 @ OK
    bl usbstarttransfert
    pop {pc}
/******************************************************************/
/*     analyse du registre buffer status pour trouver les buffers concernés      */ 
/******************************************************************/
/*   aucun paramètre                */
.thumb_func
usbhandlebuffstatus:           @  INFO: usbhandlebuffstatus
    push {r4-r7,lr}
    bl attenteCourte
    
    ldr r4,iAdrBuffStatus
    ldr r4,[r4]             @ buffers

    movs r5,r4              @ r buffers
    movs r6,0       @ i
    movs r4,USB_NUM_ENDPOINTS
    lsls r4,1        @   * 2    ?????
    movs r7,1        @ bit
1:
    cmp r6,r4
    bge 100f
    movs r1,r5      @ r buffers
    ands r1,r7      @ and bit
    beq 2f
    ldr r2,iAdrBuffStatusClr
    str r7,[r2]     @ raz du bit concerné dans le registre status buffer
    movs r0,r6
    lsrs r0,1
    movs r1,1
    ands r1,r6
    mvns r1,r1
    bl usbhandlebuffdone

    mvns r0,r7
    ands r5,r0
2:
    lsls r7,1
    adds r6,1         @ incremente boucle
    b 1b              @ et boucle 

100:
    pop {r4-r7,pc}
.align 2
iAdrBuffStatus:       .int USBCTRL_REGS_BASE + USB_BUFF_STATUS
iAdrBuffStatusClr:    .int USBCTRL_REGS_BASE + 0x3000 + USB_BUFF_STATUS
/******************************************************************/
/*     recherche du endpount concerné                             */ 
/******************************************************************/
/*  r0 =  ep_num    et r1  =  in               */
.thumb_func
usbhandlebuffdone:            @ INFO: usbhandlebuffdone
    push {r4-r6,lr}
    
    movs r2,0
    movs r3,1
    tst r1,r3                   @ test bit 0
    beq 1f                      @ le bit est à zéro
    movs r2,USB_DIR_IN
1:
    orrs r2,r0
    movs r5,0                   @ indice de balayage
    movs r4,LGCFGENDPOINT       @ taille d'un endpoint
    ldr  r6,iAdrEndpoints1      @ adresse début endpoints configuration
2:                              @ début de boucle de recherche
    movs r3,r5
    muls r3,r3,r4               @ calcul de l'adresse 
    adds r0,r6,r3               @ adresse de chaque endpoint
    ldr r1,[r0,uec_handler]     @ la procédure à appeler existe ?
    cmp r1,0
    beq 3f                      @ non 
    ldr r1,[r0,uec_descriptor]  @ le descriptof existe ?
    cmp r1,0
    beq 3f                       @ non
    ldrb r3,[r1,ued_bEndpointAddress]
    cmp r3,r2                    @ adresse OK ?
    bne 3f
    bl usbhandleepbuffdone       @ traitement du endpoint

    b 100f
3:
    adds r5,1                    @ incremente l'indice
    movs r3,USB_NUM_ENDPOINTS
    cmp r5,r3
    blt 2b                       @ et boucle
100:
    pop {r4-r6,pc}
.align 2
iAdrEndpoints1:    .int cfg_endpoints
/******************************************************************/
/*     appel de la procédure relatif au endpoint                                       */ 
/******************************************************************/
/*  r0  adresse du endpoint               */
.thumb_func
usbhandleepbuffdone:           @ INFO: usbhandleepbuffdone
    push {lr}
    ldr r1,[r0,uec_buffer_control]
    ldr r1,[r1]                     @ adresse controle de la dpram
    ldr r2,iParBufCtrl
    ands r1,r2                      @ extraction longueur
    ldr r3,[r0,uec_handler]         @ charge la procédure du endpoint à executer
    ldr r0,[r0,uec_data_buffer]     @ avec ces donnees et r1 comme longueur
    blx r3                          @ appel procédure
    pop {pc}
.align 2
iParBufCtrl:        .int USB_BUF_CTRL_LEN_MASK
/******************************************************************/
/*     reset bus : initialisation                                       */ 
/******************************************************************/
/*  aucun paramètre               */
.thumb_func
usbbusreset:               @ INFO: usbbusreset
    push {lr}
    movs r1,0
    ldr r0,iAdrbDev_addr1
    strb r1,[r0]
    ldr r0,iAdrShould_set_address1
    str r1,[r0]
    ldr r0,iAdrUsbRegsBase1
    str r1,[r0]
    ldr r0,iAdriHostOK
    str r1,[r0]
100: 
    pop {pc}
.align 2
iAdriHostOK:             .int iHostOK
iAdrShould_set_address1: .int should_set_address
iAdrbDev_addr1:          .int bDev_addr
iAdrUsbRegsBase1:        .int USBCTRL_REGS_BASE
/******************************************************************/
/*     attente courte                                       */ 
/******************************************************************/
/*             */
.thumb_func
attenteCourte:               @ INFO: attenteCourte
    movs r0,250
    lsls r0,6
1:
    subs r0,1
    bgt 1b
100: 
    bx lr 

/******************************************************************/
/*     Arret d urgence                                       */ 
/******************************************************************/
/*                    */
.thumb_func
arretUrgent:               @ INFO: arretUrgent
    push {lr}
1:
    bl 1b                  @ boucle 

    pop {pc}
    .align 2

iAdrWatchDogBase1:       .int WATCHDOG_BASE
