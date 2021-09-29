### Chapitre 14 : implantation du protocole USB CDC sans le sdk C++

Le programme précédent permettait les échanges entre PC et pico mais il fallait utiliser un script python.

Dans ce chapitre nous allons voir l’implantation du protocole USB de communication série ce qui permet de dialoguer directement en utilisant putty sur windows ou minicom sur raspberry.

Attention attention, je publie ce programme mais il est loin d’être parfait !! en particulier je ne suis pas arrivé à modifier le taux de transmission ; il reste figé à 9600 bauds !!!

Il est aussi très possible qu’il subsiste des erreurs dues à une mauvaise interprétation du protocole et à l’absence d’information sur le fonctionnement exact de la partie USB hardware du pico.

Les routines reprennent les grandes fonctionnalités du programme précédent en les adaptant aux particularités de la classe CDC : ajout des endpoints 2 et 3 par exemple et de la routine gestionCDC.

Cette routine présente d’ailleurs de graves lacunes car les gestions des requêtes 0x20, 0x21 et 0x22 ne sont pas rigoureuses car il me manque des informations sur leur fonctionnement.

Il faudra donc dans putty créer les données d’une autre session série avec un taux de transmission de 9600 bauds à la place des 115200 de la session normale. 

Pour le fonctionnement, voir les commentaires des routines.
