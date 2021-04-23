# Chapitre 7 : Particularités de l’assembleur arm thumb du pico

Voir la carte de référence des instructions ici :   [carte référence](https://developer.arm.com/documentation/qrc0006/e)

Il s’agit d’un jeu d’instructions réduit :

Une seule instruction de multiplication dont le résultat ne contient que dans un registre 32 bits. Il faudra donc écrire une multiplication qui donne le résultat sur 2 registres dans de nombreux calculs.

Pas d’instruction de division entière. Il faut faire appel à une manipulation des registres mémoire (voir le paragraphe 2.3.1.5. Integer Divider de la datasheet)

Pas d’instructions avec déplacement droite et gauche interne d’un registre. Donc pour la manipulation de tableaux il faut effectuer le calcul de l’offset avant la lecture ou l’écriture mémoire.

Et bien sûr pas d’instructions sur les nombres à virgule flottante mais il est possible d’utiliser des routines disponibles dans la rom.

La longueur des instructions étant de 16 bits, les valeurs immédiates sont limitées à 255.

Ce qui ne facilite pas le chargement d’un registre avec une valeur négative. Par exemple pour mettre -1 dans le registre r1, il faut mettre 0 d’abord puis soustraire 1 soit 2 instructions.

Pour d’autres valeurs, on peut utiliser l’instruction de déplacement puis une addition mais cela fait 3 instructions. Il est aussi possible d’utiliser une instruction ldr pour charger n’importe quelle constante (mais cela coûte 2 cycles).

Limite identique pour additionner une valeur dans un registre mais pire pour l’addition d’une valeur immédiate à un registre avec un registre destinataire différent : la limite est 7 (3 bits) !!!

Pareil pour la soustraction.

Pour l’instruction adr rx,label, le label ne peut pas être éloigné de plus de 1020 octets.

Pour les instructions ldr et str, le déplacement est de 124 octets maxi et attention, le résultat doit être aligné sur 4 octets.


Comme les instructions font 16 octets il faut aligner (.align 2) les déclarations d’adresse ou de constantes en fin de routines. Celles çi ne peuvent être que déclarées après leur utilisation car sinon le déplacement calculé est négatif et donc ne peut pas être stocké dans l’instruction.

Les opérations logiques (and, or, xor, not, tst ) ne peuvent se faire qu’entre registres.

Les instructions pop et push ne concerne que les 7 premiers registres + lr pour le push et cp pour le pop. Pour sauvegarder les autres, il faut d’abord sauvegarder les premiers puis mettre les seconds dans les premiers et sauvegarder puis recharger ceux qui contiennent les paramètres si nécessaire.

Les registres r8 à r12 ne peuvent pas être utilisés pour toutes les opérations : ils ne peuvent pas servir pour l'adressage mémoire.

Attention : si vous faites appel à des routines des librairies du SDK, ces routines ne sauvegardent pas les registres r0 à r3 et surtout pas le registre r12 !!!!!!

Dans certains cas, il faut mettre une adresse de routine impaire (lors de l’appel à partir d’un registre par exemple).

Je compléterais ces conseils au fur et à mesure des problèmes rencontrés.
