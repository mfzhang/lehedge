source('munging_functions.R')
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

# use one of the datasets to sample reference times
currencyData <- EURUSD.raw

nSamples <- 3600*24
nRecords <- min(nrow(EURJPY.raw),nrow(EURUSD.raw),nrow(USDJPY.raw))

# computed in earlier step
maxBestBuyForwardWindow <- 1500

# what we learn from
backwardWindow <- 2*maxBestBuyForwardWindow
forwardWindow  <- maxBestBuyForwardWindow

trainingRows <- sort(sample(1:(nRecords-forwardWindow-backwardWindow-1),nSamples))
trainingStartPoints <- currencyData[trainingRows,]
referenceTimes <- data.frame(epoch = trainingStartPoints$epoch,
                             training = rep(1,nrow(trainingStartPoints)))

# this magically interleaves the target currency timestamps
# and the reference times while flagging those
#for( currencyData in c(EURUSD.raw,EURJPY.raw,USDJPY.raw)) { 

EURUSD.ext <- merge_ref_times(EURUSD.raw, referenceTimes)
EURJPY.ext <- merge_ref_times(EURJPY.raw, referenceTimes)
USDJPY.ext <- merge_ref_times(USDJPY.raw, referenceTimes)

EURUSD.ask.training <- build_training_set(EURUSD.ext,referenceTimes, nSamples, backwardWindow)
EURJPY.ask.training <- build_training_set(EURJPY.ext,referenceTimes, nSamples, backwardWindow)
USDJPY.ask.training <- build_training_set(USDJPY.ext,referenceTimes, nSamples, backwardWindow)

EURUSD.ask.scaled <- scale(EURUSD.ask.training)
EURJPY.ask.scaled <- scale(EURJPY.ask.training)
USDJPY.ask.scaled <- scale(USDJPY.ask.training)

EURUSD.firstQuote <- build_first_quote(EURUSD.ext, backwardWindow)
EURJPY.firstQuote <- build_first_quote(EURJPY.ext, backwardWindow)
USDJPY.firstQuote <- build_first_quote(USDJPY.ext, backwardWindow)

EURUSD.lastQuote <- build_last_quote(EURUSD.ext, backwardWindow, forwardWindow)
EURJPY.lastQuote <- build_last_quote(EURJPY.ext, backwardWindow, forwardWindow)
USDJPY.lastQuote <- build_last_quote(USDJPY.ext, backwardWindow, forwardWindow)

# compute profit : buy at ask price, sell at bid price
options(digits = 2)
EURUSD.buy.profit <- 10000*(EURUSD.lastQuote[1,]-EURUSD.training[backwardWindow,])
options(digits = 5)
EURJPY.buy.profit <- 100*(EURJPY.lastQuote[1,]-EURJPY.training[backwardWindow,])
USDJPY.buy.profit <- 100*(USDJPY.lastQuote[1,]-USDJPY.training[backwardWindow,])

buy.profit <- data.frame(eurusd=EURUSD.buy.profit,
                         eurjpy=EURJPY.buy.profit,
                         usdjpy=USDJPY.buy.profit,
                         p=(EURUSD.buy.profit + EURJPY.buy.profit + USDJPY.buy.profit))

buy.profit.positive <- buy.profit[buy.profit$p > profit.target,,drop=FALSE]
row.names(ALL.profit.positive)

summary(ALL.buy.profit)
hist(ALL.buy.profit,breaks=100)

totalAvgSpread <- mean(EURJPY.raw$spread*100) + mean(EURUSD.raw$spread*10000) + mean(USDJPY.raw$spread*100)
print(totalAvgSpread)

EURJPY.ask.scaled.sigmoid <- 1/(1+exp(-EURJPY.ask.scaled[,1:nSamples]))
EURUSD.ask.scaled.sigmoid <- 1/(1+exp(-EURUSD.ask.scaled[,1:nSamples]))
USDJPY.ask.scaled.sigmoid <- 1/(1+exp(-USDJPY.ask.scaled[,1:nSamples]))

# 3000 pixels = 75*40 (golden ratio)
write_pngs(EURUSD.ask.scaled.sigmoid,
           EURJPY.ask.scaled.sigmoid,
           USDJPY.ask.scaled.sigmoid)


