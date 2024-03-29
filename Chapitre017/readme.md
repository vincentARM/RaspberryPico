### Chapitre 17 : utilisation du coeur 1 pour la connexion USB

Nous allons reprendre les routines du chapitre  concernant l’utilisation du deuxième cœur du raspberry pour envoyer les messages sur la connexion USB vue dans un chapitre précédent. 

Les routines sont déportées dans le fichier routinesMulticore.s. Nous modifions la routine executionCore1 qui est exécutée par le coeur 1 pour attendre la réception de l’adresse d’un message avec la routine multicore_fifo_pop_blocking et pour l’envoyer vers la connexion usb en utilisant la routine envoyerMessage (routines USB).

Nous ajoutons une routine ecrireMessage qui enverra sur le coeur 1 l’adresse du message par la routine multicore_fifo_push_blocking.

Dans cette dernière, j’ai ajouté un temps d’attente nécessaire à la bonne expédition des messages successifs. Il doit être possible de trouver une autre solution car ce temps d’attente retarde l’exécution des routines du coeur 0.

J’ai essayé de le mettre dans la routine du coeur 1 mais cela entraîne un dysfonctionnement !!

Dans le fichier des routines routinePicoARM.s, nous modifions les envois de message pour appeler la routine ecrireMessage à la place d’envoyerMessage. 
Par ailleurs, j’ajoute une routine d’affichage des données de la mémoire en hexadécimal et en ascii afficherMemoire.

Dans le programme principal, il ne reste plus que les appels au différentes initialisations et à la gestion des commandes tapées par l’utilisateur.
Comme test, nous pouvons utiliser la commande mes qui affiche le nombre de cycles, la commande mem qui teste la routine d’affichage de la mémoire et une macro qui simplifie l’appel et la commande core qui envoie un message et affiche le nombre de cycles.

Voici un exemple de résultat :
```
Début du programme.
VerifAdressePile
Valeur du registre : 20041EE8
Tapez une commande :
mem
Affichage mémoire  adresse : 20000194
20000190  00 00 00 00*01 00 00 00 12 01 00 02 00 00 00 40  ...............@
200001A0  8A 2E 0A 00 00 01 00 00 00 01 08 0B 00 02 02 02  ................
200001B0  01 00 09 04 00 00 01 02 02 00 00 05 24 00 01 10  ............$...
200001C0  04 24 02 06 05 24 06 00 01 05 24 01 00 01 00 00  .$...$....$.....
Affichage mémoire  adresse : 200000F2
200000F0  0A 00*61 69 64 65 00 61 66 66 00 6D 65 6D 00 66  ..aide.aff.mem.f
20000100  69 6E 00 66 63 74 00 63 6F 72 65 00 62 69 6E 00  in.fct.core.bin.
20000110  6D 65 73 00 4C 69 73 74 65 20 64 65 73 20 63 6F  mes.Liste des co
20000120  6D 6D 61 6E 64 65 73 20 64 69 73 70 6F 6E 69 62  mmandes disponib
Tapez une commande :
mes
Comptage cycles à vide
Nombre de cycles = 219
Comptage cycles instructions
Nombre de cycles = 169
Tapez une commande :
core
test Core 1
Message envoi par core1
Nombre de cycles = 507395
Tapez une commande :
```
Une question se pose : est-on sûr que c’est bien le core 1 qui envoie les messages ?

Dans le fichier des routinesMulticoreB.s, j’ai ajouté l’affichage du registre cpuid dans les routines ecrireMessage et executionCore1 (attention, il faut utiliser la routine envoyerMessage pour éviter une boucle dans la routine envoiRegHexa).

Voici le résultat :
```
Tapez une commande :
Valeur du registre : 00000000
core
test Core 1
Valeur du registre : 00000000
Message envoi par core1
Valeur du registre : 00000001
Valeur du registre : 00000000
Nombre de cycles = 1187015
Valeur du registre : 00000000
Tapez une commande :
```
On voit bien que chaque routine est bien exécutée sur le bon cœur(cpuid = 0 ou 1).
