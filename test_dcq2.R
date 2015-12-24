source("DCQ.R")

x <- read.delim("data/LungDataSet.txt", check.names = FALSE)
library(limma)
x <- avereps(x[,-1], ID = x[,1])
head(x)
x <- x[rownames(x) %in% markers[,2],]
rownames(x) <- markers[rownames(x),1]
head(x)
tmp <- DCQ(x, db = db)
tmp

d <- melt(tmp, varnames = c("sample", "celltype"))
head(d)
ggplot(d,aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5), axis.text.y = element_text(size = 5))

# DCs
ggplot(d %>% filter(grepl("DC", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

### with resampling
tmp <- DCQ2(x, db = db, N = 100)
length(tmp)
sapply(tmp, dim)
sapply(tmp, colnames)

d <- melt(tmp$mean, varnames = c("sample", "celltype"))

ggplot(d,aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5), axis.text.y = element_text(size = 5))

# DCs
ggplot(d %>% filter(grepl("DC", celltype)),aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(aspect.ratio = 1, axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))

m <- tmp$mean
m[tmp$sd > 0.001] <- 0
d <- melt(m, varnames = c("sample", "celltype"))

qplot(c(tmp$sd))


#######
## trick!
m1 <- matrix(NA, ncol = 5, nrow = 4, dimnames = list(1:4,1:5))
m2 <- matrix(1:20, ncol = 5, nrow = 4, dimnames = list(1:4,1:5))
m3 <- matrix(20:1, ncol = 5, nrow = 4, dimnames = list(1:4,1:5))
m1
m2
m3


apply(simplify2array(list(m1,m2,m3)), c(1,2), sum, na.rm=TRUE)

m4 <- matrix(1, ncol = 2, nrow = 2, dimnames = list(3:4,2:3))
m1
m1[rownames(m4),colnames(m4)] <- m4
m1


