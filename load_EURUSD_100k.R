source('munging_functions.R')

ask <- read.csv('EURUSD-Ask-0622-0718.100k.txt',sep=";",header=FALSE)
bid <- read.csv('EURUSD-Bid-0622-0718.100k.txt',sep=";",header=FALSE)

ask <- createPkStr(ask)
bid <- createPkStr(bid)
eurusd <- merge(ask,bid,by.x=c("pk"),by.y=c("pk"))
names(eurusd) <- c("dt", "ask", "bid")
#eurusd$dt <- strptime(eurusd$dt,"%Y%m%d %H%M%OS")
eurusd$spread <- (eurusd$ask - eurusd$bid)*10000

hist(eurusd$spread,breaks=100)
summary(eurusd$spread)




