# Chapitre 2 :  affichage de message

Pour l’instant, je vais me contenter d’utiliser seulement le cable USB pour afficher les messages sur un terminal putty sous windows 10 en mode série. 

Tout d’abord, il faut vérifier à l’aide de l’exemple hello_usb en C fourni, l’affichage du message dans putty.

Il faut à l’aide du gestionnaire de périphériques W10, chercher le port sur lequel le pico est relié par le câble USB puis paramétrer dans Putty une connexion série avec le port trouvé et la fréquence de 115200.

Maintenant, nous pouvons écrire un programme assembleur (voir les fichiers du répertoire P1) qui affiche simplement un message en faisant appel à des routines de la librairie. En effet pour l’instant il n’est pas encore possible de réécrire en assembleur les routines de gestion du port usb. On verra cela plus tard !!!

Bien le programme affiche toutes les x secondes le message. 

Mais cela fait apparaître un problème si nous supprimons la boucle: la connexion à putty ne peut se faire que si le Pico est branché et dès que celui ci est connecté, le message est déjà parti et n’est plus visible.

La première idée qui vient et de commencer le programme par une boucle d’attente de 10 secondes, ce qui laisse le temps de lancer la connexion du putty. Mais c’est pas très joli comme solution.

Une recherche sur Internet me permet de découvrir une solution proposée pour le langage C. Il faut appeler la routine tud_cdc_n_connected dans une boucle. Celle çi ne se terminera que lorsque la connexion série à putty sera effective et le programme se poursuivra par l’affichage du message.

Je poursuis l’écriture de ce programme en écrivant une routine d’affichage du contenu d’un registre. Voir les fichiers du répertoire P2.
Le programme commence donc par une boucle d’attente puis appelle la routine d’affichage d’un registre. Ici nous passons la valeur de n’importe quel registre par push et cela oblige de réaligner la pile de 4 octets après l’appel.

Le programme se termine une simple boucle car il n’y a aucune fin prévue ( destination inconnue du pc!!!). On pourrait peut être ajouter un message de bonne fin du programme !!

Vous pouvez regarder le contenu du fichier .dis pour analyser toutes les routines générées et qu’il sera possible d’utiliser.

Voici le résultat :
>Début du programme.
>Valeur du registre : 20042000
