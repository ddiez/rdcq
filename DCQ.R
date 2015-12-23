markers <- read.table("data/CellSurfaceMarkersDict.txt", stringsAsFactors = FALSE)
rownames(markers) <- markers[,2]

db <- read.delim("data/immgenGeneExpressionData.txt", stringsAsFactors = FALSE, check.names = FALSE)
db <- db[db[,1] %in% markers[,1], ]
rownames(db) <- db[,1]
db <- as.matrix(db[,-1])
db <- db[order(rownames(db)), order(colnames(db))]

DCQ <- function(x, db = db) {
  x <- x[rownames(db),] # reorder
  require(glmnet)
  res <- lapply(1:ncol(x), function(k) {
    fit2 <- glmnet(db, x[,k], family = c('gaussian'), alpha = .05, nlambda = 100, lambda.min = .2)
    fit2$beta[,100]
  })
  res <- do.call(rbind, res)
  rownames(res) <- colnames(x)
  res
}

DCQ2 <- function(x, db = db, size = ncol(db)/2, N = 10) {
  res <- matrix(NA, ncol = ncol(db), nrow = ncol(x))
  rownames(res) <- colnames(x)
  colnames(res) <- colnames(db)
  .list <- lapply(1:N, function(n) {
    tmp <- db[,sample(ncol(db), size)]
    tmp2 <- DCQ(x, tmp)
    res[rownames(tmp2),colnames(tmp2)] <- tmp2
    res
  })
  mean <- apply(simplify2array(.list), c(1,2), mean, na.rm=TRUE)
  sd <- apply(simplify2array(.list), c(1,2), sd, na.rm=TRUE)
  list(mean = mean, sd = sd)
}
