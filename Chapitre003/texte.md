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


Bien ! Maintenant nous allons poursuivre pour étoffer ces commandes.
