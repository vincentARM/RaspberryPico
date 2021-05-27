# Chapitre 8 : utilisation du bouton pour allumer la Led
Il est possible d’utiliser le bouton du pico et qui sert lors du boot à le faire passer en mode stockage, dans un programme assembleur.

Dans le programme testPico12.s nous allons l’utiliser pour allumer la Led. 

'''Attention : son utilisation n’est possible que si le programme est executé en mémoire ram et non pas en mémoire flash. 
Il faut mettre l’option pico_set_binary_type(testPico12 copy_to_ram) dans le fichier CmakeLists.txt pour qu’il fonctionne correctement (voir les explications dans les exemples fournis dans le programme button.c).

Le programme reprend la gestion des commandes comme dans les chapitres précédent et dans la commande fct nous avons ajouté l’appel à la fonction boutonLed. 

Dans celle çi nous commençons par initialiser le pin 25  (LED) du GPIO avec le minimum d’instructions nécessaire puis nous appelons la fonction etatPin pour détecter l’état du bouton.

Cette fonction positionne différentes valeurs dans les registres puis l’état et retourne la valeur 0 ou 1 suivanr si le bouton est appuyé ou non.

Je dois vous avouer que j’ai copié ces instructions dans les routines du SDK et que je n’ai pas encore bien compris leur fonctionnement. Mais ça marche !!!

Au retour de la fonction, nous nous contentons d’allumer ou d ‘eteindre la Led suivant son résultat.

Le programme boucle sur cet exemple et pour éviter un redémarrage il faut  penser à mettre à jour le compteur du watchdog.
