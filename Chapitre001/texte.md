# Préalables :
Il faut avoir installer le sdk C++  soit sur un raspberry ( ici un modèle 3B+) soit sur Windows 10 en suivant scrupuleusement les indications du document raspberry-pi-pico-c-sdk.pdf :

>To build you will need to install some extra tools. 

>• ARM GCC compiler

>• CMake

>• Build Tools for Visual Studio 2019

>• Python 3

>• Git

Il faut faire bien attention à la mise à jour des chemins (PATH) 
puis il faut tester toute la chaîne de compilation avec l’exemple blink 
puis copier le fichier exécutable .UF2 sur le raspberry pico et vérifier le clignotement de la LED.

Tant que cette étape n’est pas atteinte, il est inutile d’aller plus loin.
Remarque : sous windows il faut lancer la première étape avec **cmake -G "NMake Makefiles" ..** depuis le répertoire build alors que sur Linux il suffit de lancer **cmake ..**

Et pour la deuxième étape il faut taper **nmake** sous windows et **make** sous Linux.

Il sera peut être nécessaire d’ajouter dans le fichier CMakeList.txt les directives suivantes :

cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(nomduprojet)

Car curieusement ces directives ne sont pas renseignées dans les exemples mais sont réclamées lors de la compilation.

Il faut aussi tester l’utilisation du terminal (minicom sous linux) (putty sous windows) avec l'exemple hello-word. 

Sous windows, il faut brancher le pico sur le port usb avant de lancer putty avec le paramétrage série (115200).

Tout est ok ?  Il faut aussi récupérer la documentation complète du sdk :
https://raspberrypi.github.io/pico-sdk-doxygen/index.html 

de la datasheet :
https://datasheets.raspberrypi.org/rp2040/rp2040-datasheet.pdf

et éventuelle la documentation du processeur :
https://developer.arm.com/documentation/ddi0484/latest

et de l’architecture arm6.
https://developer.arm.com/documentation/ddi0419/latest/

Les instructions assembleur utilisées par le processeur font partie de cette architecture. Ce sont des instructions de type thumb de longueur 16 bits sauf les instructions d’appel de sous routines qui sont en 32 bits. Les instructions cbz, cbnz et it ne sont pas acceptées par le processeur.

Le source peut être saisi avec n’importe quel éditeur et doit être sauvé avec l’extension .s. Il faut préciser dans le source  ces  3 directives :

.syntax unified  (Correction : n'est pas obligatoire )

.thumb

.cpu cortex-m0plus

La directive .syntax oblige de mettre le suffixe s après les mnémoniques des instructions arithmètiques mais n'oblige pas le # avant lrs valeurs immédiates.

Comme vous l’avez constaté, les sources C sont incorporés dans le fichier Cmakelists.txt avec la directive :
 add-executable (nom pgm.c) 
 
et donc pour l’assembleur il suffit de mettre :
add-executable (nom pgm.c  pgm1.s)   si des routines assembleur sont appelées par le programme C

ou tout simplement :
add-executable (nom  pgm1.s)   s’il s’agit d’un programme assembleur seul.

Il suffit ensuite de lancer le cmake (une fois si la configuration ne change pas) puis le nmake (autant de fois qu’il le faut!!).

Pour commencer, nous écrivons une routine en assembleur programme : [testPico1.s](https://github.com/vincentARM/RaspberryPico/blob/main/Chapitre001/P1/testPico1.s) qui ajoute 5 au registre r0 puis qui le multiplie par 4. Puis cette routine est appelée dans le programme C copie du programme exemple hello_usb.c  dont nous modifions l'instruction print pour afficher le contenu retourné par la routine (voir les fichiers dans le répertoire P1).

Après quelques corrections et mises au point, le message s'affiche bien dans putty (sous windows) ou dans minicom. Je remarque que la manip n'est pas simple pour enfoncer la prise usb dans le raspberry (qui est léger) tout en appuyant sur le bouton de boot.

Pour continuer notre découverte, nous allons repartir du programme C de clignotement de la led blink.c et nous allons nous contenter d’appeler les 4 procédures du C : gpio_init, gpio_set_dir, gpio_put et sleep_ms en passant soit comme paramétre dans le registre r0 le pin de la Led  25 soit la durée d’attente pour la routine sleep_ms.

(voir les fichiers dans le répertoire P1A).

Lors de la première compilation, nous remarquons que nous devons mettre le suffixe s pour toutes les instructions arithmétiques (mov, add sub etc.) que le push ne concerne que les 7 registres les plus bas + lr et que le pop ne concerne aussi que 7 registres et le pc. 

La chaîne de compilation résout bien l’appel des procédures gpio_init et sleep_ms mais pas les routines  gpio_set_dir et  gpio_put. 

Après recherche, je trouve sur le site raspberry.org l’explication : certaines routines en C sont bien intégrées dans les librairies (comme stdlib) mais d’autres sont stockées dans des fichiers d’entête .h et compilées à la volée. Comme dans le source assembleur, nous n’avons pas indiqué  d’include de fichiers .h, nous avons des erreurs.

Pour résoudre cela, un post du site en question propose d’écrire un programme C qui fait le lien entre notre programme assembleur et les routines des entêtes .h.

Je teste cette solution qui fonctionne dans le programme testPico2.s et qui pourra servir pour d’autres cas. (voir les fichiers dans le répertoire P1B)

Mais le mieux pour les fanas d’assembleur est de réécrire ces routines directement en assembleur y compris les routines disponibles dans les librairies comme init_gpio.

C’est ce que fait le programme :  testPico2C.s     réécrit à partir de la documentation de la datasheet mais aussi à partir du fichier .dis précédent. 
(voir les fichiers dans le répertoire P1C).
En effet la chaîne de compilation fournit l’image assembleur du fichier uf2 crée ainsi que le plan de chargement. Ce sont 2 mines de documentation qui nous permettent de comprendre l’organisation des programmes du Pico.
Mais attention, la chaîne de compilation optimise grandement les routines C et la lecture du résultat n’est pas évidente !!

Cette première démarche nous montre aussi que nous allons avoir souvent à décider si nous allons utiliser une routine déjà présente dans les librairies ou si nous allons la réécrire en assembleur.
Nous constatons aussi que toutes les routines respectent la norme d'appel pour les paramètres : à savoir pas de sauvegarde des registres r0 à r3 donc il faudra faire attention lors de l'utilisation de ces registres.

Quelques précisions sur ce programme :
J’ai commencé à récupérer les constantes nécessaires dans les sources C fournis dans le SDK. Elles seront à compléter au fur et à mesure de leur utilité.

J’ai crée une structure pour l’adresse des registres concernant les entrées sorties (SIO) lors de cette première écriture mais ce n’est pas une bonne idée !!

Le nom de chaque routine doit être précédé de la directive : .thumb_func. Si vous mettez l’adresse de données à la fin du routine, il faut ajouter avant la directive .align 2. En effet les instructions thumb faisant 16 bits, l’adresse (.int) peut ne pas être alignée sur 4 octets.

L’écriture des registres mémoire peut se faire de 4 manières différentes : 

* normale  à l’adresse du registre

* avec un xor de la valeur déjà présente si écriture à l’adresse + 0x1000

* avec un masque à l’adresse + 0x2000 (atomic bitmask set on write)

* avec un masque à l’adresse +0x3000 (atomic bitmask clear on write)

Voir la datasheet rp2040.

Enfin comme les instructions n’ont que 2 octets, les valeurs immédiates ne peuvent aller que jusqu’à 255 !! Non pas toujours : l’addition ou la soustraction d’une valeur immédiate à un registre depuis un autre ne peut être qu’inférieure à 8 !!!!
