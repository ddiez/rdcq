library(glmnet)

db <- read.table("CellSurfaceMarkersDict.txt", stringsAsFactors = FALSE)
#head(db)
rownames(db) <- db[,2]
#head(db)

x <- read.delim("immgenGeneExpressionData.txt", stringsAsFactors = FALSE, check.names = FALSE)
#head(x)
x <- x[x[,1] %in% db[,1], ]
rownames(x) <- x[,1]
#head(x)
x <- as.matrix(x[,-1])
#head(x)
#x[1:10,1:10]
x <- x[order(rownames(x)), order(colnames(x))]
#x[1:10,1:10]

y <- read.delim("LungDataSet.txt", check.names = FALSE)
#head(y)
library(limma)
y <- avereps(y[,-1], ID = y[,1])
#head(y)
y <- y[rownames(y) %in% db[,2],]
rownames(y) <- db[rownames(y),1]
#head(y)
y <- y[rownames(x),] # reorder
#head(y)

################
# test
# fit2 <- glmnet(x, y[,1], family = c('gaussian'), alpha = .05, nlambda = 100, lambda.min = .2)
# 
# foo <- fit2$beta[,100]
# barplot(foo[foo != 0])
################

## do all.
res <- lapply(1:ncol(y), function(k) {
  fit2 <- glmnet(x, y[,k], family = c('gaussian'), alpha = .05, nlambda = 100, lambda.min = .2)
  fit2$beta[,100]
})
res <- do.call(rbind, res)
rownames(res) <- colnames(y)
#head(res)

res <- res[, colSums(res) != 0]

d <- melt(res, varnames = c("sample", "celltype"))
head(d)
#ggplot(d,aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5), axis.text.y = element_text(size = 5))

# DCs
ggplot(d %>% filter(grepl("DC", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

# CD8 T
ggplot(d %>% filter(grepl("T.8", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

# NK(T)
ggplot(d %>% filter(grepl("NK", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

# MF
ggplot(d %>% filter(grepl("MF", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

# MO
ggplot(d %>% filter(grepl("MO", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

# SC
ggplot(d %>% filter(grepl("SC", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))
