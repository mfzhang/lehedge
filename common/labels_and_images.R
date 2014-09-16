library(stringr)

all.profit <- all.rates

all.profit[,"EURUSD.median"] <- (all.profit[,"EURUSD.ask"] + all.profit[,"EURUSD.bid"])/2
all.profit[,"EURJPY.median"] <- (all.profit[,"EURJPY.ask"] + all.profit[,"EURJPY.bid"])/2
all.profit[,"USDJPY.median"] <- (all.profit[,"USDJPY.ask"] + all.profit[,"USDJPY.bid"])/2

all.profit[ all.profit$EURUSD.profit < u  &
            all.profit$EURJPY.profit < u  &
            all.profit$USDJPY.profit < u,   "label" ] <- 0 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit < u,   "label" ] <- 1

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit < u,   "label" ] <- 11

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit < u,   "label" ] <- 2 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit < u,   "label" ] <- 12 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- 3 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- 13 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit < u,   "label" ] <- 4 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit < u,   "label" ] <- 14

# EUR > USD & USD > JPY contradicts EUR < JPY
all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == 1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- 5 

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &              
              all.profit$EURJPY.profit < u  &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- 15 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == 1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == 1,   "label" ] <- 6 

all.profit[ all.profit$EURUSD.profit < u  &
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- 16 

all.profit[ all.profit$EURUSD.profit >= u  &
            all.profit$EURUSD.decision == 1 &  
            all.profit$EURJPY.profit >= u  &
            all.profit$EURJPY.decision == 1 &
            all.profit$USDJPY.profit >= u &
            all.profit$USDJPY.decision == 1,   "label" ] <- 7

all.profit[ all.profit$EURUSD.profit >= u  &
              all.profit$EURUSD.decision == -1 &  
              all.profit$EURJPY.profit >= u  &
              all.profit$EURJPY.decision == -1 &
              all.profit$USDJPY.profit >= u &
              all.profit$USDJPY.decision == -1,   "label" ] <- 17


# build stratified training set
all.profit.0 <- subset(all.profit,label == 0 | label == 15)
nData.0      <- nrow(all.profit.0)
s0           <- sort(sample(1:nData.0,size=480000))
all.profit.0.sample <- all.profit.0[s0,]

all.profit.1 <- subset(all.profit,label == 1)
nData.1      <- nrow(all.profit.1)
s1           <- sort(sample(1:nData.1,size=40000))
all.profit.1.sample <- all.profit.1[s1,]

all.profit.2 <- subset(all.profit,label == 2)
nData.2      <- nrow(all.profit.2)
s2           <- sort(sample(1:nData.2,size=40000))
all.profit.2.sample <- all.profit.2[s2,]

all.profit.3 <- subset(all.profit,label == 3)
nData.3      <- nrow(all.profit.3)
s3           <- sort(sample(1:nData.3,size=40000))
all.profit.3.sample <- all.profit.3[s3,]

all.profit.4 <- subset(all.profit,label == 4)
nData.4      <- nrow(all.profit.4)
s4           <- sort(sample(1:nData.4,size=40000))
all.profit.4.sample <- all.profit.4[s4,]

all.profit.6 <- subset(all.profit,label == 6)
nData.6      <- nrow(all.profit.6)
s6           <- sort(sample(1:nData.6,size=40000))
all.profit.6.sample <- all.profit.6[s6,]

all.profit.7 <- subset(all.profit,label == 7)
nData.7      <- nrow(all.profit.7)
s7           <- sort(sample(1:nData.7,size=40000))
all.profit.7.sample <- all.profit.7[s7,]

all.profit.11 <- subset(all.profit,label == 11)
nData.11      <- nrow(all.profit.11)
s11           <- sort(sample(1:nData.11,size=40000))
all.profit.11.sample <- all.profit.11[s11,]

all.profit.12 <- subset(all.profit,label == 12)
nData.12      <- nrow(all.profit.12)
s12           <- sort(sample(1:nData.12,size=40000))
all.profit.12.sample <- all.profit.12[s12,]

all.profit.13 <- subset(all.profit,label == 13)
nData.13      <- nrow(all.profit.13)
s13           <- sort(sample(1:nData.13,size=40000))
all.profit.13.sample <- all.profit.13[s13,]

all.profit.14 <- subset(all.profit,label == 14)
nData.14      <- nrow(all.profit.14)
s14           <- sort(sample(1:nData.14,size=40000))
all.profit.14.sample <- all.profit.14[s14,]

all.profit.16 <- subset(all.profit,label == 16)
nData.16      <- nrow(all.profit.16)
s16           <- sort(sample(1:nData.16,size=40000))
all.profit.16.sample <- all.profit.16[s16,]

all.profit.17 <- subset(all.profit,label == 17)
nData.17      <- nrow(all.profit.17)
s17           <- sort(sample(1:nData.17,size=40000))
all.profit.17.sample <- all.profit.17[s17,]

full.sample <- rbind(all.profit.0.sample,
                     all.profit.1.sample,
                     all.profit.2.sample,
                     all.profit.3.sample,
                     all.profit.4.sample,
                     all.profit.6.sample,
                     all.profit.7.sample,
                     all.profit.11.sample,
                     all.profit.12.sample,
                     all.profit.13.sample,
                     all.profit.14.sample,
                     all.profit.16.sample,
                     all.profit.17.sample)

# flag samples in master dataset
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

write.table(x=training.sample[,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="lehedge_training.txt")

write.table(x=validation.sample[,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="lehedge_validation.txt")

# let the image generation happen!!
# this will generate 960K images, about 10GB when backward window is 10600 pixels

library(png)

spit_sample_images(backwardWindow,"img/", samplingIdx)
