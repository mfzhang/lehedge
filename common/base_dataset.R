
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
