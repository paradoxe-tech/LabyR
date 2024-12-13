# Turtle-like PrintR
Un package pour générer des fichiers d'impression 3D (au format `gcode`) à partir d'instructions "Turtle", qui permettent de dessiner en programmant, simplement et de manière (presque) purement impérative.

## Installation et Usage

```r
install.packages("devtools")
devtools::install_github("Mathuww/PrintR")
library(PrintR)
```

## Dessin 2-dimensionnel

L'idée du projet est de commencer par implémenter une version de Turtle qui interprète directement chaque action de l'utilisateur dans un format isomorphe au `gcode`. De plus, il nous fallait une définition forte de la notion de "forme" ; pour être capable d'appliquer des algorithmes d'impression 3D cohérents et optimisés sans influencer l'expérience du dessinateur.

### Tracés et formes

Pour cette raison, les tracés Turtle (objets `Path`) sont transformés en formes (objets `Polygon`) avant d'être traitées. L'utilisateur peut alors définir ses propres formes, réutilisables à n'importe quel moment du tracé.

```r
# POO : Réutilisation des formes
square = function(size) {
  # Définition d'un tracé
  path <- Path$new()

  # Syntaxe tortue : Dessin d'un carré
  path$forward(size)
  path$turn(90)
  path$forward(size)
  path$turn(90)
  path$forward(size)
  path$turn(90)
  path$forward(size)
  path$turn(90)

  return( Polygon$new(path) )
}
```

### Construction et affichage

Les formes peuvent ainsi être données à l'instance de `Loggerhead`, via la méthode `buildShapes`. Elles devront être ordonnées par ordre d'impression, en précisant le sommet prioritaire de chaque polygone.

```r
# Dessin du carré sur le calque
turtle$buildShapes(list(
  square(50) # carré de côté 50
))
```

L'utilisateur peut aussi choisir de se déplacer librement (dans ce cas la buse suivra ses déplacements à la lettre sur le plan) en créant simplement un nouveau tracé et en appliquant la méthode `freeDraw`.

```r
# Nouveau tracé pour le déplacement
freeWill = Path$new()
freeWill$forward(size)

# Tracé interprété comme déplacement
turtle$freeDraw(
  freeWill
)
```
