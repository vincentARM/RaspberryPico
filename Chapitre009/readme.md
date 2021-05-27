#Chapitre 9 : Utilisation du 2ième cœur du Pico

Dans les exemples fournis en langage C, il y a un programme qui montre le lancement du 2ième cœur. Je l’ai pris tel quel pour le convertir en langage assembleur.

Dans le programme testPico11.s nous reprenons la gestion des commandes et pour la commande fct, nous appelons la routine lancementCore1.
Dans cette routine, nous appelons la routine d’initialisation en lui passant en paramètre la fonction que nous voulons que le cœur 1 exécute. Puis après un temps d’attente nous récupérons la valeur envoyée par le cœur 1 dans le registre r0 et nous l’affichons.
La routine executionCore1 que doit exécuter le coeur 1 ne contient que des affichages pour vérification et l’envoi de la valeur 123 au cœur 0 grâce à la fonction multicore_fifo_push_blocking.

Les fonctions multicore_fifo_push_blocking  et multicore_fifo_pop_blocking géré la file d’attente des messages entre les 2 coeurs (voir les explications dans la datasheet )

Revenons à la routine d’initialisation multicore_launch_core1 : elle prépare la sequence d’initialisation en stockant en fond de pile les adresses de la procédure du coeur1, l’adresse de la pile et les adresses de 2 sous-routines dont je n’ai pas compris l’utilité !!
Puis elle appelle la routine multicore_launch_core1_raw qui va envoyer une séquence de valeurs et comparer leur retour du coeur 1.
Elle commence par envoyer les valeurs 0, 0 et 1  puis l’adresse de la table des vecteurs (vtor) puis l’adresse de la pile – 12 octets puis l’adresse de la routine trampoline !!!
Si le coeur 1 répond correctement, la procédure d’initialisation est validée.

Dans les exemples en langage C il y a un autre exemple dont les calculs sont effectués par le coeur 1 mais je ne l’ai pas traduite en assembleur.

```
Exemple de résultat :
Début du programme
Reboot par watchdog !!
Entrez une commande :
fct
retourInitOK
core1_debut
core1
core0_2
```
