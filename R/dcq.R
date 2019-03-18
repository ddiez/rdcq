#' dcq
#'
#' Perform Digital Cell Quantification
#'
#' @param x matrix of expression levels.
#' @param db databases of expression levels for markers.
#' @param alpha parameter passed to glmnet.
#' @param lambda.min.ratio parameter passed to glmnet.
#' @param nlambda parameter passed to glmnet.
#'
#' @return A matrix with cell abundances.
#' @export
#'
#' @examples
#' NULL
dcq <- function(x, db = db, alpha = 0.05, lambda.min.ratio = .2, nlambda = 100) {
  x <- x[toupper(rownames(x)) %in% rownames(db), ]
  res <- lapply(1:ncol(x), function(k) {
    fit2 <- glmnet(db, x[,k], family = c('gaussian'), alpha = alpha, nlambda = nlambda, lambda.min.ratio = lambda.min.ratio)
    fit2$beta[,100]
  })
  res <- do.call(rbind, res)
  rownames(res) <- colnames(x)
  res
}

dcq2 <- function(x, db = db, size = ncol(db)/2, N = 10) {
  res <- matrix(NA, ncol = ncol(db), nrow = ncol(x))
  rownames(res) <- colnames(x)
  colnames(res) <- colnames(db)
  .list <- lapply(1:N, function(n) {
    tmp <- db[,sample(ncol(db), size)]
    tmp2 <- dcq(x, tmp)
    res[rownames(tmp2),colnames(tmp2)] <- tmp2
    res
  })
  mean <- apply(simplify2array(.list), c(1, 2), mean, na.rm = TRUE)
  sd <- apply(simplify2array(.list), c(1, 2), sd, na.rm = TRUE)
  list(mean = mean, sd = sd)
}
