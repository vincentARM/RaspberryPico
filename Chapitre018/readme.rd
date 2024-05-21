Programme serveur web  avec le picoW

Après plusieurs mois d’absence, je reviens sur le raspberry pico  mais cette fois ci sur le modèle W avec la puce Wifi.

Après avoir testé d’anciens programmes assembleur sur ce modèle, je m’intéresse aux fonctionnalités wifi offertes tout d’abord en reprenant le serveur web écrit en python et bien documenté dans le manuel :
J’essaie de trouver la même démarche pour un serveur web écrit avec le SDK C++ mais il n-y a que quelques exemples de serveur et client TCP. A partir de l’exemple du serveur tcp, j’ écris et teste un serveur web en langage C ce qui me permet d’apprendre les fonctions  des librairies cw et lwip (voir le projet : ).
Maintenant passons à l’assembleur. L’utilisation des librairies cyw43 et lwip nous impose de compiler avec le SDK C++.

Dans le programme, serveurasmwifi.s  nous commençons par décrire la structure tcp pour gérer les échanges  et la structure pbuf pour récupérer les données retournées par la pile tcp.
Dans un premier temps, nous utilisons la définition de la structure tcp de l’exemple fourni dans les exemples picoW du serveur et client tcp.
Dans la .data, nous décrivons tous les libellés des commandes dont nous avons besoin. Nous décrivons en particulier sur 2 lignes le formulaire html qui va nous servir pour communiquer avec le navigateur.
Dans le main du programme, nous initialisons les données du pico avec stdio_init_all, les données du wifi avec cyw43_arch_init et les données du capteur de température avec initADC.
Si ces premières étapes se passent bien la led clignote 2 fois. Remarque, pour la led nous utilisons la fonction fournie par la bibliothèque  cyw43_arch_gpio_put.
Nous appelons la routine lancementServeur qui va établir la communication et ouvrir le serveur tcp.  Il vous faudra mettre à jour le code de votre réseau (de votre box) et votre mot de passe (la clè wifi). Si la connexion s’effectue correctement la led clignote 5 fois.
La routine tcp_server_open prépare l’appel de la fonction tcp.accept qui permet l’appel de notre propre fonction. En effet c’est la pile tcp de la librairie lwip qui appelle nos fonctions en fonction des échanges reçus.
Ensuite nous trouvons la boucle principale qui appelle sys_check_timeouts et cyw43_arch_poll. Cette boucle se terminera lorsque l’indicateur serveur actif passera à 1.
A partir de là le serveur attend une connexion d’un navigateur sur le port 80. Il faut donc que vous recuperiez l’adresse IP de votre picoW sur votre réseau (le mieux est de fixer une adresse IP sur votre box pour éviter d’avoir à chercher à chaque fois l’adresse ip attribuée) et de la saisir dans votre navigateur. 
A réception de la connexion, la routine accept de lwip va appeler notre propre fonction tcp_server_accept dans laquelle nous allons positionner nos propres fonctions à appeler pour envoyer, recevoir des messages, et gérer les erreurs. Vous remarquerez qu’il faut positionner un code retour à 0 pour indiquer à lwip que notre fonction est ok.
Aprés l’appel à accept, lwip appelle la fonction tcp_server_recv avec le contenu du message reçu. Cette fonction sera appelée par lwip à chaqueréception d’un message du navigateur. C’est donc la fonction la plus importante puisqu’elle devra analyser les messages reçus et préparer les réponses à retourner au navigateur.
Nous renvoyons les instructions html de description du formulaire par l’intermédiaire de la routine tcp_server_sent_datas.  Il faut d’abord Initialiser avec des blancs, le buffer d’écriture puis écrire l’entête HTML puis les données du formulaire.
On écrit aussi la ligne qui contient le message de retour.

La routine d’analyse des commandes se contente de comparer les chaines reçues avec les libellés puis d’exécuter la commande identifiée.
Pour compiler et exécuter le programme, il faut créer un répertoire sous windows et copier tous les fichiers du répertoire ci joint, modifier dans le programme assembleur le nom de votre réseau et le mot de passe de la box. Il faut créer un sous répertoire build, se placer dedans et executez :

cmake -DPICO_BOARD=pico_w  -DPython3_EXECUTABLE=C:\Users\Vincent\AppData\Local\Microsoft\WindowsApps\python3.10.exe -G "NMake Makefiles"  .
Si le résultat est correct, compilez par nmake puis copier le fichier uf2 dans votre pico, suivez le clignotement de la led puis connecter vous à partir d’un navigateur à l’adresse IP du picoW.
Ce programme est autonome et donc doit fonctionner sans connexion usb.
En cas d’anomalie, vérifier vos paramètres réseau, adresse IP, code SSID, mot de passe. Fernez et relancez votre navigateur ou supprimer le cache des données.
Si vous ne trouvez pas le problème il faut intégrer ce programme dans un et précédent projet qui contient les accès par la liaison USB  et ajouter des messages de debugging ou utiliser toute méthode de debugging que vous connaissez.

