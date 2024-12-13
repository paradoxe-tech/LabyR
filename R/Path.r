library(R6)

Path <- R6Class("Path",
  class = TRUE,

  public = list(
    x = 0,
    y = 0,
    facing = c(1, 0), # Direction initiale (vecteur x, y)
    movements = list(), # Liste pour stocker les mouvements

    #' Instancie un objet `Path`.
    #' @param x la coordonnée x de départ.
    #' @param y la coordonnée y de départ.
    #' @param facing la direction initiale.
    #' @return Un objet `Path`.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' @export
    initialize = function(x=0, y = 0, facing = c(1, 0)) {
      self$facing <- facing
      self$x <- x
      self$y <- y
      self$movements <- list(c(x, y, 0.0)) # Pas de FILL pour le début du Path
    },

    #' Crée un objet `Path` à partir de coordonnées.
    #' @param coords les coordonnées du chemin.
    #' @return Un objet `Path`.
    #' @examples
    #' path <- Path$fromCoords(list(c(0, 0), c(1, 1), c(2, 2)))
    #' @export
    fromCoords = function(coords) {
      path <- Path$new(coords[[1]][1], coords[[1]][2])

      for (i in 2:length(coords)) {
        point <- coords[[i]]
        path$move(point[1], point[2])
      }

      path$move(coords[[1]][1], coords[[1]][2])
      return(path)
    },

    #' Avance la tortue d'une certaine distance.
    #' @param value la distance à parcourir.
    #' @param fill le remplissage du chemin.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$forward(10)
    #' @export
    forward = function(value, fill = 1.0) {
      new_x <- self$x + value * self$facing[1]
      new_y <- self$y + value * self$facing[2]

      self$move(new_x, new_y, fill)

      self$x <- new_x
      self$y <- new_y
    },

    #' Tourne la tortue d'un certain angle.
    #' @param angle l'angle de rotation (en degrés).
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$turn(90)
    #' @export
    turn = function(angle) {
      radians <- angle * pi / 180
      new_facing_x <- cos(radians) * self$facing[1] - sin(radians) * self$facing[2]
      new_facing_y <- sin(radians) * self$facing[1] + cos(radians) * self$facing[2]
      self$facing <- round(c(new_facing_x, new_facing_y), 10)
    },

    #' Définit la direction de la tortue.
    #' @param direction la direction de la tortue.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$setFacing(c(0, 1))
    #' @export
    setFacing = function(direction) {
      self$facing <- round(direction, 10)
    },

    #' Fusionne deux objets `Path`.
    #' @param path1 le premier chemin.
    #' @param path2 le deuxième chemin.
    #' @return Un objet `Path`.
    #' @examples
    #' path1 <- Path$new(0, 0, c(1, 0))
    #' path2 <- Path$new(1, 1, c(1, 0))
    #' path1$fusion(path2)
    #' @export
    fusion = function(path1, path2) {
      if (!all(inherits(path1, "Path") && inherits(path2, "Path"))) {
        stop("ERROR : All objects to be merged should be instances of 'Path'")
      }

      last_point_path1 <- path1$movements[[length(path1$movements)]][1:2]
      first_point_path2 <- path2$movements[[1]][1:2]

      # Vérifie si le dernier point de P1 rejoint le premier point de P2
      if (all(last_point_path1 == first_point_path2)) {
        new_movements <- c(path1$movements, path2$movements[-1])
      } else {
        # Point intermédiaire : origine du path 2. Mouvement sans "FILL"
        intermed_mov <- list(c(first_point_path2, 0.))
        new_movements <- c(path1$movements, intermed_mov, path2$movements[-1])
      }
      new_path <- Path$new()
      new_path$movements <- new_movements
      return(new_path)
    },

    #' Enregistre un mouvement de la tortue.
    #' @param x2 la coordonnée x de destination.
    #' @param y2 la coordonnée y de destination.
    #' @param fill le remplissage du chemin.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$move(1, 1)
    #' @export
    move = function(x2, y2, fill = 1.0) {
      if (x2 < 0) x2 <- 0 # Cropping
      if (y2 < 0) y2 <- 0
      self$movements <- append(self$movements, list(c(x2, y2, fill)))
      self$x <- x2
      self$y <- y2
    },

    #' Affiche le chemin sous forme de chaîne de caractères.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$move(1, 1)
    #' path$print()
    #' @export
    print = function() {
      movement_strings <- sapply(self$movements, function(move) {
        paste0("(", move[1], ", ", move[2], ", ", move[3], ")")
      })

      movement_path <- paste(movement_strings, collapse = " -> ")
      cat("<Path>", movement_path, "\n", sep = " ")
    },

    #' Affiche le chemin sous forme de graphique.
    #' @examples
    #' path <- Path$new(0, 0, c(1, 0))
    #' path$move(1, 1)
    #' path$display()
    #' @export
    display = function() {
      turtle_init()
      turtle_up()
      turtle_hide()

      curr_pos <- self$movements[[1]]
      turtle_goto(curr_pos[1], curr_pos[2])
      for (i in 1:(length(self$movements) - 1)) {
        next_pos <- self$movements[[i + 1]]

        # Si ce vecteur a la mention FILL
        if (next_pos[3] != 0) {
          turtle_down()
          turtle_col(col = 'black')
          turtle_goto(next_pos[1], next_pos[2])
        } else { 
          turtle_up()
          turtle_col(col = 'red')
          turtle_goto(next_pos[1], next_pos[2])
        }
        Sys.sleep(0.3)
        pos <- next_pos
      }
    }
  )
)