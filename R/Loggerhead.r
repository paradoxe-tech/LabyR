library(R6)
library(TurtleGraphics)

Loggerhead <- R6Class("Loggerhead", # nolint: object_name_linter.
  class = TRUE,

  public = list(
    layers = NULL,
    activeLayer = NULL,
    printerConfig = NULL,
    userConfig = NULL,

    #' Instancie un objet `Loggerhead`.
    #' @param printerConfig la configuration de l'imprimante.
    #' @param userConfig la configuration de l'utilisateur.
    #' @return Un objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' @export
    initialize = function(printerConfig, userConfig) {
      self$layers <- list()
      self$printerConfig <- printerConfig
      self$userConfig <- userConfig
      turtle_init()
      turtle_hide()
    },

    #' Ajoute un calque à l'objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$addLayer()
    #' @export
    addLayer = function() {
      layer <- Path$new()
      self$layers <- append(self$layers, list(layer))
      self$selectLayer(length(self$layers))
    },

    #' Sélectionne un calque de l'objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$selectLayer(2)
    #' @export
    selectLayer = function(layerIndex) {
      if (layerIndex < 1 || layerIndex > length(self$layers)) {
        stop("Layer index out of bounds")
      } else {
        self$activeLayer <- layerIndex
      }
    },

    #' Ajoute des formes au calque actif de l'objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$buildShapes(c(square, rectangle))
    #' @export
    buildShapes = function(polygons) {
      if(is.null(self$activeLayer)) stop("No active layer selected")

      layer <- self$layers[[self$activeLayer]]

      for (polygon in polygons) {
        if (!inherits(polygon, "Polygon")) {
          stop("All shapes must be of class 'Polygon'")
        } else {
          polygonPath <- polygon$toPrintPath(self$activeLayer)
          layer <- Path$new()$fusion(layer, polygonPath)
        }
      }

      self$layers[[self$activeLayer]] <- layer
    },

    #' Dessine un chemin libre sur le calque actif de l'objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$freeDraw(c(square, rectangle))
    #' @export
    freeDraw = function(moves) {
      if(!self$activeLayer) stop("No layer registered")
      # free draw
      self$layers[[self$activeLayer]] <- moves
    },

    #' Affiche le calque actif de l'objet `Loggerhead`.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$display()
    #' @export
    display = function() {
      self$layers[[self$activeLayer]]$display()
    },

    #' Exporte l'objet `Loggerhead` au format GCODE.
    #' @examples
    #' turtle <- Loggerhead$new(printerConfig, userConfig)
    #' turtle$export("out.gcode")
    #' @export
    export = function(path) {
      return()
    }
  )
)