### Chapitre 15 : affichage d’une valeur en virgule flottante (Float 32 bits)

Avec le pico, nous pouvons effectuer des calculs en virgule flottante en appelant les fonctions préprogrammées de la Rom.

Mais en assembleur, nous n’avons pas la possibilité d’afficher le résultat. Dans un premier temps j’ai essayé de reprendre l’algorithme grisu que j’avais porté en assembleur arm pour le raspberry pi mais celui ci était prévu pour des floats en double précision. Or la version 1 des fonctions de la rom ne gère que des floats simple précision (sur 32 bits).

En recherchant des informations complémentaires sur Grisu et Dragon4, je trouve un autre algorithme de Benoit Blanchon https://blog.benoitblanchon.fr/lightweight-float-to-string/  beaucoup plus simple.

Dans le programme affFloatA.s vous trouverez cet algorithme avec quelques cas de tests. Il est a adapter en fonction des sorties que vous voulez avoir car il comporte quelques lacunes.

Par exemple, pour des valeurs inférieure à 1E7, il affiche  valeurE0  ce qui n’est pas terrible !!

Et pour certaines valeurs qui ne peuvent être qu’approchées par la norme IEEE754, l’affichage n’est pas arrondi !!

Enfin, il y a une erreur lors de la multiplication d’une valeur inférieure à 1E-37 par la valeur 1E38 qui donne 0 alors que ces 2 valeurs sont bien dans la limite des floats simple précision. Ceci entraîne que l’affichage est faux pour toute valeurs inférieure à 1E-37.
Voici un exemple des résultats :
 ```
Tapez une commande :
fct
Cas du 0+
Valeur du registre : 00000002
+0
Cas du 0-
Valeur du registre : 00000002
-0
Cas du Nan
Valeur du registre : 00000003
Nan
Cas de l'infini positif
Valeur du registre : 00000004
+Inf
Cas de l'infini negatif
Valeur du registre : 00000004
-Inf
Autres cas
Valeur du registre : 0000000F
+1,234500048E20
Valeur du registre : 0000000C
+10,123456E0
Valeur du registre : 00000006
+0E-63
Valeur du registre : 0000000F
+3,399999616E38
Valeur du registre : 0000000F
-3,399999616E38
Valeur du registre : 00000013
+123456,703124992E0
Tapez une commande :
```
