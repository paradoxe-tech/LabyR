### Notes de travail
## Ce que j'ai ajouté
Il fallait stocker les paramètres d'impression pour une imprimante donnée afin que notre programme soit compatible avec plusieurs imprimantes. Du coup j'ai stocké ces données dans un fichier "printers.json" ou seront répértoriés par imprimante le diamètre de la tête, l'en tête GCODE et la fin de programme GCODE avec la syntaxe suivante :
```JSON
{
  "printer_name" :
    { 
      "nozzle_diam" : "(nozzle diam)",
      "start_code" : "...",
      "end_code" : "..."
    }
}
```

Du coup j'ai modifié le constructeur de Loggerhead pour qu'il devienne :
```R
initialize = function(printer, fil_radius, flow_rate = 1, delta = 0.5)
```

Etant donné que fil_radius (rayon du filament), flow_rate (j'explique ce que c'est plus bas) et delta (l'épaisseur d'une couche en mm) peuvent fluctuer pour chaque impression.

## G-Code : En tête commandes et fin de fichier
Pour être sur de produire un fichier G-Code correct dans tous les cas, il faut qu'on analyse les commandes d'un fichier Gcode normal et qu'on différencie les commandes selon leur pertinence :
- Il y a les lignes d'en tête et de fin de fichier qu'on retrouvera quelle que soit l'imprimante et quel que soit le modèle (M2 à la fin par exemple)
- Les lignes Gcode spécifiques à une certaine imprimante

J'ai aussi appris que le filament est considéré comme un axe lui aussi (l'axe E). Pour calculer la qté de filament à utiliser, 
- Première étape : savoir la longueur de la ligne qu'on trace
- Le vol du fil à extruder = hauteur de la couche (delta) x diamètre tête d'impression x longueur ligne x "flow rate" (multiplicateur customisable)
- Ensuite la longueur du fil = le vol de fil / (divisé par) le diamètre du filament (dépend du filament utilisé! donc doit pouvoir être changé par l'utilisateur)
Ce qui fait que l'utilisateur doit pouvoir régler pour son impression :
- La hauteur de couche
- Le diam de la tête
- Le diam du filament qu'il utilise
- Le "flow rate" qu'il peut ajuste à sa guise à chaque impression (en gros le fait que le flow rate soit ajustable permet à l'utilisateur de mettre moins ou plus de filament selon comment son imprimante se comporte)

Deux types de mouvement :
- G1 X... Y... Z... E... F... quand on extrude. E : longueur de filament à extruder, F : vitesse (je dois me renseigner sur ça)
- G0 X... Y.. Z... quand on n'extrude pas (dans notre cas quand FILL=0)

Pour l'instant de ce que j'ai compris, pour préparer une bonne impression les commandes suivantes sont nécessaires (G code de départ dans ultimaker Cura) :
- G21 pour être sur d'être en mode métrique
- G90 pour être sur d'être en mode "coordonées absolues"
- M82 pour mettre l'axe E en mode "coords absolues" (déjà fait par G90 apparemment ? donc peut être inutile)
- M107 pour commencer avec ventilo éteint
- G28  permet d'amener la tête à sa position initiale (X0 Y0 Z0)
maintenant pour bien préparer nettoyer la tête d'impression (les slicers font ça apparemment) :
- G1 Z5.0 F9000 : on se déplace 15mm au dessus du lit
- M109 S(temp) permet de faire chauffer la tête à (temp) degrés. Je pense que la température dépénd de chaque impirmante
- M106 S(speed) permet de régler le ventilateur externe à une vitesse entre 0 et 255. se renseigner sur la vitesse à utiliser
- M190 S(temp) même chose avec le lit d'impression (la surface quoi.) encore une fois je pense que la température optimale d'impression dépend des impirmantes. + ttes les imprimantes ont pas de lit chauffant
- G92 E0 : remise à zéro de l'axe E
- G1 F200 E3 : on extrait 3 mm de fil (pour qu'il y en ait dans la buse je crois)
- G92 E0 : remise à zéro de l'axe E
- G1 F9000 : pas sur de l'utilité de cette ligne mais je crois que ça signale le début d'impressipn


**Apparemment Cura stocke dans un fichier json le gcode de départ qu'il utilise pour chaque imprimante donc on peut être le choper comme ça aussi pour comparer**

Du coup à la fin du fichier il faut ensuite 
- M104 S0 pour refroidir complètement la tete d'impression
- M140 S0 pour faire de même avec le lit d'impression (est ce que la notre a un lit chauffant ? jsp encore une fois)
Ensuite préparer l'imprimante pour pouvoir retirer la pièce facilement. Pour ça :
- G90 pour passer en coord. relatives (permet de pas avoir à connaitre ou on était avant pour la suite)
- G1 E-1 F300 pour rétracer un peu le filament (axe E)
- G1 Z+0.5 E-5 X-20 Y-20 F9000 pour dégager la tête de la pièce et rétracer encore + le filament
- G28 X0 Y0 pour que la tête revienne à la maison mais QUE sur les axes x et y (pas Z pour ça qu'y a pas de Z0) sinon possible collision avec la pièce
PAS SUR : - G1 Y150 F5000 pour bouger la pièce (à tester ça, pas sur de ce que ça donne)
- M84 pour éteindre les moteur
- M107 pour étéindre ventilo
- G90 pour revenir en coord. absolues pour la prochaine impression
- M2 (code de fin de programme apparemment)
