library(TurtleGraphics)

cheminRelatif <- "C:/Users/mathe/OneDrive/ECOLE/Valrose/L2/progR/LabyR/src/"

source(paste0(cheminRelatif, 'classes/Loggerhead.r'))
source(paste0(cheminRelatif, 'classes/Path.r'))
source(paste0(cheminRelatif, 'classes/Polygon.r'))


turtle <- Loggerhead$new("Ultimaker_S3") # 0.5 = rayon filament 

# Définir un carré de côté 5O
path <- Path$new()

for (i in 1:4) {
  path$forward(50)
  path$turn(90) 
}

for (i in 1:4) {
  path$forward(80)
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

