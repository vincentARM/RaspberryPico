### Chapitre 12 : programmation et compilation sans le SDK C++ : partie 2

Pour s’affranchir de la limite des 252 caractères possibles pour la taille de l’exécutable, nous avons plusieurs solutions. Pour faire simple, nous allons nous contenter de récupérer les 256 premiers caractères d’un fichier uf2 généré par le SDK  et les concaténer avec le .bin de notre programme pour créer un nouveau .bin complet.

Comme cela, nous n’avons pas à nous préoccuper du calcul de la somme de contrôle puisque les 256 caractères seront toujours identiques. 

Mais vous allez me dire:est ce que ça marche ? Car le bootloader va d’abord exécuter ces 252 caractères !  Que vont-ils faire exactement ? Et quelle instruction de notre programme va-t-il exécuter ensuite ?

Voici en anglais ce que font les 252 caractères chargés :
```
2.8.2.3. Flash Second Stage
The flash second stage must configure the SSI and the external flash for the best possible execute-in-place performance.
This includes interface width, SCK frequency, SPI instruction prefix and an XIP continuation code for address-data only
modes. Generally some operation can be performed on the external flash so that it does not require an instruction prefix
on each access, and will simply respond to addresses with data.
Until the SSI is correctly configured for the attached flash device, it is not possible to access flash via the XIP address
window. Additionally, the Synopsys SSI can not be reconfigured at all without first disabling it. Therefore the second stage
must be copied from flash to SRAM by the bootrom, and executed in SRAM.
Alternatively, the second stage can simply shadow an image from external flash into SRAM, and not configure execute-inplace.
This is the only job of the second stage. All other chip setup (e.g. PLLs, Voltage Regulator) can be performed by platform
initialisation code executed over the XIP interface, once the second stage has run.
```

Puis il est indiqué que l’exécution est passée à l’instruction se trouvant à l’adresse 0x1000000.

Et donc il suffit d’indiquer cette adresse au script de création du fichier uf2 pour que cela fonctionne.

Voyons l’exemple du programme blinkA12.s  qui fait clignoter la led comme dans le programme précédent et qui fait aussi varier sa luminosité.

Dans le répertoire de travail, nous trouvons le MakeFile, un fichier entete.bin qui contient les 256 premiers caractères, le fichier de directives pour le linker, le script python de création du fichier uf2 et le fichier source.

Le lancement par make va compiler et linker le programme avec les outils standards puis va concaténer l’entête et le fichier binaire crée avec la simple instruction type !!!
Le .bin résultat est mis à l’entrée du script python : c’est tout simple.

Voici un résultat de la compilation :
```
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-as --warn --fatal-warnings -mcpu=cortex-m0  blinkA12.s -o blinkA12.o
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-ld  -T memmap.ld  blinkA12.o -o blinkA12.elf  -M >blinkA12_map.txt
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-objdump -D blinkA12.elf > blinkA12.list
E:\Pico\Tools\"10 2020-q4-major"\bin\arm-none-eabi-objcopy -O binary blinkA12.elf blinkA12_dep.bin
type entete.bin blinkA12_dep.bin > blinkA12.bin
entete.bin

blinkA12_dep.bin

python uf2conv.py --family 0xE48BFF56 --base 0x10000000  blinkA12.bin -o blinkA12.uf2
Converting to uf2, output size: 1536, start address: 0x10000000
Wrote 1536 bytes to blinkA12.uf2
```

Dans le programme blinckA12.s nous trouvons en premier la table des vecteurs d’interruption qui ne contient qu’un saut vers la routine reset puis des sauts vers une boucle sans fin pour tous les autres cas. Cette table semble être obligatoire et servira à initialiser le registre VTOR situé à l’adresse PPB_BASE + PPB_VTOR. 
Pour plus d’explications complémentaires, vous pouvez rechercher sur Internet les descriptions de cette table.

Ensuite nous trouvons une routine d’initialisation qui effectue le reset général et une routine d’initialisation de l’oscillateur Cristal (XOSC) puis l’initialisation des registres d’horloge.

Cette fois çi la fréquence d’ horloge sera donc de 12 MHz.

Le reste du programme est identique aux programmes précédents pour les routines ledEclat et variaLed.

Le fichier bin résultat fait 600 octets.

Le programme fonctionne correctement et il faut aussi vérifier qu’il fonctionne lorsque l’on débranche et rebranche le pico. 

Pourquoi ?   Parce que lors du passage en mode chargement par le port USB, le bootloader effectue les initialisations des horloges (et de sous systèmes?) qui ne seront pas fait lors de la connexion directe du pico ce qui peut entraîner des comportements différents.

Maintenant, nous pouvons écrire des programmes plus gros mais hélas sans aucune possibilité de communication vers le PC.

Nous allons essayer dans les chapitres suivants de trouver une solution pour dialoguer avec un PC.
