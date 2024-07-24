/******************************/
/*    Constantes */
.equ TCPPORT,      6000
.equ POLL_TIME_S, 5
.equ TCP_WRITE_FLAG_COPY, 1

.equ CYW43_WL_GPIO_LED_PIN, 0

.equ LGTEXTMAX,  80

/******************************/
/*    Constantes X11         */
/******************************/

/* constantes X11 */
.equ KeyPressed,  1
.equ KeyRelease, 2
.equ ButtonPress, 4  
.equ ButtonRelease, 8
.equ EnterNotify, 0x10
.equ LeaveNotify,  0x20

/* event  */
.equ Expose,   12  
.equ ClientMessage,    33      
.equ KeyPressMask, 1
.equ KeyPressEvt,  2
.equ ButtonPressMask, 4
.equ ButtonReleaseMask, 8
.equ ExposureMask, 1<<15
.equ StructureNotifyMask, 1<<17
.equ EnterWindowMask, 1<<4
.equ LeaveWindowMask, 1<<5 
.equ ConfigureNotify, 22


.equ GCForeground,	1<<2
.equ GCBackground, 1<<3
.equ GCLine_width, 1<<4
.equ GCLine_style, 1<<5
.equ GCFont,	1<<14

.equ CWBackPixmap,    1
.equ CWBackPixel,     2
.equ CWBorderPixmap,  4
.equ CWBorderPixel,   8
.equ CWBitGravity,    0x10
.equ CWWinGravity,    0x20
.equ CWEventMask,     0x800




/*******************************************/
/*         Structures                      */
/*******************************************/
/*  définitions tcp */
    .struct  0
tcp_pcb:                     @  
    .struct  tcp_pcb + 4 
tcp_IP:                     @  
    .struct  tcp_IP + 4 
tcp_codeServer:                     @  
    .struct  tcp_codeServer + 4 
tcp_client_connected:                     @  
    .struct  tcp_client_connected + 4 
tcp_ressource_ID:                     @  
    .struct  tcp_ressource_ID + 4 
tcp_parent:
    .struct tcp_parent  + 4
tcp_call_event:                     @  adresse fonction gestion des evenements
    .struct  tcp_call_event + 4
       //  status = 0    start
    //           0    open ok
    //           1    fenetre crée
tcp_status:                     @  
    .struct  tcp_status + 4
tcp_serveur_actif:                     @  
    .struct  tcp_serveur_actif + 4 

tcp_depth:
    .struct tcp_depth  + 2
tcp_bitpixel:
    .struct tcp_bitpixel  + 2
tcp_screen_width:
    .struct tcp_screen_width  + 2
tcp_screen_height:
    .struct tcp_screen_height  + 2
 
tcp_end:

/****************************/
/*  définitions client prefix */
    .struct  0
prefix_byteOrder:                     @  
    .struct  prefix_byteOrder + 1      
prefix_pad:                     @  
    .struct  prefix_pad + 1  
prefix_majorVersion:                     @  
    .struct  prefix_majorVersion + 2 
prefix_minorVersion:                     @  
    .struct  prefix_minorVersion + 2 
prefix_nbytesAuthProto:                     @  
    .struct  prefix_nbytesAuthProto + 2
prefix_nbytesAuthString:                     @  
    .struct  prefix_nbytesAuthString + 2   
prefix_pad2:                     @  
    .struct  prefix_pad2 + 2   
prefix_end:
/****************************/
/*  définitions infosconnexion */
    .struct  0
conn_status:                     @  
    .struct  conn_status + 1 
conn_lenlib:                     @  
    .struct  conn_lenlib + 1 
conn_majorVersion:                     @  
    .struct  conn_majorVersion + 2 
conn_minorVersion:                     @  
    .struct  conn_minorVersion + 2 
conn_lenadd:                     @  
    .struct  conn_lenadd + 2 
conn_release:                     @  
    .struct  conn_release + 4     
conn_residbase:                     @  
    .struct  conn_residbase + 4   
conn_residmask:                     @  
    .struct  conn_residmask + 4   
conn_imgbyteord:                     @  
    .struct  conn_imgbyteord + 4 
//conn_inter:
//    .struct  0
conn_lgFournisseur:                     @  
    .struct  conn_lgFournisseur + 2 
conn_lgReqMax:                     @  
    .struct  conn_lgReqMax + 2 
conn_nbEcrans:                     @  
    .struct  conn_nbEcrans + 1
conn_nbFormats:                     @  
    .struct  conn_nbFormats + 1
conn_ordreoctimg:                     @  
    .struct  conn_ordreoctimg + 1
conn_ordrebits:                     @  
    .struct  conn_ordrebits + 1 
conn_unitenum:                     @  
    .struct  conn_unitenum + 1 
conn_pavenum:                     @  
    .struct  conn_pavenum + 1
conn_mincode:                     @  
    .struct  conn_mincode + 1
conn_maxcode:                     @  
    .struct  conn_maxcode + 1
conn_vide:                     @  
    .struct  conn_vide + 4
conn_Fournisseur:                     @  
    .struct  conn_Fournisseur + 20    @ fonction de la longueur
    
/****************************/
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

/*  définitions entete requete  */
    .struct  0
req_code:                     @   opcode
    .struct  req_code + 1 
req_compl:                     @  complement
    .struct  req_compl + 1 
req_len:                     @   taille
    .struct  req_len + 2
req_end:   

/*  définitions requete draw line */
    .struct  0
reqline_entete:                     @  
    .struct  reqline_entete + 4  
reqline_drawable:                     @  
    .struct  reqline_drawable + 4
reqline_GC:                     @  
    .struct  reqline_GC + 4
reqline_X:                     @  
    .struct  reqline_X + 2
reqline_Y:                     @  
    .struct  reqline_Y + 2
reqline_X1:                     @  
    .struct  reqline_X1 + 2
reqline_Y1:                     @  
    .struct  reqline_Y1 + 2
    
/*  définitions requete create window */
    .struct  0
reqwin_entete:                     @  
    .struct  reqwin_entete + 4  
reqwin_Id:                     @  
    .struct  reqwin_Id + 4
reqwin_Parent:                     @  
    .struct  reqwin_Parent + 4
reqwin_X:                     @  
    .struct  reqwin_X + 2
reqwin_Y:                     @  
    .struct  reqwin_Y + 2
reqwin_height:                     @  
    .struct  reqwin_height + 2
reqwin_width:                     @  
    .struct  reqwin_width + 2
reqwin_border:                     @  
    .struct  reqwin_border + 2
reqwin_class:                     @  
    .struct  reqwin_class + 2
reqwin_visual:                     @  
    .struct  reqwin_visual + 4
reqwin_bitmask:                     @  
    .struct  reqwin_bitmask + 4
reqwin_values:                     @  
    .struct  reqwin_values + 4  
    
/*  définitions requete map */
    .struct  0
reqmap_entete:                     @  
    .struct  reqmap_entete + 4  
reqmap_Id:                     @  
    .struct  reqmap_Id + 4
    
 /*  définitions requete unmap */
    .struct  0
requnmap_entete:                     @  
    .struct  requnmap_entete + 4  
requnmap_Id:                     @  
    .struct  requnmap_Id + 4
    
/*  définitions requete création GC */
    .struct  0
reqGC_entete:                     @  
    .struct  reqGC_entete + 4  
reqGC_Id:                     @  
    .struct  reqGC_Id + 4     
reqGC_drawable:                     @  
    .struct  reqGC_drawable + 4 
reqGC_bitmask:                     @  
    .struct  reqGC_bitmask + 4     
reqGC_value1:                     @  
    .struct  reqGC_value1 + 4
reqGC_value2:                     @  
    .struct  reqGC_value2 + 4 
    
/*  définitions requete change GC */
    .struct  0
reqChgGC_entete:                     @  
    .struct  reqChgGC_entete + 4  
reqChgGC_Id:                     @  
    .struct  reqChgGC_Id + 4     
reqChgGC_bitmask:                     @  
    .struct  reqChgGC_bitmask + 4     
reqChgGC_value1:                     @  
    .struct  reqChgGC_value1 + 4

/*  définitions requete create pixmap */
    .struct  0
reqpix_entete:                     @  
    .struct  reqpix_entete + 4  
reqpix_Id:                     @  
    .struct  reqpix_Id + 4     
reqpix_drawable:                     @  
    .struct  reqpix_drawable + 4 
reqpix_width:                     @  
    .struct  reqpix_width + 2     
reqpix_height:                     @  
    .struct  reqpix_height + 2
    
/*  définitions requete change attribut */
    .struct  0
reqattrib_entete:                     @  
    .struct  reqattrib_entete + 4  
reqattrib_Id:                     @  
    .struct  reqattrib_Id + 4   
reqattrib_bitmask:                     @  
    .struct  reqattrib_bitmask + 4   
reqattrib_values:                     @  
    .struct  reqattrib_values + 20  
   
    
/*  définitions requete afficher texte */
    .struct  0
reqtext_entete:                     @  
    .struct  reqtext_entete + 4  
reqtext_drawable:                     @  
    .struct  reqtext_drawable + 4 
reqtext_GC:                     @  
    .struct  reqtext_GC + 4     
reqtext_X:                     @  
    .struct  reqtext_X + 2
reqtext_Y:                     @  
    .struct  reqtext_Y + 2
reqtext_text:                     @  
    .struct  reqtext_text + LGTEXTMAX
    
 /*  définitions requete rectangle */
    .struct  0
reqrect_entete:                     @  
    .struct  reqrect_entete + 4  
reqrect_drawable:                     @  
    .struct  reqrect_drawable + 4 
reqrect_GC:                     @  
    .struct  reqrect_GC + 4 
reqrect_X:                     @  
    .struct  reqrect_X + 2
reqrect_Y:                     @  
    .struct  reqrect_Y + 2 
reqrect_width:                     @  
    .struct  reqrect_width + 2    
reqrect_height:                     @  
    .struct  reqrect_height + 2     
    
 /*  définitions requete Arc */
    .struct  0
reqarc_entete:                     @  
    .struct  reqarc_entete + 4  
reqarc_drawable:                     @  
    .struct  reqarc_drawable + 4 
reqarc_GC:                     @  
    .struct  reqarc_GC + 4 
reqarc_arc:                     @  
    .struct  reqarc_arc + 12
  /*  définitions requete Arc */
    .struct  0
arc_x:                     @  
    .struct  arc_x + 2                     @ 
arc_y:                     @  
    .struct  arc_y + 2    
arc_width:                     @  
    .struct  arc_width + 2  
arc_height:                     @  
    .struct  arc_height + 2      
arc_anglestart:                     @  
    .struct  arc_anglestart + 2 
arc_anglelen:                     @  
    .struct  arc_anglelen + 2     @     
    
/*  définitions requete copy area */
    .struct  0
reqcopy_entete:                     @  
    .struct  reqcopy_entete + 4  
reqcopy_Idsrc:                     @  
    .struct  reqcopy_Idsrc + 4  
reqcopy_Iddest:                     @  
    .struct  reqcopy_Iddest + 4      
reqcopy_GC:                     @  
    .struct  reqcopy_GC + 4 
reqcopy_Xsrc:                     @  
    .struct  reqcopy_Xsrc + 2     
reqcopy_Ysrc:                     @  
    .struct  reqcopy_Ysrc + 2
reqcopy_Xdest:                     @  
    .struct  reqcopy_Xdest + 2   
reqcopy_Ydest:                     @  
    .struct  reqcopy_Ydest + 2  
reqcopy_width:                     @  
    .struct  reqcopy_width + 2    
reqcopy_height:                     @  
    .struct  reqcopy_height + 2
    
/*  définitions requete configuration fenetre */
    .struct  0
reqconf_entete:                     @  
    .struct  reqconf_entete + 4  
reqconf_Id:                     @  
    .struct  reqconf_Id + 4   
reqconf_bitmask:                     @  
    .struct  reqconf_bitmask + 4   
reqconf_values:                     @  
    .struct  reqconf_values + 20  
    
/*  définitions requete list font */
    .struct  0
reqlistF_entete:                     @  
    .struct  reqlistF_entete + 4  
reqlistF_maxnames:                     @  
    .struct  reqlistF_maxnames +   2 
reqlistF_lenPattern:                     @  
    .struct  reqlistF_lenPattern + 2  
reqlistF_Pattern:                     @  
    .struct  reqlistF_Pattern + 20 
    
/*  définitions requete open font */
    .struct  0
reqopenF_entete:                     @  
    .struct  reqopenF_entete + 4  
reqopenF_Id:                     @  
    .struct  reqopenF_Id +   4 
reqopenF_len:                     @  
    .struct  reqopenF_len + 2 
reqopenF_pad:                     @  
    .struct  reqopenF_pad + 2      
reqopenF_name:                     @  
    .struct  reqopenF_name + 40 
    
/****************************************/
/*  Evenements                         */ 
/****************************************/
 /*  définitions requete rectangle */
    .struct  0
event_codeop:                     @  
    .struct  event_codeop + 1  
event_compl:                     @  
    .struct  event_compl + 1  
event_seq:                     @  
    .struct  event_seq + 2  
event_time:                     @  
    .struct  event_time + 4
event_root:                     @  
    .struct  event_root + 4
event_win:                     @  
    .struct  event_win + 4  
event_winchild:                     @  
    .struct  event_winchild + 4  

    
    