/***************************************************/	
/*  DEFINITIONS DES Structures   X11               */
/***************************************************/
/* Assembleur ARM Raspberry  : Vincent Leboulou */
/* Blog : http://assembleurarmpi.blogspot.fr/  */
/* ATTENTION : vérifier bien ces structures avant utilisation */
/* autre que celle décrites dans ce blog          */
/*************************************************/
/*  */
/*********************************************/
/* ces définitions sont celles du Display */
    .struct  0
Disp_ext_data:	 /* hook for extension to hang data */ 
    .struct  Disp_ext_data + 4 
Disp_private1:	 
    .struct  Disp_private1 + 4 	
Disp_fd:	    /* Network socket. */
    .struct  Disp_fd + 4 		
Disp_private2:	 
    .struct  Disp_private2 + 4
Disp_proto_major_version:	   /* major version of server's X protocol */
    .struct  Disp_proto_major_version + 4
Disp_proto_minor_version:	  /* minor version of servers X protocol */
    .struct  Disp_proto_minor_version + 4	
Disp_vendor:	           	/* vendor of the server hardware */
    .struct  Disp_vendor + 4
Disp_private3:	 
    .struct  Disp_private3 + 4
Disp_private4:	 
    .struct  Disp_private4 + 4
Disp_private5:	 
    .struct  Disp_private5 + 4
Disp_private6:	 
    .struct  Disp_private6 + 4
Disp_resource_alloc:	 
    .struct  Disp_resource_alloc + 4	
Disp_byte_order:	 	/* screen byte order, LSBFirst, MSBFirst */
    .struct  Disp_byte_order+ 4
Disp_bitmap_unit:	    /* padding and data requirements */
    .struct  Disp_bitmap_unit + 4
Disp_bitmap_pad:	 /* padding requirements on bitmaps */
    .struct  Disp_bitmap_pad + 4
Disp_bitmap_bit_order:	 /* LeastSignificant or MostSignificant */
    .struct  Disp_bitmap_bit_order + 4
Disp_nformats:	           /* number of pixmap formats in list */
    .struct  Disp_nformats + 4 
Disp_pixmap_format:	       /* pixmap format list */
    .struct  Disp_pixmap_format + 4	
Disp_private8:	 
    .struct  Disp_private8 + 4
Disp_release:	           /* release of the server */ 
    .struct  Disp_release + 4
Disp_private9:	 
    .struct  Disp_private9 + 4
Disp_private10:	 
    .struct  Disp_private10 + 4	
Disp_qlen:	         /* Length of input event queue */
    .struct  Disp_qlen + 4	
Disp_last_request_read:	  /* seq number of last event read */
    .struct  Disp_last_request_read + 4
Disp_request:	 /* sequence number of last request. */
    .struct  Disp_request + 4		
Disp_private11:	 
    .struct  Disp_private11 + 4		
Disp_private12:	 
    .struct  Disp_private12 + 4	
Disp_private13:	 
    .struct  Disp_private13 + 4	
Disp_private14:	 
    .struct  Disp_private14 + 4	
Disp_max_request_size:	 /* maximum number 32 bit words in request*/
    .struct  Disp_max_request_size + 4	
Disp_db:	 
    .struct  Disp_db + 4		
Disp_private15:	 
    .struct  Disp_private15 + 4	
Disp_display_name:	 /* "host:display" string used on this connect*/
    .struct  Disp_display_name + 4	
Disp_default_screen:	 	/* default screen for operations */
    .struct  Disp_default_screen + 4		
Disp_nscreens:	      	/* number of screens on this server*/
    .struct  Disp_nscreens + 4		
Disp_screens:	      /* pointer to list of screens */
    .struct  Disp_screens + 4	
Disp_motion_buffer:	    /* size of motion buffer */
    .struct  Disp_motion_buffer + 4		
Disp_private16:	 
    .struct  Disp_private16 + 4	
Disp_min_keycode:	  	/* minimum defined keycode */
    .struct  Disp_min_keycode + 4		
Disp_max_keycode:	  	/* maximum defined keycode */
    .struct  Disp_max_keycode + 4	
Disp_private17:	 
    .struct  Disp_private17 + 4	
Disp_private18:	 
    .struct  Disp_private18 + 4	
Disp_private19:	 
    .struct  Disp_private19 + 4		
Disp_xdefaults:	    /* contents of defaults from server */
    .struct  Disp_xdefaults + 4	
Disp_fin:
/*****************************************/	
/* ces définitions sont celles d'un ecran Screen */
    .struct  0
Screen_ext_data:	 /* hook for extension to hang data */ 
    .struct  Screen_ext_data + 4 
Screen_Xdisplay:	 /* back pointer to display structure */
    .struct  Screen_Xdisplay + 4 	
Screen_root:	 	/* Root window id. */ 
    .struct  Screen_root + 4 
Screen_width:	 
    .struct  Screen_width + 4 	
Screen_height:	 
    .struct  Screen_height + 4 
Screen_mwidth:	 /* width and height of  in millimeters */
    .struct  Screen_mwidth + 4 	
Screen_mheight:	 
    .struct  Screen_mheight + 4 
Screen_ndepths:	  /* number of depths possible */ 
    .struct  Screen_ndepths + 4  
Screen_depths:	 /* list of allowable depths on the screen */  
    .struct  Screen_depths + 4 
Screen_root_depth:	   /* bits per pixel */ 
    .struct  Screen_root_depth + 4 	
Screen_root_visual:	 /* root visual */ 
    .struct  Screen_root_visual + 4 
Screen_default_gc:	 /* GC for the root root visual */ 
    .struct  Screen_default_gc + 4 	
Screen_cmap:	 /* default color map */
    .struct  Screen_cmap + 4 
Screen_white_pixel:	 
    .struct  Screen_white_pixel + 4 	
Screen_black_pixel:	 
    .struct  Screen_black_pixel + 4 
Screen_max_maps:	 /* max and min color maps */
    .struct  Screen_max_maps + 4 	
Screen_min_maps:	 
    .struct  Screen_min_maps + 4 
Screen_backing_store:	 /* Never, WhenMapped, Always */
    .struct  Screen_backing_store + 4 	
Screen_save_unders:	 
    .struct  Screen_save_unders + 4 
Screen_root_input_mask:	 /* initial root input mask */
    .struct  Screen_root_input_mask + 4 
Screen_fin:
/**********************************************/
/* ces définitions sont celles des attributs d'une fenêtre XWindowAttributes */
    .struct  0
Win_x:	          /* position horizontale */
    .struct Win_x + 4   
Win_y:	          /* position verticale */
    .struct Win_y + 4
Win_width:	       /* largeur */
    .struct Win_width + 4  
Win_height:	           	/* hauteur */
    .struct Win_height + 4
Win_border_width:	/* border width of window */
    .struct Win_border_width + 4	
Win_depth:	      /* depth of window */
    .struct Win_depth + 4	
Win_visual:	      /* the associated visual structure */
    .struct Win_visual + 4
Win_root:	      /* root of screen containing window */
    .struct Win_root + 4
Win_class:	     /* InputOutput, InputOnly*/
    .struct Win_class + 4	
Win_bit_gravity:	  /* one of bit gravity values */
    .struct Win_bit_gravity + 4
Win_win_gravity:	  /* one of the window gravity values */
    .struct Win_win_gravity + 4	
Win_backing_store:	 /* NotUseful, WhenMapped, Always */
    .struct Win_backing_store + 4		
Win_backing_planes:	 /* planes to be preserved if possible */
    .struct Win_backing_planes + 4	
Win_backing_pixel:	/* value to be used when restoring planes */
    .struct Win_backing_pixel + 4	
Win_save_under:	    /* boolean, should bits under be saved? */
    .struct Win_save_under + 4		
Win_colormap:	   /* color map to be associated with window */
    .struct Win_colormap + 4
Win_map_installed:	/* boolean, is color map currently installed*/
    .struct Win_map_installed + 4
Win_map_state:	   /* IsUnmapped, IsUnviewable, IsViewable */
    .struct Win_map_state + 4	
Win_all_event_masks:	/* set of events all people have interest in*/
    .struct Win_all_event_masks + 4	
Win_your_event_mask:	/* my event mask */
    .struct Win_your_event_mask + 4	
Win_do_not_propagate_mask:	/* set of events that should not propagate */
    .struct Win_do_not_propagate_mask + 4		
Win_override_redirect:	/* boolean value for override-redirect */
    .struct Win_override_redirect + 4	
Win_screen:	 /* back pointer to correct screen */
    .struct Win_screen + 4	
/* ajout données particulières */
Win_id:
	.struct Win_id + 4	   @ identification de la fenêtre
Win_procedure:
	.struct Win_procedure + 4	   @ procedure à appeler si evenement
Win_background:
 	.struct Win_background + 4	   @ pixel du fond
Win_foreground:
    .struct Win_foreground + 4     @ picel dessin
Win_border:
 	.struct Win_border + 4	       @ pixel de la bordure
Win_titre:        /*pointeur vers le titre de la fenêtre */
 	.struct Win_titre + 4	
Win_titre_red:       /* pointeur vers texte de la fenetre reduit */
 	.struct Win_titre_red + 4	
Win_GC:                      @ contexte graphique associé
    .struct Win_GC + 4		
Win_Font:					@ police de caractère 
	.struct Win_Font + 4
Win_long_texte:      /* longueur du texte saisi */
 	.struct Win_long_texte + 4	
Win_pt_texte:       /*  pointeur vers buffer du texte saisi */
 	.struct Win_pt_texte + 4	
Win_fin:	

/****************************/
/* ces définitions sont celles d'un bouton */
    .struct  0
BT_windows:
.struct BT_windows + 4
BT_texte:	
    .struct BT_texte + 4
BT_text_width:	
    .struct BT_text_width + 4	
BT_font_ascent:
    .struct BT_font_ascent + 4  
BT_x:
	.struct BT_x + 4
BT_y:
	.struct BT_y + 4
BT_width:
	.struct BT_width + 4
BT_height:
    .struct	BT_height + 4
BT_border:
    .struct BT_border + 4
BT_background:
    .struct BT_background + 4	
BT_foreground:
    .struct BT_foreground + 4
BT_cbdata:
    .struct BT_cbdata  + 4
BT_release:
    .struct BT_release + 4	
BT_adresse:
    .struct BT_adresse + 4		
BT_GC:
    .struct BT_GC + 4		
BT_Font:
	.struct BT_Font + 4
BT_fin:	
	.struct BT_fin + 4
/**********************************************/
/* structure XFontStruct       Police de caractères    */
    .struct  0
XFontST_ext_data:	 /* hook for extension to hang data */ 
    .struct  XFontST_ext_data + 4 
XFontST_fid:	  /* Font id for this font */
    .struct  XFontST_fid + 4 
XFontST_direction:	  /* hint about direction the font is painted */
    .struct  XFontST_direction + 4     
XFontST_min_char_or_byte2:	  /* first character */
    .struct  XFontST_min_char_or_byte2+ 4
XFontST_max_char_or_byte2:	  /* last character */
    .struct  XFontST_max_char_or_byte2+ 4   
XFontST_min_byte1:	  /* first row that exists */
    .struct  XFontST_min_byte1 + 4     
XFontST_max_byte1:	  /* last row that exists */
    .struct  XFontST_max_byte1 + 4  	
XFontST_all_chars_exist:	  /* flag if all characters have non-zero size*/
    .struct  XFontST_all_chars_exist + 4    
XFontST_default_char:	  /* char to print for undefined character */
    .struct  XFontST_default_char + 4      
XFontST_n_properties:	  /* how many properties there are */
    .struct  XFontST_n_properties + 4
XFontST_properties:	  /* pointer to array of additional properties*/
    .struct  XFontST_properties + 4    
XFontST_min_bounds:	  /* minimum bounds over all existing char*/
    .struct  XFontST_min_bounds + 4      
XFontST_max_bounds:	  /* maximum bounds over all existing char*/
    .struct  XFontST_max_bounds + 4      
XFontST_per_char:	  /* first_char to last_char information */
    .struct  XFontST_per_char + 4  
XFontST_ascent:	  /* log. extent above baseline for spacing */
    .struct  XFontST_ascent + 4  
XFontST_descent:	  /* log. descent above baseline for spacing */
    .struct  XFontST_descent + 4      
XFontST_fin:    
 /**********************************************/
/* structure XTextItem */
    .struct  0
XTI_chars:	/* pointer to string */
    .struct XTI_chars + 4
XTI_nchars:	/* number of characters */
    .struct XTI_nchars + 4	
XTI_delta:	/* delta between strings */
    .struct XTI_delta + 4
XTI_font:	/* Font to print it in, None don't change */
    .struct XTI_font + 4		
XTI_fin:
/**********************************************/
/* structure    XGCValues                  */
    .struct  0
XGC_function: 				/* logical operation */
	.struct XGC_function + 4
XGC_plane_mask: 			/* plane mask */
	.struct XGC_plane_mask + 4
XGC_foreground: 			/* foreground pixel */
	.struct XGC_foreground + 4
XGC_background: 			/* background pixel */
	.struct XGC_background + 4
XGC_line_width: 			/* line width */
	.struct XGC_line_width + 4
XGC_line_style: 			/* LineSolid, LineOnOffDash, LineDoubleDash */
	.struct XGC_line_style + 4
XGC_cap_style: 				/* CapNotLast, CapButt,CapRound, CapProjecting */
	.struct XGC_cap_style + 4
XGC_join_style: 			/* JoinMiter, JoinRound, JoinBevel */
	.struct XGC_join_style + 4
XGC_fill_style: 			/* FillSolid, FillTiled,FillStippled, FillOpaeueStippled */
	.struct XGC_fill_style + 4
XGC_fill_rule: 				/* EvenOddRule, WindingRule */
	.struct XGC_fill_rule + 4
XGC_arc_mode: 				/* ArcChord, ArcPieSlice */
	.struct XGC_arc_mode + 4
XGC_tile:   				/* tile pixmap for tiling operations */
	.struct XGC_tile + 4
XGC_stipple: .word	0	/* stipple 1 plane pixmap for stipping */
	.struct XGC_stipple + 4
XGC_ts_x_origin: 			/* offset for tile or stipple operations */
	.struct XGC_ts_x_origin + 4
XGC_ts_y_origin: 
	.struct XGC_ts_y_origin + 4
XGC_font: 						/* default text font for text operations */
	.struct XGC_font + 4
XGC_subwindow_mode: 			/* ClipByChildren, IncludeInferiors */
	.struct XGC_subwindow_mode + 4
XGC_graphics_exposures: 			/* boolean, should exposures be generated */
	.struct XGC_graphics_exposures + 4
XGC_clip_x_origin: 				/* origin for clipping */
	.struct XGC_clip_x_origin + 4
XGC_clip_y_origin: 		
	.struct XGC_clip_y_origin + 4
XGC_clip_mask: 				/* bitmap clipping; other calls for rects */
	.struct XGC_clip_mask + 4
XGC_dash_offset: 			/* patterned/dashed line information */
	.struct XGC_dash_offset + 4
XGC_dashes: 
	.struct XGC_dashes + 4
XGC_fin:
	
 /**********************************************/
/* evenement Xconfigure */
    .struct  0
XConfigureEvent_type:	
    .struct XConfigureEvent_type + 4
XConfigureEvent_serial:
	.struct XConfigureEvent_serial + 4 /* # of last request processed by server */
XConfigureEvent_send_event:
    .struct XConfigureEvent_send_event  + 4 /* true if this came from a SendEvent request */
XConfigureEvent_display:
    .struct XConfigureEvent_display  + 4	/* Display the event was read from */
XConfigureEvent_event:
    .struct XConfigureEvent_event  + 4	
XConfigureEvent_window:
    .struct XConfigureEvent_window  + 4	
XConfigureEvent_x:
    .struct XConfigureEvent_x  + 4
XConfigureEvent_y:
    .struct XConfigureEvent_y  + 4	
XConfigureEvent_width:
    .struct XConfigureEvent_width  + 4	
XConfigureEvent_height:
    .struct XConfigureEvent_height  + 4
XConfigureEvent_border_width:
    .struct XConfigureEvent_border_width  + 4
XConfigureEvent_above:
    .struct XConfigureEvent_above  + 4
XConfigureEvent_override_redirect:
    .struct XConfigureEvent_override_redirect  + 4
/***************************************************/
/* structure XButtonEvent    */
    .struct  0
XBE_type:	          
    .struct XBE_type + 4  /* TODO A REVOIR erreur ligne suivante */           	
XBE_serial:	         /* No  last request processed  server */ 
    .struct XBE_serial + 4 
XBE_send_event:	          /* true if this came from a SendEvent request */ 
    .struct XBE_send_event + 4 	
XBE_display:	          /* Display the event was read from */  
    .struct XBE_display + 4  	
XBE_window:	             /* "event" window it is reported relative to */
    .struct XBE_window + 4  
XBE_root:	             /* root window that the event occurred on */
    .struct XBE_root + 4  
XBE_subwindow:	          /* child window */ 
    .struct XBE_subwindow + 4  
XBE_time:	          /* milliseconds */   
    .struct XBE_time + 4  	
XBE_x:	             /* pointer x, y coordinates in event window */
    .struct XBE_x + 4
XBE_y:	          
    .struct XBE_y + 4
XBE_x_root:	          /* coordinates relative to root */
    .struct XBE_x_root + 4
XBE_y_root:	          
    .struct XBE_y_root + 4	
XBE_state:	          /* key or button mask */
    .struct XBE_state + 4	                                
XBE_button:	          /* detail */
    .struct XBE_button + 4	
XBE_same_screen:	     /* same screen flag */    
    .struct XBE_same_screen + 4		
XBE_fin:
/***************************************************/
/* structure XMotionEvent */	
    .struct  0
XMotion_type:	          
    .struct XMotion_type + 4
XMotion_serial:	          /* # of last request processed by server */
    .struct XMotion_serial + 4	
XMotion_send_event:	          /* true if this came from a SendEvent request */
    .struct XMotion_send_event + 4
XMotion_display:	          /* Display the event was read from */
    .struct XMotion_display + 4
XMotion_window:	           /* "event" window reported relative to */
    .struct XMotion_window + 4
XMotion_root:	           /* root window that the event occurred on */
    .struct XMotion_root + 4
XMotion_subwindow:	          /* child window */
    .struct XMotion_subwindow + 4
XMotion_time:	          /* milliseconds */
    .struct XMotion_time + 4
XMotion_x:	          /* pointer x, y coordinates in event window */
    .struct XMotion_x + 4	
XMotion_y:	          
    .struct XMotion_y + 4
XMotion_x_root:	          /* coordinates relative to root */
    .struct XMotion_x_root + 4	
XMotion_y_root:	          
    .struct XMotion_y_root + 4	
XMotion_state:	          /* key or button mask */
    .struct XMotion_state + 4
XMotion_hint:	          /* detail */
    .struct XMotion_hint + 4
XMotion_same_screen:	          /* same screen flag */
    .struct XMotion_same_screen + 4	
XMotion_fin:	

/***************************************************/
/* structure XClientMessageEvent */	
    .struct  0
XClient_type:
	.struct XClient_type + 4
XClient_serial:			/* # of last request processed by server */
	.struct XClient_serial + 4
XClient_send_event:		/* true if this came from a SendEvent request */
	.struct XClient_send_event + 4
XClient_display:		/* Display the event was read from */
	.struct XClient_display + 4
XClient_window:
	.struct XClient_window + 4
XClient_message_type:
	.struct XClient_message_type + 4
XClient_format:
	.struct XClient_format + 4
XClient_data:        /* datas */
	.struct XClient_data + 4
XClient_fin:


/***************************************************/
/* structure XAnyEvent */	
    .struct  0
XAny_type:	          
    .struct XAny_type + 4
XAny_serial:	          
    .struct XAny_serial + 4   /* # of last request processed by server */
XAny_send_event:	          
    .struct XAny_send_event + 4	/* true if this came from a SendEvent request */
XAny_display:	          
    .struct XAny_display + 4  /* Display the event was read from */
XAny_window:	          
    .struct XAny_window + 4 	/* window on which event was requested in event mask */
Xany_fin:

/***************************************************/
/* structure XSetWindowAttributes */
    .struct  0
Att_background_pixmap:	          /* background or None or ParentRelative */
    .struct Att_background_pixmap + 4
Att_background_pixel:	          /* background pixel */
    .struct Att_background_pixel + 4	
Att_border_pixmap:	          /* border of the window */
    .struct Att_border_pixmap + 4	
Att_border_pixel:	          /* border pixel */
    .struct Att_border_pixel + 4	
Att_bit_gravity:	          /* one of bit gravity values */
    .struct Att_bit_gravity + 4 
Att_win_gravity:	          /* one of the window gravity values */
    .struct Att_win_gravity + 4     
Att_backing_store:	        /* NotUseful, WhenMapped, Always */
    .struct Att_backing_store + 4      
Att_backing_planes:	        /* planes to be preseved if possible */
    .struct Att_backing_planes + 4  
Att_backing_pixel:	        /* value to use in restoring planes */
    .struct Att_backing_pixel + 4 	
Att_save_under:	        /* should bits under be saved? (popups) */
    .struct Att_save_under + 4   
Att_event_mask:	        /* set of events that should be saved */
    .struct Att_event_mask + 4       
Att_do_not_propagate_mask:	        /* set of events that should be saved */
    .struct Att_do_not_propagate_mask + 4     
Att_override_redirect:	        /* boolean value for override-redirect */
    .struct Att_override_redirect + 4        
Att_colormap:	        /* color map to be associated with window */
    .struct Att_colormap + 4     
Att_cursor:	        
    .struct Att_cursor + 4      
Att_fin:		
/*******************FIN*****************************/	
/* structure de type   XWMHints   */
    .struct  0
Hints_flags:	          /* marks which fields in this structure are defined */
    .struct Hints_flags + 4
Hints_input:	          /* does this application rely on the window manager to
				   get keyboard input? */
    .struct Hints_input + 4	
Hints_initial_state:	         
    .struct Hints_initial_state + 4	
Hints_icon_pixmap:	         /* pixmap to be used as icon */
    .struct Hints_icon_pixmap + 4	
Hints_icon_window:	         /* window to be used as icon */
    .struct Hints_icon_window + 4	
Hints_icon_x:	         /* initial position of icon */
    .struct Hints_icon_x + 4	
Hints_icon_y:	         
    .struct Hints_icon_y + 4	
Hints_icon_mask:	         	/* pixmap to be used as mask for icon_pixmap */
    .struct Hints_icon_mask + 4		
Hints_window_group:	         /* id of related window group */
    .struct Hints_window_group + 4	
Hints_fin:
/*******************FIN*****************************/	
/* structure de type   XSizeHints   */
    .struct  0
XSize_flags:	          /* marks which fields in this structure are defined */
    .struct XSize_flags + 4
XSize_x:	          
    .struct XSize_x + 4
XSize_y:	          
    .struct XSize_y + 4
XSize_width:	          
    .struct XSize_width + 4
XSize_height:	          
    .struct XSize_height + 4
XSize_min_width:	          
    .struct XSize_min_width + 4	
XSize_min_height:	          
    .struct XSize_min_height + 4	
XSize_max_width:	          
    .struct XSize_max_width + 4	
XSize_max_height:	          
    .struct XSize_min_height + 4		
XSize_width_inc:	          
    .struct XSize_width_inc + 4	
XSize_height_inc:	          
    .struct XSize_height_inc + 4	
XSize_min_aspect_x:	          
    .struct XSize_min_aspect_x + 4	
XSize_min_aspect_y:	          
    .struct XSize_min_aspect_y + 4	
XSize_max_aspect_x:	          
    .struct XSize_max_aspect_x + 4	
XSize_max_aspect_y:	          
    .struct XSize_max_aspect_y + 4		
XSize_base_width:	          
    .struct XSize_base_width + 4	
XSize_base_height:	          
    .struct XSize_base_height + 4
XSize_win_gravity:	          
    .struct XSize_win_gravity + 4	
XSize_fin:	
/*******************FIN*****************************/	
/* structure de type   XTextProperty   */
    .struct  0
XText_value:	          /* property data */
    .struct XText_value + 4
XText_encoding:	          	/* type of property */
    .struct XText_encoding + 4
XText_format:	          	/* 8, 16, or 32 */
    .struct XText_format + 4	
XText_nitems:	          	/* number of items in value */
    .struct XText_nitems + 4	
XText_fin:

/*******************FIN*****************************/
/* structure de type   XColor   */
    .struct  0
XColor_pixel:	          	/* pixel value */
    .struct XColor_pixel + 4
XColor_red:	          	/* pixel value   TODO A VERIFIER */
    .struct XColor_red + 4
XColor_green:	          	/* pixel value */
    .struct XColor_green + 4
XColor_blue:	          	/* pixel value */
    .struct XColor_blue + 4	
XColor_flags:	          	/* DoRed, DoGreen, DoBlue */	
    .struct XColor_flags + 4	
XColor_pad:	          	/* pixel value */
    .struct XColor_pad + 4
XColor_fin:	
/*******************FIN*****************************/
/* structure de type   XWindowChanges   */
    .struct  0
XWCH_x:
	.struct XWCH_x + 4
XWCH_y:
	.struct XWCH_y + 4
XWCH_width:
	.struct XWCH_width + 4
XWCH_height:
	.struct XWCH_height + 4
XWCH_border_width:
	.struct XWCH_border_width + 4
XWCH_sibling:
	.struct XWCH_sibling + 4
XWCH_stack_mode:
	.struct XWCH_stack_mode + 4
XWCH_fin:



/* structure FSCREENINFO */	
/* voir explication détaillée : https://www.kernel.org/doc/Documentation/fb/api.txt */
    .struct  0
FBFIXSCinfo_id:	      /* identification string eg "TT Builtin" */
    .struct FBFIXSCinfo_id + 16  
FBFIXSCinfo_smem_start:	/* Start of frame buffer mem */
	.struct FBFIXSCinfo_smem_start + 4   
FBFIXSCinfo_smem_len:	   /* Length of frame buffer mem */
	.struct FBFIXSCinfo_smem_len + 4   
FBFIXSCinfo_type:	/* see FB_TYPE_*		*/
	.struct FBFIXSCinfo_type + 4  
FBFIXSCinfo_type_aux:	  /* Interleave for interleaved Planes */
	.struct FBFIXSCinfo_type_aux + 4  
FBFIXSCinfo_visual:	/* see FB_VISUAL_*		*/
	.struct FBFIXSCinfo_visual + 4  
FBFIXSCinfo_xpanstep:	/* zero if no hardware panning  */
	.struct FBFIXSCinfo_xpanstep + 2  	
FBFIXSCinfo_ypanstep:	/* zero if no hardware panning  */
	.struct FBFIXSCinfo_ypanstep + 2 
FBFIXSCinfo_ywrapstep:	  /* zero if no hardware ywrap    */
	.struct FBFIXSCinfo_ywrapstep + 4 
FBFIXSCinfo_line_length:	/* length of a line in bytes    */
	.struct FBFIXSCinfo_line_length + 4 
FBFIXSCinfo_mmio_start:	 /* Start of Memory Mapped I/O   */
	.struct FBFIXSCinfo_mmio_start + 4 	
FBFIXSCinfo_mmio_len:	    /* Length of Memory Mapped I/O  */
	.struct FBFIXSCinfo_mmio_len + 4 
FBFIXSCinfo_accel:	 /* Indicate to driver which	specific chip/card we have	*/
	.struct FBFIXSCinfo_accel + 4 
FBFIXSCinfo_capabilities:	 /* see FB_CAP_*			*/
	.struct FBFIXSCinfo_capabilities + 4 
FBFIXSCinfo_reserved:	 /* Reserved for future compatibility */
	.struct FBFIXSCinfo_reserved + 8	
FBFIXSCinfo_fin:

/* structure VSCREENINFO */	
    .struct  0
FBVARSCinfo_xres:	       /* visible resolution		*/ 
    .struct FBVARSCinfo_xres + 4  
FBVARSCinfo_yres:	      
    .struct FBVARSCinfo_yres + 4 
FBVARSCinfo_xres_virtual:	      /* virtual resolution		*/
    .struct FBVARSCinfo_xres_virtual + 4 
FBVARSCinfo_yres_virtual:	      
    .struct FBVARSCinfo_yres_virtual + 4 
FBVARSCinfo_xoffset:	      /* offset from virtual to visible resolution */
    .struct FBVARSCinfo_xoffset + 4 
FBVARSCinfo_yoffset:	      
    .struct FBVARSCinfo_yoffset + 4 
FBVARSCinfo_bits_per_pixel:	      /* bits par pixel */
    .struct FBVARSCinfo_bits_per_pixel + 4 	
FBVARSCinfo_grayscale:	      /* 0 = color, 1 = grayscale,  >1 = FOURCC	*/
    .struct FBVARSCinfo_grayscale + 4 
FBVARSCinfo_red:	      /* bitfield in fb mem if true color, */
    .struct FBVARSCinfo_red + 4 
FBVARSCinfo_green:	      /* else only length is significant */
    .struct FBVARSCinfo_green + 4 
FBVARSCinfo_blue:	      
    .struct FBVARSCinfo_blue + 4 
FBVARSCinfo_transp:	      /* transparency			*/
    .struct FBVARSCinfo_transp + 4 	
FBVARSCinfo_nonstd:	      /* != 0 Non standard pixel format */
    .struct FBVARSCinfo_nonstd + 4 
FBVARSCinfo_activate:	      /* see FB_ACTIVATE_*		*/
    .struct FBVARSCinfo_activate + 4 	
FBVARSCinfo_height:	      	/* height of picture in mm    */
    .struct FBVARSCinfo_height + 4 
FBVARSCinfo_width:	       /* width of picture in mm     */
    .struct FBVARSCinfo_width + 4 
FBVARSCinfo_accel_flags:	      /* (OBSOLETE) see fb_info.flags */
    .struct FBVARSCinfo_accel_flags + 4 
/* Timing: All values in pixclocks, except pixclock (of course) */	
FBVARSCinfo_pixclock:	      /* pixel clock in ps (pico seconds) */
    .struct FBVARSCinfo_pixclock + 4 	
FBVARSCinfo_left_margin:	      
    .struct FBVARSCinfo_left_margin + 4 
FBVARSCinfo_right_margin:	      
    .struct FBVARSCinfo_right_margin + 4 
FBVARSCinfo_upper_margin:	      
    .struct FBVARSCinfo_upper_margin + 4 
FBVARSCinfo_lower_margin:	      
    .struct FBVARSCinfo_lower_margin + 4 
FBVARSCinfo_hsync_len:	      /* length of horizontal sync	*/
    .struct FBVARSCinfo_hsync_len + 4 	
FBVARSCinfo_vsync_len:	      /* length of vertical sync	*/
    .struct FBVARSCinfo_vsync_len + 4 
FBVARSCinfo_sync:	      /* see FB_SYNC_*		*/
    .struct FBVARSCinfo_sync + 4 
FBVARSCinfo_vmode:	      /* see FB_VMODE_*		*/
    .struct FBVARSCinfo_vmode + 4 
FBVARSCinfo_rotate:	      /* angle we rotate counter clockwise */
    .struct FBVARSCinfo_rotate + 4 	
FBVARSCinfo_colorspace:	      /* colorspace for FOURCC-based modes */
    .struct FBVARSCinfo_colorspace + 4 	
FBVARSCinfo_reserved:	      /* Reserved for future compatibility */
    .struct FBVARSCinfo_reserved + 16		
FBVARSCinfo_fin:	
/* structure de type timespec */
    .struct  0
tv_sec:	  /* seconds */
    .struct  tv_sec + 4 
tv_nsec:	  /* nanoseconds */
    .struct  tv_nsec + 4	
tv_fin:
/*********************************/
/* structures pour fichier BMP   */
/* description des entêtes       */
/* structure de type  BITMAPFILEHEADER */
    .struct  0
BMFH_bfType:	          /* identification du type de fichier */
    .struct BMFH_bfType + 2
BMFH_bfSize:	          /* taille de la structure */
    .struct BMFH_bfSize + 4
BMFH_bfReserved1:	          /* reservée */
    .struct BMFH_bfReserved1 + 2	
BMFH_bfReserved2:	          /* reservée */
    .struct BMFH_bfReserved2 + 2	
BMFH_bfOffBits:	          /* Offset pour le début de l'image */
    .struct BMFH_bfOffBits + 4	
BMFH_fin:	
/***************************************/
/* structure de type  BITMAPINFOHEADER */
    .struct  0
BMIH_biSize:	          /* taille */
    .struct BMIH_biSize + 4
BMIH_biWidth:	          /* largeur image */
    .struct BMIH_biWidth + 4	
BMIH_biHeight:	          /* hauteur image */
    .struct BMIH_biHeight + 4
BMIH_biPlanes:	          /* nombre plan */
    .struct BMIH_biPlanes + 2
BMIH_biBitCount:	          /* nombre bits par pixel */
    .struct BMIH_biBitCount + 2
BMIH_biCompression:	          /* type de compression */
    .struct BMIH_biCompression + 4
BMIH_biSizeImage:	          /* taille image */
    .struct BMIH_biSizeImage + 4
BMIH_biXPelsPerMeter:	          /* pixel horizontal par metre */
    .struct BMIH_biXPelsPerMeter + 4
BMIH_biYPelsPerMeter:	          /* pixel vertical par metre */
    .struct BMIH_biYPelsPerMeter + 4
BMIH_biClrUsed:	          /*  */
    .struct BMIH_biClrUsed + 4
BMIH_biClrImportant:	          /*  */
    .struct BMIH_biClrImportant + 4
/* A REVOIR car BITMAPINFO */		
BMIH_rgbBlue:	          /* octet bleu */
    .struct BMIH_rgbBlue + 1
BMIH_rgbGreen:	          /* octet vert */
    .struct BMIH_rgbGreen + 1
BMIH_rgbRed:	          /* octet rouge */
    .struct BMIH_rgbRed + 1
BMIH_rgbReserved:	          /* reserve */
    .struct BMIH_rgbReserved + 1	
BMIH_fin:	
/**********************************************/
/* structure de type   image Bmp  */
    .struct  0
BMP_largeur:	           /* largeur en pixel de l'image */
    .struct BMP_largeur + 4
BMP_hauteur:	           /* hauteur en pixel de l'image */
    .struct BMP_hauteur + 4
BMP_debut_pixel:	           /* pointeur début des pixels de l'image */
    .struct BMP_debut_pixel + 4
BMP_imageX11:
	.struct BMP_imageX11 + 4
BMP_fin:
/**********************************************/
/* structure de type   image JPEG  */
    .struct  0
JPEG_largeur:	           /* largeur en pixel de l'image */
    .struct JPEG_largeur + 4
JPEG_hauteur:	           /* hauteur en pixel de l'image */
    .struct JPEG_hauteur + 4
JPEG_debut_pixel:	           /* pointeur début des pixels de l'image */
    .struct JPEG_debut_pixel + 4
JPEG_imageX11:
	.struct JPEG_imageX11 + 4
JPEG_fin:
/**********************************************/
/* structure de type  jpeg_error_mgr */
    .struct  0
jpeg_error_error_exit:	          
    .struct jpeg_error_error_exit + 4
jpeg_error_emit_message:	          
    .struct jpeg_error_emit_message + 4
jpeg_error_output_message:	          
    .struct jpeg_error_output_message + 4
jpeg_error_format_message:	          
    .struct jpeg_error_format_message + 4
jpeg_error_reset_error_mgr:	          
    .struct jpeg_error_reset_error_mgr + 4
jpeg_error_msg_code:	          
    .struct jpeg_error_msg_code + 4
jpeg_error_msg_parm:	          
    .struct jpeg_error_msg_parm + 80
jpeg_error_trace_level:	          
    .struct jpeg_error_trace_level + 4
jpeg_error_num_warnings:	          
    .struct jpeg_error_num_warnings + 4
jpeg_error_jpeg_message_table:	          
    .struct jpeg_error_jpeg_message_table + 4
jpeg_error_addon_message_table:	          
    .struct jpeg_error_addon_message_table + 4
jpeg_error_first_addon_message:	          
    .struct jpeg_error_first_addon_message + 4
jpeg_error_last_addon_message:	          
    .struct jpeg_error_last_addon_message + 4
jpeg_error_setjmp_buffer:              @ ajout zone pour structure my_error_mgr
    .struct jpeg_error_setjmp_buffer + 4
jpeg_error_fin:
/**********************************************/
/* structure de type  jpeg_decompress_struct */
    .struct  0
jpeg_decompress_err:	          
    .struct jpeg_decompress_err + 4
jpeg_decompress_mem:	          
    .struct jpeg_decompress_mem + 4
jpeg_decompress_progress:	          
    .struct jpeg_decompress_progress + 4
jpeg_decompress_client_data:	          
    .struct jpeg_decompress_client_data + 4
jpeg_decompress_is_decompressor:	          
    .struct jpeg_decompress_is_decompressor + 4
jpeg_decompress_global_state:	          
    .struct jpeg_decompress_global_state + 4
jpeg_decompress_src:	          
    .struct jpeg_decompress_src + 4
jpeg_decompress_image_width:	          
    .struct jpeg_decompress_image_width + 4
jpeg_decompress_image_height:	          
    .struct jpeg_decompress_image_height + 4
jpeg_decompress_num_components:	          
    .struct jpeg_decompress_num_components + 4
jpeg_decompress_jpeg_color_space:	          
    .struct jpeg_decompress_jpeg_color_space + 4
jpeg_decompress_out_color_space:	          
    .struct jpeg_decompress_out_color_space + 4
jpeg_decompress_scale_num:	          
    .struct jpeg_decompress_scale_num + 4
jpeg_decompress_scale_denom:	          
    .struct jpeg_decompress_scale_denom + 4
jpeg_decompress_output_gamma:	          
    .struct jpeg_decompress_output_gamma + 4
jpeg_decompress_buffered_image:	          
    .struct jpeg_decompress_buffered_image + 4
jpeg_decompress_raw_data_out:	          
    .struct jpeg_decompress_raw_data_out + 4
jpeg_decompress_zonesadefinir:	          
    .struct jpeg_decompress_zonesadefinir + 40
jpeg_decompress_output_width:	          
    .struct jpeg_decompress_output_width + 4
jpeg_decompress_output_height:	          
    .struct jpeg_decompress_output_height + 4
jpeg_decompress_out_color_components:	          
    .struct jpeg_decompress_out_color_components + 4
jpeg_decompress_output_components:	          
    .struct jpeg_decompress_output_components + 4
jpeg_decompress_rec_outbuf_height:	          
    .struct jpeg_decompress_rec_outbuf_height + 4
jpeg_decompress_actual_number_of_colors:	          
    .struct jpeg_decompress_actual_number_of_colors + 4
jpeg_decompress_colormap:	          
    .struct jpeg_decompress_colormap + 4
jpeg_decompress_output_scanline:	          
    .struct jpeg_decompress_output_scanline + 4
jpeg_decompress_autres_zones:	          
    .struct jpeg_decompress_autres_zones + 324
jpeg_decompress_fin:            /* la taille doit être de 464 octets */
/**********************************************/
/* structure de type   stat  : infos fichier  */
    .struct  0
Stat_dev_t:	           /* ID of device containing file */
    .struct Stat_dev_t + 4
Stat_ino_t:	          /* inode */
    .struct Stat_ino_t + 2
Stat_mode_t:	          /* File type and mode */
    .struct Stat_mode_t + 2	
Stat_nlink_t:	           /* Number of hard links */
    .struct Stat_nlink_t + 2	
Stat_uid_t:	           /* User ID of owner */
    .struct Stat_uid_t + 2 
Stat_gid_t:	             /* Group ID of owner */
    .struct Stat_gid_t + 2 	
Stat_rdev_t:	            /* Device ID (if special file) */
    .struct Stat_rdev_t + 2 
Stat_size_deb:           /* la taille est sur 8 octets si gros fichiers */
	 .struct Stat_size_deb + 4 
Stat_size_t:	            /* Total size, in bytes */
    .struct Stat_size_t + 4 	
Stat_blksize_t:	            /* Block size for filesystem I/O */
    .struct Stat_blksize_t + 4 	
Stat_blkcnt_t:	           /* Number of 512B blocks allocated */
    .struct Stat_blkcnt_t + 4 	
Stat_atime:	           /*   date et heure fichier */
    .struct Stat_atime + 8     
Stat_mtime:	           /*   date et heure modif fichier */
    .struct Stat_atime + 8 
Stat_ctime:	           /*   date et heure creation fichier */
    .struct Stat_atime + 8 	
Stat_Fin:		
