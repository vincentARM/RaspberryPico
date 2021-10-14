### Chapitre 16 ; mesure fréquence horloge, mesure de cycles

Dans le programme mesureC.s, nous allons repartir du programme précédent pour ajouter une commande qui affichera la fréquence d ‘une horloge après saisie de son numéro interne et une commande qui affichera le calcul du nombre de cycles d’une suite d’instructions. 
La commande fct affichera le nombre de cycle et le temps nécessaire à l’affichage d’une valeur float.
 
Voici la liste des horloges internes au pico.:
```
CLOCKS_FC0_SRC_VALUE_PLL_SYS_CLKSRC_PRIMARY 0x01
CLOCKS_FC0_SRC_VALUE_PLL_USB_CLKSRC_PRIMARY 0x02
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC            0x03
CLOCKS_FC0_SRC_VALUE_ROSC_CLKSRC_PH         0x04
CLOCKS_FC0_SRC_VALUE_XOSC_CLKSRC            0x05
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN0           0x06
CLOCKS_FC0_SRC_VALUE_CLKSRC_GPIN1           0x07
CLOCKS_FC0_SRC_VALUE_CLK_REF                0x08
CLOCKS_FC0_SRC_VALUE_CLK_SYS                0x09
CLOCKS_FC0_SRC_VALUE_CLK_PERI               0x0a
CLOCKS_FC0_SRC_VALUE_CLK_USB                0x0b
CLOCKS_FC0_SRC_VALUE_CLK_ADC                0x0c
CLOCKS_FC0_SRC_VALUE_CLK_RTC                0x0d
```
Pour afficher une fréquence il suffit de taper la commande clk puis lors de la demande le N° en hexa de l’horloge : exemple :
```
Tapez une commande :
clk
Numéro horloge (en hexa de 0 à 0d) ? :
8
Resultat en KHz :
12002
Tapez une commande :
```
Remarque : toutes les horloges ne sont pas actives !

La fonction calculerFrequence est la traduction en assembleur de celle donnée en C dans la datasheet du pico au paragraphe 2.15.6.2. Using the frequency counter.

La seule difficulté a été de trouver la fréquence de référence pour les calculs. Comme le programme part de l’initialisation de l’oscillateur cristal nous trouvons dans la documentation que sa fréquence est de 12 mHz soit 12000 Khz.

Pour la mesure du nombre de cycles, nous utilisons les registres du compteur systick que nous initialisons dans la routine debutSystick. Nous testons cette routine à vide.
Attention : la première mesure est anormale (mais il doit y avoir une explication) et il faut donc lancer plusieurs mesures.
Exemple :
```
Tapez une commande :
mes
Comptage cycles à vide
Nombre de cycles = 64
Comptage cycles instructions
Nombre de cycles = 167
Tapez une commande :
mes
Comptage cycles à vide
Nombre de cycles = 13
Comptage cycles instructions
Nombre de cycles = 16
Tapez une commande :
mes
Comptage cycles à vide
Nombre de cycles = 13
Comptage cycles instructions
Nombre de cycles = 16
Tapez une commande :
```
Vérifions le nombre de cycle à vide :
```
Pour terminer la routine débutSystick nous avons les instructions :
str r0,[r1]  soit 2 cycles
bx lr           soit 3 cycles
puis l’appel de la routine :
bl finSystick  soit 4 cycles
puis pour le début de la routine finSystick :
push {lr]      soit 2 cycles
ldr r0,iAdrSystick_SVR  soit 2 cycles
```
soit un total de 13 cycles.

Pour le calcul du nombre de cycles nécessaire à l’affichage d’un float nous avons :
```
Tapez une commande :
fct
Mesure temps conversion float
Valeur du registre : 0000000F
+3,399999616E38
Temps en µs = 8267
Mesure cycles conversion float
Valeur du registre : 0000000F
+3,399999616E38
Nombre de cycles = 1033334
```
C’est beaucoup mais il faut penser que nous avons le transfert des données sur le port USB.

Sachant qu’un cycle à 125Mhz dure 8 nano secondes nous avons 1033334 * 8 = 8 266 672 nano secondes soit 8266 microsecondes ce qui correspond bien au temps donnée par le timer.
