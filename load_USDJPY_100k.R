source('munging_functions.R')

ask <- read.csv('USDJPY-Ask-0620-0718.100k.txt',sep=";",header=FALSE)
bid <- read.csv('USDJPY-Bid-0620-0718.100k.txt',sep=";",header=FALSE)

ask <- createPkStr(ask)
bid <- createPkStr(bid)
usdjpy <- merge(ask,bid,by.x=c("pk"),by.y=c("pk"))
names(usdjpy) <- c("dt", "ask", "bid")
#usdjpy$dt <- strptime(usdjpy$dt,"%Y%m%d %H%M%OS")
usdjpy$spread <- (usdjpy$ask - usdjpy$bid)*100

hist(usdjpy$spread,breaks=100)
summary(usdjpy$spread)

