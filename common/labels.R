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

nSample <- nrow(full.sample)
# create permutation of indices
shuffler <- sample(1:nSample,size=nSample)
# shuffle labels
full.sample.shuffled <- full.sample[shuffler,] 

validation.idx <- sort(sample(1:nSample,size=0.1*nSample))
validation.sample <- full.sample.shuffled[validation.idx,]
training.sample <- full.sample.shuffled[-validation.idx,]

training.sample[,"filename"] <- paste(str_pad(row.names(training.sample), 8, pad="0"),".png",sep="")
validation.sample[,"filename"] <- paste(str_pad(row.names(validation.sample), 8, pad="0"),".png",sep="")

write.table(x=training.sample[,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="buyside/lehedge_buy_training.txt")

write.table(x=validation.sample[,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="buyside/lehedge_buy_val.txt")


# flag samples in master dataset
all.profit[row.names(full.sample),"sample"] <- 1

