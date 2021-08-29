### Chapitre 11 : programmation et compilation sans le SDK C++

En cherchant sur Internet, j’ai trouvé sur github des exemples de programmation en C et en assembleur qui n’utilisaient pas le SDK C++ pour compiler les programmes. 

Je remercie particulièrement Robert Clausecker, Matthias Koch et David Welch  pour leurs exemples de programmes et leur aide.

En effet, il ne suffit pas de compiler un programme en assembleur avec les outils standards mais il faut aussi le transformer au format uf2 et comprendre comment le logiciel en ROM du pico charge ce fichier dans la mémoire flash ou dans la ram.

 Lors du premier chargement du fichier uf2 depuis le PC en appuyant sur le bouton de boot, le chargeur charge le fichier dans la mémoire flash à l’adresse indiquée dans le fichier uf2 (le plus souvent  0x1000000)
 
Puis l’étape 2 du chargement (voir la documentation de la datasheet  chapitre 2.7 Boot Sequence) consiste à copier les 256 premiers octets de la mémoire flash dans la sram à l’adresse 0x20041F00 cad à la fin de la Sram et à vérifier la somme de contrôle située dans les 4 derniers octets de ces 256 premiers octets. Si elle n’est pas exacte, le programme de chargement s’arrête !! 

Si la somme est exacte, l’exécution est lancée à l’adresse 0x20041F00.

Donc une première solution consiste à avoir un exécutable de moins de 252 octets, un script qui calcule la somme de contrôle et la stocke dans les octets 252,253,254 et 255 et un script qui génère le fichier uf2.

David Welch dans son répertoire https://github.com/dwelch67/raspberrypi-pico  propose une solution qui génère la somme de contrôle et le fichier uf2 à partir d’un programme C++.
Robert Clausecker propose un autre script python qui calcule la somme de contrôle mais qui utilise le script standard python de conversion d’un fichier du format bin au format uf2. C’est cette solution que je vais exploiter ici.

Dans un répertoire de travail il faut créer un fichier Makefile tel celui figurant dans mon répertoire.

Il faut adapter le chemin d’accès aux outils de compilation et de link aux répertoires de votre PC.

Il faut aussi vérifier la présence de l’exécutable make sur votre pc et mettre à jour la variable d’environnement PATH pour que windows trouve le chemin pour l’exécuter.

Il faut recopier les 2 scripts python :   pad_checksum_binary.py et uf2conv.py dans le répertoire de travail ainsi que le fichier memmap.ld qui donne les directives pour le linker.

Il faut recopier le programme source  blinkA11.s dans le répertoire de travail et lancer la création par un simple make.

Remarque : il doit être possible d’utiliser nmake en modifiant quelques lignes du Makefile pour l’adapter à la syntaxe Microsoft.

L’exécution du make va entraîner la compilation du programme avec l’utilitaire as pour produire un fichier .o puis le link avec ld pour produire un fichier .elf puis un fichier .bin avec objcopy puis le lancement du script python pad_checksum_binary.py qui va calculer la somme de contrôle et la placer au bon endroit.

Puis le script python uf2conv va convertir le fichier .bin final en fichier au format uf2.

Une liste de compilation sera aussi créée dans un fichier .list.

Bravo si tout cela fonctionne du premier coup !!

Remarque : la taille du ficher _deb.bin donne la taille exacte de l’exécutable ce qui peut être necessaire pour savoir de combien il faut optimiser le programme pour qu’il rentre dans les 252  octets.
Exemple compilation
```
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-as --warn --fatal-warnings -mcpu=cortex-m0  blinkA11.s -o blinkA11.o
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-ld  -T memmap.ld  blinkA11.o -o blinkA11.elf
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-objdump -D blinkA11.elf > blinkA11.list
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-objcopy -O binary blinkA11.elf blinkA11_dep.bin
python pad_checksum_binary.py -p256 -s-1 blinkA11_dep.bin blinkA11.bin
python uf2conv.py --family 0xE48BFF56 --base 0x10000000  blinkA11.bin -o blinkA11.uf2
Converting to uf2, output size: 512, start address: 0x10000000
Wrote 512 bytes to blinkA11.uf2
```

Voyons le programme blinkA11 qui se contente de faire clignoter la led et qui à une taille de 100 octets.

Il commence par charger les constantes utilisées en seulement 2 instructions

Puis il effectue un reset général sauf les 4 systèmes essentiels et force la référence de l’horloge au Ring Oscillator(ROSC). 

Ensuite nous retrouvons l’initialisation de la LED du  GPIO  et la routine ledEclats comme dans le programme précédent.
Le programme boucle indéfiniment sur cette routine.

Vous remarquerez que les valeurs d’attente sont très différentes du programme précédent. En effet ici, il n’y aucun lancement d’horloge et donc le processeur tourne à la fréquence de l’oscillateur interne rosc à la fréquence de 6,5Mhz.


Pour ceux qui veulent une liaison série avec un raspberry pi pour afficher des messages vous trouverez un exemple ici : https://picocomp.belug.de/mandelboot.tar.gz

Bon avec 252 caractères, il n’est pas possible de faire grand-chose et donc dans le chapitre suivant, nous verrons comment avoir des programmes plus importants.
