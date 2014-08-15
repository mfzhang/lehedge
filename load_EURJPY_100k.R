source('munging_functions.R')

ask <- read.csv('EURJPY-Ask-100k.txt',sep=";",header=FALSE)
bid <- read.csv('EURJPY-Bid-100k.txt',sep=";",header=FALSE)

ask <- createPkStr(ask)
bid <- createPkStr(bid)
eurjpy <- merge(ask,bid,by.x=c("pk"),by.y=c("pk"))
names(eurjpy) <- c("dt", "ask", "bid")
#eurjpy$dt <- strptime(eurjpy$dt,"%Y%m%d %H%M%OS")
eurjpy$spread <- (eurjpy$ask - eurjpy$bid)*100

hist(eurjpy$spread,breaks=100)
summary(eurjpy$spread)

