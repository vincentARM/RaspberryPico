### Chapitre 13 : communication entre le pico et un pc sans utilisation du sdk.

Dans les exemples de programme en langage C pour le pico, nous trouvons dans le répertoire usb/device le programme de bas niveau dev_lowlevel.c ainsi qu’un script en python pour envoyer et recevoir un message au pico.

Nous allons nous inspirer de ce programme, pour récrire les fonctions en langage assembleur ARM. Je ne vous cache pas que cela a été un gros travail surtout pour la mise au point car je n’utilise pas les pins servant au debugger.

Les routines usb sont déportées dans le programme routinesUSB.s, les routines générales dans le programme routinesPicoArm.s.

Dans le programme principal nous initialisons les données necessaires au fonctionnement sans SDK, les horloges et le GPIO.

Nous appelons la routine d’initialisation du port USB et nous entrons dans une boucle pour attendre que l’ordinateur maître (sous Windows ou Linux) se connecte.
Ensuite nous envoyons les messages d’invite puis nous attendons la réponse pour lancer quelques commandes.

Maintenant voyons le programme des routines USB. Nous trouvons les constantes nécessaires au fonctionnement puis la description des structures du protocole USB.
Dans la .data, nous trouvons les valeurs des descriptifs du protocole USB : descriptif du périphérique (device descriptor), le descriptif de configuration, les endpoints etc.

Dans la procèdure initUsbDevice nous reprenons les fonctionnalités du programme C donné en exemple avec la particularité de forcer la fonction appelée par l’interruption USB dans la table des vecteurs (VTOR).

Après l’activation de l’interruption, nous entrons dans une boucle d’attente. En effet le host va déclencher l’interruption dès la connexion de la prise usb ce qui va entraîner les échanges successifs du protocole USB ( et qui n’est pas simple!!)

Si le host reconnaît bien le protocole la boucle se termine et rend la main au programme principal.

Maintenant, il faut lancer le script python dev_lowlevel_loopback1 sur le host pour établier la communication avec le pico.

Le script d’origine a été modifié pour pouvoir gérer cette communication. Il récupère les informations de la connexion USB et envoie le message Pret au pico. 
Dès ce moment celui ci peut envoyer et recevoir des messages.

Tout cela fonctionne correctement et bien sûr peut être grandement amélioré car les routines ne sont pas toujours bien écrites et optimisées. Cela permet d’effectuer des échanges avec la seule liaison USB et sans passer par le SDK.
