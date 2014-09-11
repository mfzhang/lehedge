library(stringr)

all.profit <- all.rates

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

label.counts <- table(all.profit$label)

profit.sum <- vector()
profit.sum[1] <- sum(subset(all.profit,label==1,select=EURUSD.profit))
profit.sum[2] <- sum(subset(all.profit,label==2,select=EURJPY.profit))
profit.sum[3] <- sum(subset(all.profit,label==3,select=USDJPY.profit))
profit.sum[4] <- sum(subset(all.profit,label==4,select=c("EURUSD.profit","EURJPY.profit")))
profit.sum[6] <- sum(subset(all.profit,label==6,select=c("EURJPY.profit","USDJPY.profit")))
profit.sum[7] <- sum(subset(all.profit,label==7,select=c("EURUSD.profit","EURJPY.profit","USDJPY.profit")))

profit.sum[c(1,2,3,4,6,7)]/label.counts[2:7]

#1        2        3        4        6        7 
#13.74093 14.70803 12.93258 39.62058 36.35264 75.73316

print(buy.profit.sum)

sum(buy.profit.counts[2:7])

# build stratified training set

row.names(all.profit[ all.profit$label == 1,])

training <- c( 
  row.names(all.profit[ all.profit$label %in% c(1,2,3,4,6)]),
  sample(row.names(all.profit[ all.profit$label %in% c(0,7)]),size=0.01*,
)


paddedNames <- str_pad(row.names(buy.profit), 6, pad="0")
buy.profit$filename <- paste(paddedNames,".png",sep="")

write.table(x=buy.profit[-buy.validation,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="buyside/lehedge_buy_training.txt")

write.table(x=buy.profit[buy.validation,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="buyside/lehedge_buy_val.txt")


totalProfit <- sum(
  sum(buy.profit[  buy.profit$eurusd >= u  &
                     buy.profit$eurjpy < u  &
                     buy.profit$usdjpy < u,   "eurusd" ])
  ,
  sum(buy.profit[  buy.profit$eurusd < u  &
                     buy.profit$eurjpy >= u  &
                     buy.profit$usdjpy < u,   "eurjpy" ])
  ,
  sum(buy.profit[  buy.profit$eurusd < u  &
                     buy.profit$eurjpy < u  &
                     buy.profit$usdjpy >= u,   "usdjpy" ])
  ,
  sum(buy.profit[  buy.profit$eurusd >= u  &
                     buy.profit$eurjpy >= u  &
                     buy.profit$usdjpy < u,   c("eurusd","eurjpy") ])
  ,
  sum(buy.profit[  buy.profit$eurusd >= u  &
                     buy.profit$eurjpy < u  &
                     buy.profit$usdjpy >= u,  c("eurusd","usdjpy") ])
  ,
  sum(buy.profit[  buy.profit$eurusd < u  &
                     buy.profit$eurjpy >= u  &
                     buy.profit$usdjpy >= u,  c("eurjpy","usdjpy") ])
  ,
  sum(buy.profit[  buy.profit$eurusd >= u  &
                     buy.profit$eurjpy >= u  &
                     buy.profit$usdjpy >= u,   c("eurusd","eurjpy","usdjpy") ]))



