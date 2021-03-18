 # Chapitre 6 : Utilisation du timer, routines chrono

Le pico possède un timer qui délivre un comptage toutes les microsecondes. Nous allons nous en servir pour mesurer le temps de l’attente d’une seconde de la procédure sleep_ms disponible dans la librairie standard.

Voir les fichiers dans ce même répertoire.

Nous commençons par lancer la routine testTimer pour activer le timer (registre tick commun avec le sous-système watchdog) et pour vérifier le contenu des registres donnant le temps (TIMELR et TIMEHR).

Puis nous avons 2 routines debutChrono et stopChrono qui vont la première stocker en .bss le temps début donné par les registres du timer et pour la seconde prendre le temps final, soustraire le temps stocké et afficher le résultat.

Ensuite nous utilisons ces routines pour mesurer le temps à vide, le temps d’une seconde donnée par  sleep_ms et le temps donnée par un compteur interne de l’oscillateur par défaut (ROSC Ring Oscillator).

A vide, la mesure donne 3 microsecondes ce qui me paraît beaucoup car un décompte manuel des cycles donne 28  * 8 nano-secondes (durée d’un cycle à 125 mhz) = 224 nanosecondes !!!
La mesure d’une seconde donne 1000003 microsecondes ce qui est conforme.

La 3ième mesure donne pour le nombre maximun (127 car maxi sur 7 bits) 33 microsecondes donc 1 top compte pour 30/127 = 236 nanosecondes.

Vérification en appelant la routine avec 42 ce qui donne un temps de 10 micro secondes environ.

Résultat :
```
Debut du programme.
Entrez une commande :
fct
Valeur du registre : 00001E0A
ExtractTimer
Valeur du registre : 00B8D57D
Valeur du registre : 00000000
Valeur du registre : 00B8D57D
Temps = 4
Temps = 1000002
testCountOsc
Temps = 33
testCountOsc
Temps = 10
Entrez une commande :
fct
Valeur du registre : 0000260A
ExtractTimer
Valeur du registre : 013E7B2C
Valeur du registre : 00000000
Valeur du registre : 013E7B2C
Temps = 3
Temps = 1000002
testCountOsc
Temps = 32
testCountOsc
Temps = 10
```
Remarque : les temps peuvent varier à chaque exécution car le Rosc n'est pas très stable d'après la documentation. J'ai essayé d'utiliser le cristal oscillateur mais je ne suis pas arrivé à le lancer correctement. 
