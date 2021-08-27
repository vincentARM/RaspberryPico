### Chapitre 10 : programmation assembleur sans la stdlib

Après plusieurs mois passés sur un autre projet, me voici revenu sur le pico. Dans ce chapitre nous allons voir comment nous passer de la librairie stdlib qui prend quand même pas mal de place.

Evidement, sans elle, nous allons predre beaucoup de fonction et en particulier la communication avec le PC par le cable USB et donc cette solution ne peut être réservée que pour faire fonctionner la LED ou les autres pins du GPIO.

Mais il nous faudra quand même utiliser une libraire minimum(pico_standard_link ) pour avoir une compilation correcte avec le SDK. Dans le fichier CmakeFile.txt nous aurons donc la ligne :
```
target_link_libraries(testPico21  pico_standard_link)
```
La taille du fichier uf2 est ainsi réduite à 6KO.

Dans le programme testpgm21.s nous allons nous contenter de faire clignoter la led et de montrer un exemple de variation de sa luminosité. 

Le programme commence par effectuer un reset général à l’exception de 4 sous système. Il faut attendre que le reset soit OK avant de continuer. 

Puis nous devons lancer un oscillateur et paramétrer une horloge minimum pour que l’allumage et l’extinction de la Led puisse s’effectuer.

Ensuite nous initialisation la sortie pin25 correspondant à la LED. Vous remarquerez que ces initialisations sont fortement allégées par rapport à mes premiers programmes : merci à  pour leurs exemples de programmation.

Ensuite le programme appelle les routines de clignotement de la LED fortement allégées et celle de la variation de la luminosité ?

Pour cette dernière, et pour avoir une transition douce, nous utilisons algorithme du cercle de Minsky qui calcule de manière simplifier le cosinus et le sinus.
Le sinus nous permet de calculer les durées d’extinction et d’allumage de la led.

Je pense qu’il est possible d’améliorer cette partie pour avoir des transitions plus longues et plus complètes (en effet l’extinction de la led n’est pas totale en fin de cycle!!).

Remarque : le routine ledEclats pourra être utiliser pour déboguer un programme sans affichage en lui faisant appel avec des nombres d’éclair différents.
