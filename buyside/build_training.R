source('../common/base_dataset.R')
source('best_windows.R')


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

EURUSD.buy.ext <- merge_ref_times(EURUSD.raw, referenceTimes)
EURJPY.buy.ext <- merge_ref_times(EURJPY.raw, referenceTimes)
USDJPY.buy.ext <- merge_ref_times(USDJPY.raw, referenceTimes)

EURUSD.ask.training <- build_training_set(EURUSD.buy.ext,referenceTimes, nSamples, backwardWindow)
EURJPY.ask.training <- build_training_set(EURJPY.buy.ext,referenceTimes, nSamples, backwardWindow)
USDJPY.ask.training <- build_training_set(USDJPY.buy.ext,referenceTimes, nSamples, backwardWindow)

EURUSD.bid.training <- build_training_set("bid",EURUSD.buy.ext,referenceTimes, nSamples, backwardWindow)
EURJPY.bid.training <- build_training_set("bid",EURJPY.buy.ext,referenceTimes, nSamples, backwardWindow)
USDJPY.bid.training <- build_training_set("bid",USDJPY.buy.ext,referenceTimes, nSamples, backwardWindow)

EURUSD.ask.scaled <- scale(EURUSD.ask.training)
EURJPY.ask.scaled <- scale(EURJPY.ask.training)
USDJPY.ask.scaled <- scale(USDJPY.ask.training)

#EURUSD.firstQuote <- build_first_quote(EURUSD.ext, backwardWindow)
#EURJPY.firstQuote <- build_first_quote(EURJPY.ext, backwardWindow)
#USDJPY.firstQuote <- build_first_quote(USDJPY.ext, backwardWindow)

EURUSD.lastQuote <- build_last_quote(EURUSD.buy.ext, backwardWindow, forwardWindow)
EURJPY.lastQuote <- build_last_quote(EURJPY.buy.ext, backwardWindow, forwardWindow)
USDJPY.lastQuote <- build_last_quote(USDJPY.buy.ext, backwardWindow, forwardWindow)

# compute profit : buy at ask price, sell at bid price
options(digits = 2)
EURUSD.buy.profit <- 10000*(EURUSD.lastQuote[1,]-EURUSD.ask.training[backwardWindow,])
options(digits = 5)
EURJPY.buy.profit <- 100*(EURJPY.lastQuote[1,]-EURJPY.ask.training[backwardWindow,])
USDJPY.buy.profit <- 100*(USDJPY.lastQuote[1,]-USDJPY.ask.training[backwardWindow,])

buy.profit <- data.frame(eurusd=EURUSD.buy.profit,
                         eurjpy=EURJPY.buy.profit,
                         usdjpy=USDJPY.buy.profit,
                         p=(EURUSD.buy.profit + EURJPY.buy.profit + USDJPY.buy.profit))

buy.profit.sample <- buy.profit[sample(1:86400,8640),]

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


