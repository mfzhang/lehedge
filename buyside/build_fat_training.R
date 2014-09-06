# size of entire dataset
nData <- nrow(all.rates)

desiredSampleCount <- 1500000
samplingRate <- round(nrow(all.rates)/desiredSampleCount,2)

# what we learn from
backwardWindow <- 2*maxBestBuyForwardWindow
forwardWindow  <- maxBestBuyForwardWindow

# identify margins to avoid tick depletion at initialization and end phase of sampling

all.rates.100k.head <- all.rates[1:100000,]

EURUSD.prefill <- findMinRow(all.rates.100k.head, "EURUSD", backwardWindow)
EURJPY.prefill <- findMinRow(all.rates.100k.head, "EURJPY", backwardWindow)
USDJPY.prefill <- findMinRow(all.rates.100k.head, "USDJPY", backwardWindow)

all.rates.100k.tail <- all.rates[(nData-99999):nData,]

EURUSD.postfill <- findMaxRow(all.rates.100k.tail, "EURUSD", forwardWindow)
EURJPY.postfill <- findMaxRow(all.rates.100k.tail, "EURJPY", forwardWindow)
USDJPY.postfill <- findMaxRow(all.rates.100k.tail, "USDJPY", forwardWindow)

# this gives us the first row of the dataset for which 
# we know we have enough ticks for all 3 currencies to fill the backward window
# it is where we should initialize the head of the tick reader

minRow <- max(EURUSD.prefill,EURJPY.prefill,USDJPY.prefill)
maxRow <- nData-max(EURUSD.postfill,EURJPY.postfill,USDJPY.postfill)+1

print(paste("head initialization row = ",minRow,sep=""))

# let the sampling happen!!
# this will generate 1.2M images, about 4.7GB when backward window is 2600 pixels
# returns a vector of zeros and ones indicating the end points of time frames for all samples

samplingIdx <- sort(sample(minRow:maxRow,replace=FALSE,size=round(samplingRate*nData)))
stuff <- build_training_set_images("ask",backwardWindow,"buyside/img/",samplingIdx)

# our looping adds one extra head, let's crop this 
sampledf <- data.frame(s=sampled[1:nrow(all.rates)])
# how many samples do we have?
print(paste("sampled ",length(sampled[sampled==1]), "records"))

#forwardWindow <- 1300

EURUSD.close <- closeRates("EURUSD", forwardWindow, sampledf)
EURJPY.buy.lastQuote <- build_last_quote(EURJPY.buy.ext, backwardWindow, forwardWindow)
USDJPY.buy.lastQuote <- build_last_quote(USDJPY.buy.ext, backwardWindow, forwardWindow)

# compute profit : buy at ask price, sell at bid price
options(digits = 2)
EURUSD.buy.profit <- 10000*(EURUSD.buy.lastQuote[1,]-EURUSD.buy.firstQuote[1,])
options(digits = 5)
EURJPY.buy.profit <- 100*(EURJPY.buy.lastQuote[1,]-EURJPY.buy.firstQuote[1,])
USDJPY.buy.profit <- 100*(USDJPY.buy.lastQuote[1,]-USDJPY.buy.firstQuote[1,])

buy.profit <- data.frame(eurusd=EURUSD.buy.profit,
                         eurjpy=EURJPY.buy.profit,
                         usdjpy=USDJPY.buy.profit,
                         p=(EURUSD.buy.profit + EURJPY.buy.profit + USDJPY.buy.profit))


#EURJPY.ask.scaled.sigmoid <- 1/(1+exp(-EURJPY.ask.scaled[,1:nSamples]))
#EURUSD.ask.scaled.sigmoid <- 1/(1+exp(-EURUSD.ask.scaled[,1:nSamples]))
#USDJPY.ask.scaled.sigmoid <- 1/(1+exp(-USDJPY.ask.scaled[,1:nSamples]))

all_records <- 1:nSamples
buy.validation <- sample(all_records,0.15*nSamples)

