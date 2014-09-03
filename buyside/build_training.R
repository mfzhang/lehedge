
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

EURUSD.ask.training <- build_training_set("ask",EURUSD.buy.ext,referenceTimes, nSamples, backwardWindow)
EURJPY.ask.training <- build_training_set("ask",EURJPY.buy.ext,referenceTimes, nSamples, backwardWindow)
USDJPY.ask.training <- build_training_set("ask",USDJPY.buy.ext,referenceTimes, nSamples, backwardWindow)

EURUSD.ask.scaled <- scale(EURUSD.ask.training)
EURJPY.ask.scaled <- scale(EURJPY.ask.training)
USDJPY.ask.scaled <- scale(USDJPY.ask.training)

EURUSD.buy.lastQuote <- build_last_quote(EURUSD.buy.ext, backwardWindow, forwardWindow)
EURJPY.buy.lastQuote <- build_last_quote(EURJPY.buy.ext, backwardWindow, forwardWindow)
USDJPY.buy.lastQuote <- build_last_quote(USDJPY.buy.ext, backwardWindow, forwardWindow)

# compute profit : buy at ask price, sell at bid price
options(digits = 2)
EURUSD.buy.profit <- 10000*(EURUSD.buy.lastQuote[1,]-EURUSD.ask.training[backwardWindow,])
options(digits = 5)
EURJPY.buy.profit <- 100*(EURJPY.buy.lastQuote[1,]-EURJPY.ask.training[backwardWindow,])
USDJPY.buy.profit <- 100*(USDJPY.buy.lastQuote[1,]-USDJPY.ask.training[backwardWindow,])

buy.profit <- data.frame(eurusd=EURUSD.buy.profit,
                         eurjpy=EURJPY.buy.profit,
                         usdjpy=USDJPY.buy.profit,
                         p=(EURUSD.buy.profit + EURJPY.buy.profit + USDJPY.buy.profit))


EURJPY.ask.scaled.sigmoid <- 1/(1+exp(-EURJPY.ask.scaled[,1:nSamples]))
EURUSD.ask.scaled.sigmoid <- 1/(1+exp(-EURUSD.ask.scaled[,1:nSamples]))
USDJPY.ask.scaled.sigmoid <- 1/(1+exp(-USDJPY.ask.scaled[,1:nSamples]))

all_records <- 1:nSamples
buy.validation <- sample(all_records,0.15*nSamples)

