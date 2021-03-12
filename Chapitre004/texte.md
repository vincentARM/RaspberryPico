# Chapitre 4 : appel d'une fonction de la rom
Le pico contient une mémoire rom dans laquelle sont enregistrées plusieurs routines dont celles pour gérer le boot et la connexion en usb sous la forme d’une unité de stockage.

Dans le premier programme, nous allons voir l’accès à ces routines qui se fait d’une manière particulière. Nous utiliserons une de ces routines pour effectuer un reset du pico.
Voir les fichiers dans le répertoire P1.

Et tout d’abord, nous allons tester une macro d’affichage d’un libellé en utilisant l’appel à la routine   "__wrap_puts".  Cette macro nous permet d’afficher un libellé quelconque sans avoir à le déclarer dans la .data.

Nous retrouvons dans le code, les commandes déjà vues et pour la commande fct nous allons appeler la fonction qui calcule le nombre de bit à 1 d’un registre.

Pour cela la section 2.8.3.1.1 de la datasheet indique qu’il faut employer les codes P et 3. La documentation indique bien la marche à suivre et que nous allons traduire en assembleur :
Nous chargeons l’adresse de 2 tables : ptRom_table_lookup et ptFunctionTable (attention ces 2 adresses ne sont que sur 16 octets) et nous appelons la fonction qui va retourner l’adresse finale de la routine à appeler. 

Il nous faut bien sûr passer correctement la valeur en paramètre à la fonction. 

Vous pouvez tester d’autres routines en modifiant les codes d’appel.

Nous allons utiliser les codes U et B pour effectuer un reset du pico à partrir de la commande fin. Ainsi le pico se retrouve dans la configuration unité de stockage USB et nous pouvons copier un nouveau programme au format uf2 sans avoir à effectuer un débranchement du câble usb.
Exemple d’exécution :

>Debut du programme. 

>Entrez une commande :

>fct

>ResultatFonction

>Valeur du registre : 00000001

>Entrez une commande :

>fin

