currencyData <- EURUSD.ticks
nSamples <- 3600*24
nRecords <- nrow(currencyData)
maxForwardWindow <- 5000
maxBackwardWindow <- 5000
maxBestBuyForwardWindow <- 1500
trainingRows <- sample((maxBackwardWindow+1):(nRecords-maxForwardWindow-1),nSamples)
trainingStartPoints <- currencyData[trainingRows,]
options(digits.secs = 3)
options(digits = 13)
referenceTimes <- sort(trainingStartPoints$epoch)
rt <- data.frame(epoch=referenceTimes,training=rep(1,length(referenceTimes)))
EURJPY.ext <- merge(EURJPY.ticks,rt,by.x="epoch",by.y="epoch",all.x=TRUE,all.y=TRUE)
rn <- as.numeric(row.names(EURJPY.ext[!is.na(EURJPY.ext$training),]))# & is.na(EURJPY.ext$ask)
rnPlusOne <- rn+1
rn3000 <- rn + 2*maxBestBuyForwardWindow
trainingData <- matrix(nrow=nSamples,ncol=2*maxBestBuyForwardWindow)
i <- 1
for( i in 1:length(rn)){ 
  print(rn[i])
  startingRow <- rn[i]
  endRow <- rn3000[i]
  rec <- EURJPY.ext[startingRow:(endRow-1),"ask"]
  noNAs <- !is.na(rec)
  s <- rec[noNAs]
  j <- 0
  while(length(s) < 2*maxBestBuyForwardWindow){
    rec <- c(s,EURJPY.ext[endRow+j,"ask"])
    noNAs <- !is.na(rec)
    s <- rec[noNAs]
    j <- j+1
  }
  trainingData[i,] <- s
  i <- i+1
}

