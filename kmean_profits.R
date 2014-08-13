library(ggplot2)
d <- read.table("training_profits.csv",sep=",")
ggplot(data=d,aes(x=1:nrow(d))) + geom_line(aes(y=V1,color="EURJPY")) + geom_line(aes(y=V2,color="EURUSD")) + geom_line(aes(y=V3,color="USDJPY")) + ylab("profit") + xlab("time ordered samples")

d$buyall <- d$V1+d$V2+d$V3
d$sellall <- -d$buyall
ggplot(data=d,aes(x=1:nrow(d))) + geom_line(aes(y=buyall,color="Buy all")) + geom_line(aes(y=sellall,color="Sell all")) + ylab("profit") + xlab("time ordered samples")

profitOverTen <- d[d$buyall >= 10 | d$sellall >= 10,]
sum(abs(profitOverTen$total))
summary(abs(profitOverTen$total))
sum(abs(profitOverTen$total))-3*3*501

head(d)
tail(d)

df <- scale(d)
  
wssplot <- function(data, nc=15, seed=1234) {
    wss <- (nrow(data)-1)*sum(apply(data,2,var))
    for (i in 2:nc) {
      set.seed(seed)
      wss[i] <- sum(kmeans(data, centers=i)$withinss)
    }
    plot(1:nc, wss, type="b", xlab="Number of Clusters",
                              ylab="Within groups sum of squares")
}

wssplot(df)

library(NbClust)
set.seed(1234)
nc <- NbClust(df, min.nc=2, max.nc=15, method="kmeans")
table(nc$Best.n[1,])
barplot(table(nc$Best.n[1,]), 
        xlab="Numer of Clusters", ylab="Number of Criteria",
        main="Number of Clusters Chosen by 26 Criteria")

fit.km <- kmeans(df, 2, nstart=25)                           
fit.km$size
fit.km$centers                                              
e <- cbind(d,fit.km$cluster)
aggregate(e, by=list(cluster=fit.km$cluster), mean)

fit.km3 <- kmeans(df, 3, nstart=25)                           
fit.km3$size
fit.km3$centers                                              
e <- cbind(d,fit.km3$cluster)
aggregate(e, by=list(cluster=fit.km3$cluster), mean)

fit.km11 <- kmeans(df, 11, nstart=25)                           
fit.km11$size
fit.km11$centers                                              
e <- cbind(d,fit.km11$cluster)
aggregate(e, by=list(cluster=fit.km11$cluster), mean)
aggregate(e, by=list(cluster=fit.km11$cluster), sum)

profitOverTenK <- e[e$buyall >= 10 | e$sellall >= 10,]


