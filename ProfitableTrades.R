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
