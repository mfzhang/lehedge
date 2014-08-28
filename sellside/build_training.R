
# what we learn from
backwardWindow <- 2*maxBestSellForwardWindow
forwardWindow  <- maxBestSellForwardWindow

trainingRows <- sort(sample(1:(nRecords-forwardWindow-backwardWindow-1),nSamples))
trainingStartPoints <- currencyData[trainingRows,]
referenceTimes <- data.frame(epoch = trainingStartPoints$epoch,
                             training = rep(1,nrow(trainingStartPoints)))

# this magically interleaves the target currency timestamps
# and the reference times while flagging those
#for( currencyData in c(EURUSD.raw,EURJPY.raw,USDJPY.raw)) { 

EURUSD.sell.ext <- merge_ref_times(EURUSD.raw, referenceTimes)
EURJPY.sell.ext <- merge_ref_times(EURJPY.raw, referenceTimes)
USDJPY.sell.ext <- merge_ref_times(USDJPY.raw, referenceTimes)

EURUSD.bid.training <- build_training_set("bid",EURUSD.sell.ext,referenceTimes, nSamples, backwardWindow)
EURJPY.bid.training <- build_training_set("bid",EURJPY.sell.ext,referenceTimes, nSamples, backwardWindow)
USDJPY.bid.training <- build_training_set("bid",USDJPY.sell.ext,referenceTimes, nSamples, backwardWindow)

EURUSD.bid.scaled <- scale(EURUSD.bid.training)
EURJPY.bid.scaled <- scale(EURJPY.bid.training)
USDJPY.bid.scaled <- scale(USDJPY.bid.training)

EURUSD.sell.lastQuote <- build_last_quote(EURUSD.sell.ext, backwardWindow, forwardWindow)
EURJPY.sell.lastQuote <- build_last_quote(EURJPY.sell.ext, backwardWindow, forwardWindow)
USDJPY.sell.lastQuote <- build_last_quote(USDJPY.sell.ext, backwardWindow, forwardWindow)

# compute profit : buy at ask price, sell at bid price
options(digits = 2)
EURUSD.sell.profit <- 10000*(EURUSD.sell.lastQuote[1,]-EURUSD.bid.training[backwardWindow,])
options(digits = 5)
EURJPY.sell.profit <- 100*(EURJPY.sell.lastQuote[1,]-EURJPY.bid.training[backwardWindow,])
USDJPY.sell.profit <- 100*(USDJPY.sell.lastQuote[1,]-USDJPY.bid.training[backwardWindow,])

sell.profit <- data.frame(eurusd=EURUSD.sell.profit,
                         eurjpy=EURJPY.sell.profit,
                         usdjpy=USDJPY.sell.profit,
                         p=(EURUSD.sell.profit + EURJPY.sell.profit + USDJPY.sell.profit))

EURJPY.bid.scaled.sigmoid <- 1/(1+exp(-EURJPY.bid.scaled[,1:nSamples]))
EURUSD.bid.scaled.sigmoid <- 1/(1+exp(-EURUSD.bid.scaled[,1:nSamples]))
USDJPY.bid.scaled.sigmoid <- 1/(1+exp(-USDJPY.bid.scaled[,1:nSamples]))

all_records <- 1:nSamples
sell.validation <- sample(all_records,0.15*nSamples)

write_pngs('sellside/img/train/file',
           all_records[! all_records %in% sell.validation],
           EURUSD.bid.scaled.sigmoid,
           EURJPY.bid.scaled.sigmoid,
           USDJPY.bid.scaled.sigmoid)

write_pngs('sellside/img/val/file',
           sell.validation,             
           EURUSD.bid.scaled.sigmoid,
           EURJPY.bid.scaled.sigmoid,
           USDJPY.bid.scaled.sigmoid)


