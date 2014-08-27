
individual.profit.target <- 10

totalAvgSpread <- mean(EURJPY.raw$spread*100) + mean(EURUSD.raw$spread*10000) + mean(USDJPY.raw$spread*100)

u <- individual.profit.target + totalAvgSpread

buy.profit[  buy.profit$eurusd < u  &
               buy.profit$eurjpy < u  &
               buy.profit$usdjpy < u,   "label" ] <- 0 

buy.profit[  buy.profit$eurusd >= u  &
               buy.profit$eurjpy < u  &
               buy.profit$usdjpy < u,   "label" ] <- 1 

buy.profit[  buy.profit$eurusd < u  &
               buy.profit$eurjpy >= u  &
               buy.profit$usdjpy < u,   "label" ] <- 2

buy.profit[  buy.profit$eurusd < u  &
               buy.profit$eurjpy < u  &
               buy.profit$usdjpy >= u,   "label" ] <- 3 

buy.profit[  buy.profit$eurusd >= u  &
               buy.profit$eurjpy >= u  &
               buy.profit$usdjpy < u,   "label" ] <- 4 

buy.profit[  buy.profit$eurusd >= u  &
               buy.profit$eurjpy < u  &
               buy.profit$usdjpy >= u,   "label" ] <- 5 

buy.profit[  buy.profit$eurusd < u  &
               buy.profit$eurjpy >= u  &
               buy.profit$usdjpy >= u,   "label" ] <- 6

buy.profit[  buy.profit$eurusd >= u  &
               buy.profit$eurjpy >= u  &
               buy.profit$usdjpy >= u,   "label" ] <- 7 

buy.profit.counts <- table(buy.profit$label)

sum(buy.profit.counts[2:8])

buy.profit$filename <- paste("training-",row.names(buy.profit),".png",sep="")

write.table(x=buy.profit[-split_data,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="buyside/lehedge_buy_training.txt")

write.table(x=buy.profit[split_data,c("filename","label")],
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



