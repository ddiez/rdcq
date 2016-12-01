#' dcqUI
#'
#' Runs the shiny UI for dcq method.
#'
#' @return NULL
#' @export
#'
dcqUI <- function() {
  runApp(system.file("shiny", "rdcq", "app.R", package = "rdcq"))
}
