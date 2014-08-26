
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

