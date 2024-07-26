Librairie légére pico client X11

Dans ce chapitre nous allons créer une petite librairie pour un client X11. Bien sûr toutes les fonctions de X11 ne seront pas développées mais nous verrons les principales pour créer une fenêtre, des boutons etc.  Il existe quelques petites différences avec les fonctions standard X11 dues au mode de fonctionnement de la libraire lwip et le mécanisme de tcp_ip.

Dans le projet, nous trouvons donc la librairie xlibx11pico.s et un programme permettant de tester toutes les fonctions : execlibx11asm.s.

Dans la routine principale de ce dernier, nous trouvons les initialisations et la boucle principale de lecture des commandes. Pour tester les routines X11 il faut saisie x11 comme commande.

Dans la routine testlibx11, nous commençons par créer une connexion wifi comme déja vu avec l’adresse IP du serveur X11, le nom du réseau et le mot de passe avec la fonction openConnexion. Puis nous appelons la pseudo fonction XopenDisplay qui se contente d’attendre le bon retour de lla routine précédente. Celle ci va retourner une structure de type tcp défini dans x11libPico.inc qui ressemble vaguement à la structure Display utilisée par les fonctions X11 standard.

Si la connexion est établie correctement, nous creons une fenêtre avec la fonctionXCreateSimpleWindow et nous ajoutons la routine qui va gérer les événements de la fenêtre par addProcEvent. En effet je n’ai pas trouvé mieux pour indiquer à la routine lwip de gérer les retours des événements X11.

Ensuite nous appelons la fonction XchangeWindowAttributs pour indiquer quels sont les événements de la fenêtre  à traiter, ici uniquement KeyPressed et ButtonPress. Puis nous affichons la fenêtre avec XmapWindow.

Nous ouvrons une police d’écriture particulière à notre serveur X11. Si vous n’avez pas cette police et si vous n’avez pas la possibilité de connaître la liste des polices de votre serveur, il faudra appeler la fonction XListFont et afficher le contenu pour voir les polices disponibles.

Nous créons un contexte graphique pour pouvoir dessiner par XcreateGC puis nous appelons les fonctions d’écriture et de dessin.
Enfin nous terminons par la boucle de gestion des événements avec la fonction XnextEvent. 
Cette fonction appellera la routine déclarée précédemment par la fonction addProcEvent ce qui permet à ce programme de gérer les événements.

En fin de boucle, nous fermons la connexion.

La routine procTraitEvents sera appelée par la fonction d’écoute de lwip. Elle contient les tests pour connaître le bouton appuyé et les autres événements. Ici j’ai fait très simple car je n’ai pas traité tous les événements qui peuvent arriver à une fenêtre et à ces composants (déplacement, agrandissement etc.).
L’appui sur les boutons ledon et ledoff permet d’allumer et d’éteindre la Led.

Pour l’écriture des fonctions de la librairie, je me suis appuyé sur la documentation complété  accessible à ce lien : https://www.x.org/releases/X11R7.7/doc/xproto/x11protocol.html

Dans le programme x11libpico.s, nous trouvons les différentes fonctions qui permettent de créer la connexion avec le serveur X11, et les fonctions de callback de la librairie lwip.

Ensuite nous trouvons les fonctions qui simulent les fonctions standard X11. Ces fonctions sont toutes du même modèle : préparation des informations de la requête puis envoie de la requête au serveur.

Pour utiliser ces programmes il faut recopier tous les fichiers dans un répertoire, modifier l’adresse IP de votre serveur X11, le nom de votre réseau et son mot de passe, créer le sous répertoire build, se positionner dedans et lancer les commandes :

cmake -DPICO_BOARD=pico_w  -G "NMake Makefiles"  ..
nmake

Puis il faut créer une connexion putty par l’intermédiaire du port USB et se connecter.
Voici un exemple de connexion :

Debut du programme.
Entrez une commande ( ou help) :
x11
Connexion en cours ...

openConnexion

Connexion OK

XOpenDisplay

tcp_client_connect

Version majeure OK

fin traitement infos serveur

Mémoire  adresse : 20015522  Fonts
20015520  51 00*3C 2D 61 64 6F 62 65 2D 68 65 6C 76 65 74  Q.<-adobe-helvet
20015530  69 63 61 2D 62 6F 6C 64 2D 6F 2D 6E 6F 72 6D 61  ica-bold-o-norma
20015540  6C 2D 2D 32 34 2D 32 34 30 2D 37 35 2D 37 35 2D  l--24-240-75-75-
20015550  70 2D 31 33 38 2D 69 73 6F 38 38 35 39 2D 31 3C  p-138-iso8859-1<
20015560  2D 61 64 6F 62 65 2D 68 65 6C 76 65 74 69 63 61  -adobe-helvetica
Fin dessin

Fermeture session

tcp_server_close

Fin fonction X11

Entrez une commande ( ou help) :

![Et l’image de l’écran du serveur X11 (Xming sous windows11) ](https://github.com/vincentARM/RaspberryPico/blob/main/Chapitre020/ecranX11picoW.jpg.png)
