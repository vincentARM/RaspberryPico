Programme client telnet  avec le picoW

Maintenant que nous avons vu comment utiliser les fonctions de la librairie lwip, avec l’exemple du serveur web, nous allons les utiliser pour développer d’autres protocoles. L’utilisation du protocole internet pour piloter le pico est certes satisfaisant mais aussi assez contraignant.

Dans ce chapitre, nous allons écrire les fonctions pour le protocole Telnet, ce qui nous permettra de piloter le pico à partir d’un logiciel comme putty et non plus à partir d’un navigateur.

Dans le programme pgmtelenetAsm.s, nous allons accéder par telnet au pico pour allumer et éteindre la led et pour afficher sa Dans la fonction principale, nous intialisons température. Pour vous, il faudra saisir votre nomd de réseau et votre mot de passe avant de compiler le programme par cmake puis par make comme indiqué au chapitre précédent.
Dans la fonction principales nous commençons par initialiser, le pico, le wifi et l’ADC avec les fonctions stdio_init_all, cyw43_arch_init et initADC et nous appelons la routine lancementServeur.

Dans cette dernière,nous commençons par créer la connexion wifi avec vos paramètres puis nous ouvrons la connexion par la routine tcp_server_open. Nous utilisons le port 23 réservé aux connexion telnet et si tout se passe bien, la led émet 5 éclats .

Nous positionnons la fonction de callback accept pour attendre une connexion telnet.
Quand une connexion est établie, nous récupérons le pcb de la connexion et nous positionnons les callback des fonctions send,recv, pool et err.

Maintenant, tout va se jouer dans la fonction tcp_server_recv qui va analyser tous les envois du clien telnet et répondre à chaque message en appelant la routine execCommande.

Rien de bien compliqué et vous pouvez voir les instructions pour allumer et éteindre la led et retourner la température. Bien sûr cela est à compléter et à adapter à vos propres besoins.

Compiler sous window avec la commande suivante :

cmake -DPICO_BOARD=pico_w  -G "NMake Makefiles"  ..

puis nmake


Pour tester, il vous suffit de créer une connexion telnet par exemple dans putty avec l’adresse IP de votre pico, et le port 23. Le pico peut être totalement déconnecte du port usb de votre ordinateur puisque la connexion ne se fait qu’avec le Wifi.

Voici un exemple de connexion :

Entrez une commande : help pour la liste >help


test
temp
ledon
ledoff
help
fin

Entrez une commande : help pour la liste >temp


Temperature (en dixieme de degres) = 262

Entrez une commande : help pour la liste >

Remarque ; dans ce cas la fonction fin de fait rien, par contre si le pico est relié à un port usb, il passe en mode mise à jour.

