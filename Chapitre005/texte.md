# Chapitre 5 : capteur de température interne

Le pico possède un capteur de température interne dont on peut lire la température sans aucun autre branchement.

La difficulté est qu’il faut effectuer des calculs en virgule flottante à partir de la lecture brute et que le processeur n’a pas d’instructions de ce type.
Pour cela il faut faire appel à des routines se trouvant en mémoire morte. Voir les fichiers du répertoire P1.

Pour simplifier les programmes, les constantes générales sont déportées dans le fichier constantesPico.inc et les routines générales dans le fichier routinesPico.s. Il faut penser à ajouter ce dernier fichier dans le fichier CmakeList.txt dans la directive add_executable.

Tout d’abord, il faut initialiser le  Analogue Digital Converter (ADC) (voir chapitre 4.9 de la datasheet) en effectuant un reset des registres. Il y a 4 entrées possibles et la cinquième est réservée à la mesure de la température.

La commande temp appelle la routine testTemp qui commence par lancer une première mesure, attendre le résultat puis lancer une autre mesure. Malgré cela, la première mesure est toujours incorrecte !! et je n’ai pas encore trouvé pourquoi.

Nous récupérons le résultat dans le registre r4 puis nous appelons la routine appelDatasRom qui va aller chercher l’adresse de la table qui nous permettra d’appeler les fonctions de calcul en virgule flottante. (voir le paragraphe 2.8.3.2 Fast Floating Point Library de la datasheet)

Nous commençons par convertir le résultat de la mesure en float en appelant la fonction se trouvant au déplacement 0x34 puis nous appelons les différentes fonctions pour effectuer les opérations de calcul.

Nous multiplions le résultat par 10 pour avoir un résultat en dizième de degrées et pour ne pas avoir à appeler la fonction printf du C pour afficher la valeur Float. Nous nous contentons d’afficher la valeur entière après une conversion en utilisant la fonction se trouvant au déplacement 0x24.

La conversion en décimal est reprise des fonctions que j’avais écrites pour le raspberry pi en 32 bits.
Elle utilise une division particulière par 10 (car le processeur cortal M0 n’a pas d’instruction de division entière) issue des idées de Delight. (en 2021, le site à l’air d’avoir disparu).
 
Voici un exemple des résultats :
```
Debut du programme.
Entrez une commande :
temp
debutADC
resultat
Valeur du registre : 00000059
résultatFinal
Valeur du registre : 00000F73
Température (en dizième de degrés) = 3955
Entrez une commande :
temp
debutADC
resultat
Valeur du registre : 00000372
résultatFinal
Valeur du registre : 000000F3
Température (en dizième de degrés) = 243
Entrez une commande :
temp
debutADC
resultat
Valeur du registre : 00000372
résultatFinal
Valeur du registre : 000000F3
Température (en dizième de degrés) = 243
Entrez une commande :
temp
```
