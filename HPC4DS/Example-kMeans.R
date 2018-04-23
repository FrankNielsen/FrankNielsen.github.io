# filename: Example-kMeans.R
# k-means clustering using the R language
N <- 100000
x <- matrix(0, N, 2)
x[seq(1,N,by=4),]  <- rnorm(N/2)
x[seq(2,N,by=4),]  <- rnorm(N/2, 3, 1)
x[seq(3,N,by=4),]  <- rnorm(N/2, -3, 1)
x[seq(4,N,by=4),1] <- rnorm(N/4, 2, 1)
x[seq(4,N,by=4),2] <- rnorm(N/4, -2.5, 1)
start.kmeans <- proc.time()[3]
ans.kmeans <- kmeans(x, 4, nstart=3, iter.max=10, algorithm="Lloyd")
ans.kmeans$centers
end.kmeans <- proc.time()[3]
end.kmeans - start.kmeans
these <- sample(1:nrow(x), 1000)
plot(x[these,1], x[these,2], pch="+",xlab="x", ylab="y")
title(main="Clustering", sub="(globular shapes of clusters)", xlab="x", ylab="y")
points(ans.kmeans$centers, pch=19, cex=2, col=1:4)
