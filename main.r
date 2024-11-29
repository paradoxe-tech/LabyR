library(TurtleGraphics)

source('classes/Loggerhead.r')
source('classes/Path.r')
source('classes/Polygon.r')

# Exemple d'utilisation
turtle <- Loggerhead$new("u83", 0.5) # 0.5 = rayon filament 

# Définir un carré de côté 1
path <- Path$new()

for (i in 1:4) {
  path$forward(50)
  path$turn(90)
}

square <- Polygon$new(c(0,0), path)

path2 <- Path$new()
for (i in 1:4) {
  path2$forward(50)
  path2$turn(90)
}

square2 <- Polygon$new(c(20,0), path2)

# Ajouter un calque contenant le carré
turtle$addLayer()

turtle$buildShapes(list(
  square,
  square2
))

# Afficher le dernier calque
turtle$display()
turtle$genFile()