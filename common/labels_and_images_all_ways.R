library(stringr)

all.profit <- all.rates

all.profit[,"EURUSD.median"] <- (all.profit[,"EURUSD.ask"] + all.profit[,"EURUSD.bid"])/2
all.profit[,"EURJPY.median"] <- (all.profit[,"EURJPY.ask"] + all.profit[,"EURJPY.bid"])/2
all.profit[,"USDJPY.median"] <- (all.profit[,"USDJPY.ask"] + all.profit[,"USDJPY.bid"])/2

all.profit[ all.profit$EURUSD.profit < u  &
            all.profit$EURJPY.profit < u  &
            all.profit$USDJPY.profit < u,   "label" ] <- "000" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "010" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "020" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "001" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "002" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "012" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "021" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "011" 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "022" 

# starting with 1

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit < u,   "label" ] <- "100"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "110" 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "120" 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "101" 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "102"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "111"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "112"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "121"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "122"

# starting with 2

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit < u,   "label" ] <- "200"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "210"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit < u,   "label" ] <- "220"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "201"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "202" 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "211"

# none 
all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "212"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- "221"

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- "222"

label.counts <- table(all.profit$label)
print(label.counts)

all.profit[,"recoded"] <- NA

# build stratified training set
all.profit.000 <- subset(all.profit,label %in% c("000","021","012","101","121","120","202","210","212","221"))
nData.000      <- nrow(all.profit.000)
s000           <- sort(sample(1:nData.000,size=10000))
all.profit.000.sample <- all.profit.000[s000,]
all.profit.000.sample[,"recoded"] <- 0
all.profit[row.names(all.profit.000.sample),"recoded"] <- 0

all.profit.001 <- subset(all.profit,label == "001")
nData.001      <- nrow(all.profit.001)
s001           <- sort(sample(1:nData.001,size=10000))
all.profit.001.sample <- all.profit.001[s001,]

all.profit[row.names(all.profit.001.sample),"recoded"] <- 1

all.profit.002 <- subset(all.profit,label == "002")
nData.002      <- nrow(all.profit.002)
s002           <- sort(sample(1:nData.002,size=10000))
all.profit.002.sample <- all.profit.002[s002,]

all.profit[row.names(all.profit.002.sample),"recoded"] <- 2

all.profit.010 <- subset(all.profit,label == "010")
nData.010      <- nrow(all.profit.010)
s010           <- sort(sample(1:nData.010,size=10000))
all.profit.010.sample <- all.profit.010[s010,]

all.profit[row.names(all.profit.010.sample),"recoded"] <- 3

all.profit.011 <- subset(all.profit,label == "011")
nData.011      <- nrow(all.profit.011)
s011           <- sort(sample(1:nData.011,size=10000))
all.profit.011.sample <- all.profit.011[s011,]

all.profit[row.names(all.profit.011.sample),"recoded"] <- 4

all.profit.020 <- subset(all.profit,label == "020")
nData.020      <- nrow(all.profit.020)
s020           <- sort(sample(1:nData.020,size=10000))
all.profit.020.sample <- all.profit.020[s020,]

all.profit[row.names(all.profit.020.sample),"recoded"] <- 5

all.profit.022 <- subset(all.profit,label == "022")
nData.022      <- nrow(all.profit.022)
s022           <- sort(sample(1:nData.022,size=10000))
all.profit.022.sample <- all.profit.022[s022,]

all.profit[row.names(all.profit.022.sample),"recoded"] <- 6

all.profit.100 <- subset(all.profit,label == "100")
nData.100      <- nrow(all.profit.100)
s100           <- sort(sample(1:nData.100,size=10000))
all.profit.100.sample <- all.profit.100[s100,]

all.profit[row.names(all.profit.100.sample),"recoded"] <- 7

all.profit.102 <- subset(all.profit,label == "102")
nData.102      <- nrow(all.profit.102)
s102           <- sort(sample(1:nData.102,size=10000))
all.profit.102.sample <- all.profit.102[s102,]

all.profit[row.names(all.profit.102.sample),"recoded"] <- 8

all.profit.110 <- subset(all.profit,label == "110")
nData.110      <- nrow(all.profit.110)
s110           <- sort(sample(1:nData.110,size=10000))
all.profit.110.sample <- all.profit.110[s110,]

all.profit[row.names(all.profit.110.sample),"recoded"] <- 9

all.profit.111 <- subset(all.profit,label == "111")
nData.111      <- nrow(all.profit.111)
s111           <- sort(sample(1:nData.111,size=10000))
all.profit.111.sample <- all.profit.111[s111,]

all.profit[row.names(all.profit.111.sample),"recoded"] <- 10

all.profit.112 <- subset(all.profit,label == "112")
nData.112      <- nrow(all.profit.112)
s112           <- sort(sample(1:nData.112,size=10000))
all.profit.112.sample <- all.profit.112[s112,]

all.profit[row.names(all.profit.112.sample),"recoded"] <- 11

all.profit.122 <- subset(all.profit,label == "122")
nData.122      <- nrow(all.profit.122)
s122           <- sort(sample(1:nData.122,size=10000))
all.profit.122.sample <- all.profit.122[s122,]

all.profit[row.names(all.profit.122.sample),"recoded"] <- 12

all.profit.200 <- subset(all.profit,label == "200")
nData.200      <- nrow(all.profit.200)
s200           <- sort(sample(1:nData.200,size=10000))
all.profit.200.sample <- all.profit.200[s200,]

all.profit[row.names(all.profit.200.sample),"recoded"] <- 13

all.profit.201 <- subset(all.profit,label == "201")
nData.201      <- nrow(all.profit.201)
s201           <- sort(sample(1:nData.201,size=10000))
all.profit.201.sample <- all.profit.201[s201,]

all.profit[row.names(all.profit.201.sample),"recoded"] <- 14

all.profit.211 <- subset(all.profit,label == "211")
nData.211      <- nrow(all.profit.211)
s211           <- sort(sample(1:nData.211,size=10000))
all.profit.211.sample <- all.profit.211[s211,]

all.profit[row.names(all.profit.211.sample),"recoded"] <- 15

all.profit.220 <- subset(all.profit,label == "220")
nData.220      <- nrow(all.profit.220)
s220           <- sort(sample(1:nData.220,size=10000))
all.profit.220.sample <- all.profit.220[s220,]

all.profit[row.names(all.profit.220.sample),"recoded"] <- 16

all.profit.222 <- subset(all.profit,label == "222")
nData.222      <- nrow(all.profit.222)
s222           <- sort(sample(1:nData.222,size=10000))
all.profit.222.sample <- all.profit.222[s222,]

all.profit[row.names(all.profit.222.sample),"recoded"] <- 17

full.sample <- rbind(all.profit.000.sample,
                     all.profit.001.sample,
                     all.profit.002.sample,
                     all.profit.010.sample,
                     all.profit.011.sample,
                     all.profit.020.sample,
                     all.profit.022.sample,
                     all.profit.100.sample,
                     all.profit.102.sample,
                     all.profit.110.sample,
                     all.profit.111.sample,
                     all.profit.112.sample,
                     all.profit.122.sample,
                     all.profit.200.sample,
                     all.profit.201.sample,
                     all.profit.211.sample,
                     all.profit.220.sample,
                     all.profit.222.sample)

# flag samples in master dataset
all.profit[,"sample"] <- NA
all.profit[row.names(full.sample),"sample"] <- 1

# what we learn from
backwardWindow <- 2*maxBestBuyForwardWindow
forwardWindow  <- maxBestBuyForwardWindow

# this gives us the first row of the dataset for which 
# we know we have enough ticks for all 3 currencies to fill the backward window
# it is where we should initialize the head of the tick reader

nData <- nrow(all.profit)
minRow <- backwardWindow
maxRow <- nData-forwardWindow+1 

print(paste("head initialization row = ",minRow,sep=""))

# let the image generation happen!!
# this will generate 960K images, about 10GB when backward window is 10600 pixels

samplingIdx <- sort(which(all.profit[,"sample"]==1))
#croppedIdx <- sort(samplingIdx[samplingIdx >= minRow & samplingIdx <= maxRow])
cropEnds <- sort(samplingIdx[samplingIdx < minRow | samplingIdx > maxRow])

# reset to NA in cropStart and cropEnd zones
all.profit[cropEnds,"sample"] <- NA

# readjust to later pass to spit_image
samplingIdx <- sort(which(all.profit[,"sample"]==1))
#croppedIdx <- sort(samplingIdx[samplingIdx >= minRow & samplingIdx <= maxRow])

# get the full sample cleaned from starting and ending short-sighted portions
almost.full.sample <- subset(all.profit,sample==1)

# shuffle samples
nSample <- nrow(almost.full.sample)
# create permutation of indices
shuffler <- sample(1:nSample,size=nSample)
# shuffle labels
almost.full.sample.shuffled <- almost.full.sample[shuffler,] 
# Corrective action : almost.full.sample.shuffled <- almost.full.sample[shuffler>=minRow & shuffler <=maxRow,] 

validation.idx <- sort(sample(1:nSample,size=0.1*nSample))
# Corrective action : validation.idx <- validation.idx[validation.idx>=minRow & validation.idx<=maxRow]
validation.sample <- almost.full.sample.shuffled[validation.idx,]
training.sample <- almost.full.sample.shuffled[-validation.idx,]

training.sample[,"filename"] <- paste(str_pad(row.names(training.sample), 8, pad="0"),".png",sep="")
validation.sample[,"filename"] <- paste(str_pad(row.names(validation.sample), 8, pad="0"),".png",sep="")

write.table(x=training.sample[,c("filename","recoded")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="data/2/labels_training.txt")

write.table(x=validation.sample[,c("filename","recoded")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="data/2/labels_validation.txt")

# let the image generation happen!!
# this will generate 960K images, about 10GB when backward window is 10600 pixels

library(png)

spit_sample_images(backwardWindow,"data/2/img/", samplingIdx)
