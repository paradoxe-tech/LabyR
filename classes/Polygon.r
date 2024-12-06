#Classe définissant des polygones d'après un tracé (ou des sommets) et permettant de les remplir
Polygon <- R6Class(
  "Polygon",
  class = TRUE,
  
  public = list(
    vertices = NULL,
    fill_step = 1,
    
    # Transforme les tracés en liste des sommets du polygone
    initialize = function(path, fill_step = 1) {
      if (!inherits(path, "Path")) {
        stop("Object passed as first parameter isn't of type 'Path'")
      }
      
      movements <- path$movements
      if (length(movements) < 3) {
        stop("No polygon can be built with less than 3 vertices")
      }
      
      first_point <- movements[[1]][1:2]
      last_point <- movements[[length(movements)]][1:2]
      
      if (!all(first_point == last_point)) {
        stop("No polygon can be built from an open path")
      }
      
      self$vertices <- lapply(movements, function(m)
        m[1:2])
      
      self$fill_step <- fill_step
    },
    
    # Méthode publique pour renvoyer un tracé optimisé
    toPrintPath = function() {
      vertices <- self$vertices
      path <- Path$new(vertices[[1]][1], vertices[[1]][2])
      
      # Trace le contour
      for (i in 2:length(vertices)) {
        point <- vertices[[i]]
        path$move(point[1], point[2])
      }
      path$move(vertices[[1]][1], vertices[[1]][2])
      
      # Trace une ligne verticale vers un segment 
      v_line = function(posx, posy, x1, y1, x2, y2) {
        tan_a <- (y2 - y1) / (x2 - x1)
        path <- path$move(path$x, tan_a * (posx -x1) + y1)
      }
      
      # Se dirige d'une valeur donnée (modifiable, permettant de modifier le pourcentage de remplissage) vers un point
      follow = function(add, x1, y1, x2, y2) {
        if (add > 0) {
          if (x1 + add > x2) {
            path$move(x2, y2, 0.0)
            return(x1 + add - x2)
          }
        } # Si on dépasse le segment
        else if (add < 0) {
          if (x1 + add < x2) {
            path$move(x2, y2, 0.0)
            return(x1 + add - x2)
          }
        } # idem
        
        tan_a <- (y2 - y1) / (x2 - x1)
        path$move(add + x1, tan_a * add + y1, 0.0)
        return(0)
      }
      
      # Pour classer les segments en partant du plus à droite, le plus haut
      sum_p = function(c) {
        # A vérifier rigoureusement
        return(c[1] * 1000 + c[2] + c[3] * 0.001 + c[4] *
                 0.000001)
      }
      
      # Création d'une liste contenant les segments
      segments <- list()
      for (i in 1:length(vertices)) {
        i2 <- i + 1
        if (i2 > length(vertices)) {
          i2 <- 1
        }
        
        if (vertices[[i2]][1] < vertices[[i]][1]) {
          segments <- append(segments, list(c(
            vertices[[i2]][1], vertices[[i2]][2], vertices[[i]][1], vertices[[i]][2]
          )))
        } else {
          segments <- append(segments, list(c(
            vertices[[i]][1], vertices[[i]][2], vertices[[i2]][1], vertices[[i2]][2]
          )))
        }
      }
      
      # Ordonnance des segments
      segments <- segments[order(sapply(segments, sum_p))]
      
      # Création des couples de segments à relier
      couples <- list()
      while (length(segments) != 0) {
        seg <- segments[[1]]
        segments <- segments[-1]
        cat("\n", seg, " ->")
        if (length(segments) == 0) {
          cat("Erreur, segment sans couple")
        }
        
        new_segments <- list()
        for (i in segments) {
          cat("\n (", i, ") : ")
            
          #Vérifie si les deux segments sont compatibles
          if (!((seg[1] >= i[3]) ||
                (i[1] >= seg[3]))) {
            
            # Les 2 segments sont compatibles
            debut <- seg[1]
            fin <- seg[3]
            
            if (debut > i[1]) {
              # Le debut du 1er segment est après celui du 2ème -> raccourcit le 2ème
              new_i <- i
              tan_a <- (i[4] - i[2]) / (i[3] - i[1])
              new_i[3] <- debut
              new_i[4] <- i[2] + (debut - i[1]) * tan_a
              new_segments <- append(new_segments, list(new_i))
              cat(new_i, " | ")
              i[1] <- new_i[3]
              i[2] <- new_i[4]
            } else if (debut < i[1]) {
              # Le debut du 1er segment est avant celui du 2ème -> impossible
              cat("Cas immpossible")
            }
            if (fin > i[3]) {
              # La fin du 1er segment est après celle du 2ème -> raccourcit le 1er
              fin <- i[3]
            } else if (fin < i[3]) {
              # La fin du 1er est avant celle du 2ème -> raccourcit le 2ème
              new_i <- i
              tan_a <- (i[4] - i[2]) / (i[3] - i[1])
              new_i[1] <- fin
              new_i[2] <- i[2] + (fin - i[1]) * tan_a
              new_segments <- append(new_segments, list(new_i))
              cat(new_i)
              i[3] <- new_i[1]
              i[4] <- new_i[2]
            }
            
            
            # Ajout dans les couples des deux segments uniformisés
            couples <- append(couples, list(c(seg, i)))
            if (fin == seg[3]) {
              # On est arrivé à la fin du segment
              seg <- c(0, 0, 0, 0)
            } else {
              # On continue le parcours avec la suite du segment
              tan_a <- (i[4] - i[2]) / (i[3] - i[1])
              seg[2] <- tan_a * (fin - seg[1]) + seg[2]
              seg[1] <- fin
            }
          } else {
            new_segments <- append(new_segments, list(i))
          }
        }
        segments <- new_segments
      }
      
      # Création du remplissage (le tracé)
      step_value <- self$fill_step # La valeur dépend du diamètre de la buse
      for (c in couples) {
        path$move(c[1], c[2], 0.0)
        up <- TRUE
        while (TRUE) {
          if (up) { # Suis le segment du haut, puis trace vers le segment du bas
            if (follow(step_value, path$x, path$y, c[3], c[4]) != 0) {
              break
            }
            v_line(path$x, path$y, c[5], c[6], c[7], c[8])
          } else { # Suis le segment du bas, puis trace vers le segment du haut
            if (follow(step_value, path$x, path$y, c[7], c[8]) != 0) {
              break
            }
            v_line(path$x, path$y, c[1], c[2], c[3], c[4])
          }
          up <- !up
        }
      }
      
      # Retourne le tracé final
      return(path)
    },
    
    # Surcharge de la fonction d'affichage
    print = function() {
      origin <- self$vertices[[1]]
      
      cat(
        "<Polygon>",
        "\n\tVertices: ",
        length(self$vertices) - 1,
        " (+ 1)",
        "\n\tOrigin: (",
        origin[1],
        ', ',
        origin[2],
        ")",
        "\n",
        sep = ""
      )
    }
  )
)