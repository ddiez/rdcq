#' dcqUI
#'
#' Runs the shiny UI for dcq method.
#'
#' @return NULL
#' @export
#'
dcqUI <- function() {
  runApp(system.file("shiny", "DCQ", "app.R", package = "DCQ"))
}
