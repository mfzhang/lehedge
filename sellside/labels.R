
individual.profit.target <- -10

totalAvgSpread <- mean(EURJPY.raw$spread*100) + mean(EURUSD.raw$spread*10000) + mean(USDJPY.raw$spread*100)

u <- individual.profit.target - totalAvgSpread

sell.profit[   sell.profit$eurusd > u  &
               sell.profit$eurjpy > u  &
               sell.profit$usdjpy > u,   "label" ] <- 0 

sell.profit[   sell.profit$eurusd <= u  &
               sell.profit$eurjpy > u  &
               sell.profit$usdjpy > u,   "label" ] <- 1 

sell.profit[   sell.profit$eurusd > u  &
               sell.profit$eurjpy <= u  &
               sell.profit$usdjpy > u,   "label" ] <- 2

sell.profit[   sell.profit$eurusd > u  &
               sell.profit$eurjpy > u  &
               sell.profit$usdjpy <= u,   "label" ] <- 3 

sell.profit[   sell.profit$eurusd <= u  &
               sell.profit$eurjpy <= u  &
               sell.profit$usdjpy > u,   "label" ] <- 4 

sell.profit[   sell.profit$eurusd <= u  &
               sell.profit$eurjpy > u  &
               sell.profit$usdjpy <= u,   "label" ] <- 5 

sell.profit[   sell.profit$eurusd > u  &
               sell.profit$eurjpy <= u  &
               sell.profit$usdjpy <= u,   "label" ] <- 6

sell.profit[  sell.profit$eurusd <= u  &
                sell.profit$eurjpy <= u  &
                sell.profit$usdjpy <= u,   "label" ] <- 7 

sell.profit.counts <- table(sell.profit$label)

sum(sell.profit.counts[2:8])

sell.profit$filename <- paste("training-",row.names(sell.profit),".png",sep="")

write.table(x=sell.profit[,c("filename","label")],
            quote=FALSE,
            row.names=FALSE,
            col.names=FALSE,
            file="sellside/lehedge_sell_training.txt")

totalProfit <- sum(
  sum(sell.profit[  sell.profit$eurusd <= u  &
                      sell.profit$eurjpy > u  &
                      sell.profit$usdjpy > u,   "eurusd" ])
  ,
  sum(sell.profit[  sell.profit$eurusd > u  &
                      sell.profit$eurjpy <= u  &
                      sell.profit$usdjpy > u,   "eurjpy" ])
  ,
  sum(sell.profit[  sell.profit$eurusd > u  &
                      sell.profit$eurjpy > u  &
                      sell.profit$usdjpy <= u,   "usdjpy" ])
  ,
  sum(sell.profit[  sell.profit$eurusd <= u  &
                      sell.profit$eurjpy <= u  &
                      sell.profit$usdjpy > u,   c("eurusd","eurjpy") ])
  ,
  sum(sell.profit[  sell.profit$eurusd <= u  &
                      sell.profit$eurjpy > u  &
                      sell.profit$usdjpy <= u,  c("eurusd","usdjpy") ])
  ,
  sum(sell.profit[  sell.profit$eurusd > u  &
                      sell.profit$eurjpy <= u  &
                      sell.profit$usdjpy <= u,  c("eurjpy","usdjpy") ])
  ,
  sum(sell.profit[  sell.profit$eurusd <= u  &
                      sell.profit$eurjpy <= u  &
                      sell.profit$usdjpy <= u,   c("eurusd","eurjpy","usdjpy") ]))



