
options(digits.secs = 3)
options(digits = 13)

profit.target <- 30

minEpoch <- max(min(EURUSD.ticks$epoch),
                min(EURJPY.ticks$epoch),
                min(USDJPY.ticks$epoch))

maxEpoch <- min(max(EURUSD.ticks$epoch),
                max(EURJPY.ticks$epoch),
                max(USDJPY.ticks$epoch))

EURUSD.raw <- EURUSD.ticks[EURUSD.ticks$epoch >= minEpoch & EURUSD.ticks$epoch < maxEpoch,]
EURJPY.raw <- EURJPY.ticks[EURJPY.ticks$epoch >= minEpoch & EURJPY.ticks$epoch < maxEpoch,]
USDJPY.raw <- USDJPY.ticks[USDJPY.ticks$epoch >= minEpoch & USDJPY.ticks$epoch < maxEpoch,]



EURUSD.USDJPY <- merge(EURUSD.raw,USDJPY.raw,by.x="epoch",by.y="epoch",all.x=TRUE,all.y=TRUE )
EURUSD.USDJPY.EURJPY <- merge(EURUSD.USDJPY,EURJPY.raw,by.x="epoch",by.y="epoch",all.x=TRUE,all.y=TRUE )
names(EURUSD.USDJPY.EURJPY) <- c("epoch","EURUSD.ask","EURUSD.bid","EURUSD.spread","EURUSD.ask.vol","EURUSD.bid.vol","USDJPY.ask","USDJPY.bid","USDJPY.spread","USDJPY.ask.vol","USDJPY.bid.vol","EURJPY.ask","EURJPY.bid","EURJPY.spread","EURJPY.ask.vol","EURJPY.bid.vol")
all.rates <- EURUSD.USDJPY.EURJPY[,c("epoch","EURUSD.ask","EURUSD.bid","USDJPY.ask","USDJPY.bid","EURJPY.ask","EURJPY.bid")]

# clean up to avoid huge workspace data files
rm(EURUSD.USDJPY.EURJPY)
rm(EURUSD.USDJPY)
rm(EURUSD.ticks)
rm(EURJPY.ticks)
rm(USDJPY.ticks)

all.rates[,"EURUSD.ask"] <- fillna("EURUSD.ask")
all.rates[,"EURJPY.ask"] <- fillna("EURJPY.ask")
all.rates[,"USDJPY.ask"] <- fillna("USDJPY.ask")

all.rates[,"EURUSD.bid"] <- fillna("EURUSD.bid")
all.rates[,"EURJPY.bid"] <- fillna("EURJPY.bid")
all.rates[,"USDJPY.bid"] <- fillna("USDJPY.bid")

# size of entire dataset
nData <- nrow(all.rates)
#all.rates.100k.head <- all.rates[1:100000,]
#all.rates.100k.tail <- all.rates[(nData-99999):nData,]

cropStart <- max(head(which(!is.na(all.rates.100k.head$EURUSD.ask)),n=1),
                 head(which(!is.na(all.rates.100k.head$EURJPY.ask)),n=1),
                 head(which(!is.na(all.rates.100k.head$USDJPY.ask)),n=1) )

all.rates <- all.rates[cropStart:nData,]
nData <- nrow(all.rates)
all.rates.100k.head <- all.rates[1:100000,]
all.rates.100k.tail <- all.rates[(nData-99999):nData,]

# we need best windows now rather than later

maxEURUSD <- bestBuyForwardWindow("EURUSD",10000)
print(paste("EURUSD=",maxEURUSD))

maxUSDJPY <- bestBuyForwardWindow("USDJPY",100)
print(paste("USDJPY=",maxUSDJPY))

maxEURJPY <- bestBuyForwardWindow("EURJPY",100)
print(paste("EURJPY=",maxEURJPY))

forwardWindow <- max( maxEURUSD,
                      maxUSDJPY,
                      maxEURJPY)

print(paste("Best buy max window=",forwardWindow))


# lag all columns by forward window to compute profit
all.rates$EURUSD.ask.fwd <- c(diff(all.rates$EURUSD.ask,forwardWindow),rep(NA,forwardWindow)) * 10000
all.rates$EURUSD.bid.fwd <- c(diff(all.rates$EURUSD.bid,forwardWindow),rep(NA,forwardWindow)) * 10000
all.rates$EURJPY.ask.fwd <- c(diff(all.rates$EURJPY.ask,forwardWindow),rep(NA,forwardWindow)) * 100
all.rates$EURJPY.bid.fwd <- c(diff(all.rates$EURJPY.bid,forwardWindow),rep(NA,forwardWindow)) * 100
all.rates$USDJPY.ask.fwd <- c(diff(all.rates$USDJPY.ask,forwardWindow),rep(NA,forwardWindow)) * 100
all.rates$USDJPY.bid.fwd <- c(diff(all.rates$USDJPY.bid,forwardWindow),rep(NA,forwardWindow)) * 100

# crop crop crop
all.rates <- all.rates[1:(nData-forwardWindow),]

# buy positions are opened at ask price and sold at bid price
# so we use the bid price diff and substract the entry spread
all.rates[,"EURUSD.buy.profit"]  <- all.rates[,"EURUSD.bid.fwd"] - (all.rates[,"EURUSD.ask"]-all.rates[,"EURUSD.bid"])
all.rates[,"EURJPY.buy.profit"]  <- all.rates[,"EURJPY.bid.fwd"] - (all.rates[,"EURJPY.ask"]-all.rates[,"EURJPY.bid"])
all.rates[,"USDJPY.buy.profit"]  <- all.rates[,"USDJPY.bid.fwd"] - (all.rates[,"USDJPY.ask"]-all.rates[,"USDJPY.bid"])

# sell positions are opened at bid price (the market maker's price to buy) and sold at ask price
# so we use the ask price diff and substract the entry spread
# TODO : understand how this logic changes when we act as market makers (on LMAX for instance)
all.rates[,"EURUSD.sell.profit"]  <- -1*(all.rates[,"EURUSD.ask.fwd"] - (all.rates[,"EURUSD.ask"]-all.rates[,"EURUSD.bid"]))
all.rates[,"EURJPY.sell.profit"]  <- -1*(all.rates[,"EURJPY.ask.fwd"] - (all.rates[,"EURJPY.ask"]-all.rates[,"EURJPY.bid"]))
all.rates[,"USDJPY.sell.profit"]  <- -1*(all.rates[,"USDJPY.ask.fwd"] - (all.rates[,"USDJPY.ask"]-all.rates[,"USDJPY.bid"]))


individual.profit.target <- 10

totalAvgSpread <- mean((all.rates$EURUSD.ask-all.rates$EURUSD.bid)*10000) + mean((all.rates$EURJPY.ask-all.rates$EURJPY.bid)*100) + mean((all.rates$USDJPY.ask-all.rates$USDJPY.bid)*100) 

u <- individual.profit.target + totalAvgSpread

# we need to identify the best action best on buy profit and sell profit
# sell > 0 & buy > 0 
all.rates[,"EURUSD.profit"] <- ifelse(all.rates[,"EURUSD.buy.profit"] > all.rates[,"EURUSD.sell.profit"], all.rates[,"EURUSD.buy.profit"], all.rates[,"EURUSD.sell.profit"])
all.rates[,"EURJPY.profit"] <- ifelse(all.rates[,"EURJPY.buy.profit"] > all.rates[,"EURJPY.sell.profit"], all.rates[,"EURJPY.buy.profit"], all.rates[,"EURJPY.sell.profit"])
all.rates[,"USDJPY.profit"] <- ifelse(all.rates[,"USDJPY.buy.profit"] > all.rates[,"USDJPY.sell.profit"], all.rates[,"USDJPY.buy.profit"], all.rates[,"USDJPY.sell.profit"])

all.rates[,"EURUSD.decision"] <- ifelse(all.rates[,"EURUSD.buy.profit"] > all.rates[,"EURUSD.sell.profit"],1,-1)
all.rates[,"EURJPY.decision"] <- ifelse(all.rates[,"EURJPY.buy.profit"] > all.rates[,"EURJPY.sell.profit"],1,-1)
all.rates[,"USDJPY.decision"] <- ifelse(all.rates[,"USDJPY.buy.profit"] > all.rates[,"USDJPY.sell.profit"],1,-1)

#all.profit$EURUSD.label <- ifelse(all.profit$EURUSD.decision == 1,ifelse(all.profit$EURUSD.profit>u,1,0){},-1)

