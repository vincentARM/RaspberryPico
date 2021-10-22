/* Programme assembleur ARM Raspberry pico */
/* Connexion USB OK sans utilisation du SDK */
.syntax unified
.cpu cortex-m0plus 
.thumb
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global convertirFloat
.thumb_func

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
//iAdrsZoneConvFloat:       .int sZoneConvFloat
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

