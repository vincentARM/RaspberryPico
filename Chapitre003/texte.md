# Chapitre 3 :  Boucle de commandes

Dans ce programme, nous allons voir la saisie et l’exécution d’une commande sur le terminal putty.

Voir les fichiers du répertoire P1 de ce chapitre. 

Comme précédemment, le programme commence par attendre la connexion du terminal puis affiche le message d’invite.

Pour la saisie de la chaîne de caractère, nous appelons la routine getchar_timeout_us qui attend la frappe d’un caractère. Nous stockons le caractère saisi dans un buffer jusqu’à avoir un caractère de fin (0 ou 0xd). Chaque caractère est affiché pour avoir un retour sur le terminal.

Cette routine est succincte et doit être améliorée pour gérer l’annulation d’un caractère, le retour arrière etc .

Après la saisie, le contenu du buffer est comparé au libellé de la commande (ici il est unique et égal à aff) et si égal nous appelons la routine à exécuter. 

Comme exemple, nous allons afficher le contenu d’un registre mémoire ( ou 4 octets d ‘une zone mémoire) et pour cela nous demandons l’adresse en hexa de l’emplacement à afficher. 

Comme l’adresse saisie est une chaîne de caractère, il nous faut convertir celle ci en une valeur hexa grâce à la routine convertirChHexa.

Pour contrôle nous affichons l’adresse résultat puis nous affichons le contenu mémoire de cette adresse. 

Nous pouvons maintenant afficher le contenu des registres indiqués dans la datasheet pour voir leur contenu. Mais attention, certains registres ne sont pas accessibles et le programme se bloque !!

Voici un exemple d’exécution pour afficher le registre ctrl du ring ocillator :


>Valeur du registre : 20042000     *(remarque : ceci est pour vérifier l’adresse de la pile)*
>Entrez une commande :
>aff
>Adresse du registre en hexa ?:
>40060000
>Valeur du registre : 40060000
>Valeur du registre : 00FAB000
>Entrez une commande :


Bien ! Maintenant nous allons poursuivre pour étoffer ces commandes. Dans le programme suivant (voir les fichiers dans le répertoire P2 de ce chapitre) nous allons afficher en binaire le contenu d’un registre mémoire. En effet, la datasheet donne la décomposition du contenu des registres mémoire et souvent il s’agit de données de taille de quelques bits.

Nous allons aussi afficher une zone mémoire d’une taille de 4 blocs (soit 4 * 16 octets) en hexadécimal et en ascii en demandant l’adresse de début de la zone.

Nous allons aussi tester  l »accès à une fonction programmée dans le rom et nous en servir pour effectuer un reset du pico. Cela va éviter de déconnecter la prise USB pour effectuer la copie du fichier uf2.

Voyons dans le détail :
Le programme commence par attendre la connexion du terminal puis entre dans l’attente de la frappe d »une commande. Nous allons avoir les commandes aff (vue dans le programme précédent, bin, mem, fct et fin.
La commande bin va demander à l’utilisateur l’adresse du registre à afficher puis affiche son contenu en binaire avec un espace tous les 8 octets pour augmenter la lisibilité.
La commande mem va demander à l’utilisateur l’adresse du début de zone à afficher puis va afficher octet par octets les 4 blocs de 18 octets. Cette affichage est copié sur celui écrit pour un raspberry pi 32 bits !!

La commande fct va effectuer l’appel à une fonction préprogrammée de la rom (voir les descriptions au paragraphe 2?8 de la datasheet). Nous allons tester la fonction de codes P3 qui compte le nombre de bits à 1 contenu dans un registre système. Pour cela il faut traduire les codes en déplacement pour accéder à une table qui va indiquer l’adresse de la fonction dans la rom. Il nous suffit ensuite d’appeler cette fonction avec la valeur à tester.

Nous terminons en utilisant cette routine pour effectuer la réinitialisation du pico avec les codes UB ce qui entraîne automatiquement la reconnexion en mode stockage USB. Cela permet de recopier le fichier UF2 sans avoir à débrancher le câble usb et à le rebrancher en appuyant sur le bouton de boot.

Voici un exemple d'exécution :

>Début du programme.
>
>Entrez une commande :
>
>bin
>
>Adresse du registre en hexa ?:
>
>40060000
>
>Affichage binaire : 00000000 11111111 11111010 10100000
>
>Entrez une commande :
>
>aff
>
>Adresse du registre en hexa ?:
>
>40060000
>
>Valeur du registre : 40060000
>
>Valeur du registre : 00FFFAA0
>
>Entrez une commande :
>
>mem
>
>Adresse du registre en hexa ?:
>
>20000000
>
>Valeur du registre : 20000000
>
>Affichage mémoire  adresse : 20000000
>
>20000000 *00 20 04 20 13 01 00 10 C3 02 00 10 C5 02 00 10  . . ............
>
>20000010  C1 02 00 10 C1 02 00 10 C1 02 00 10 C1 02 00 10  ................
>
>20000020  C1 02 00 10 C1 02 00 10 C1 02 00 10 C7 02 00 10  ................
>
>20000030  C1 02 00 10 C1 02 00 10 C9 02 00 10 CB 02 00 10  ................
>
>Entrez une commande :
>
>fct
>
>ResultatFonction
>
>Valeur du registre : 00000001
>
>Entrez une commande :
>
>fin
>
