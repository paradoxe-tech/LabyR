library(TurtleGraphics)

source('classes/Loggerhead.r')
source('classes/Path.r')
source('classes/Polygon.r')


turtle <- Loggerhead$new("Ultimaker_S3") # 0.5 = rayon filament 

# Définir un carré de côté 5O
path <- Path$new()

for (i in 1:4) {
  path$forward(50)
  path$turn(90) 
}

square <- Polygon$new(path, fill_step = 1)

# Ajouter un calque contenant le carré
turtle$addLayer()

turtle$buildShapes(list(
  square
))

# Afficher le dernier calque
turtle$display()
turtle$genFile()