#' Immune markers in human and mouse.
#'
#' A dataset containing a list of immune markers in human and mouse, used by
#' dcq method to infer the cell composition from RNA expression levels.
#'
#' @format A data frame with 61 rows and 2 variables:
#' \describe{
#'   \item{human}{immune-related markers, human name.}
#'   \item{mouse}{immune-related markers, mouse name.}
#'   ...
#' }
#' @source \url{http://www.diamondse.info/}
"markers"


#' Database of immune cell expression levels.
#'
#' A dataset containing the expression level selected immune markers in 217 cell
#' types from the Immunology Genome Project (Immgen).
#'
#' @format A data frame with 61 rows and 217 variables:
#' @source \url{http://www.immgen.org}
"db"
