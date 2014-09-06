library(stringr)

createPkMs <- function(d) {
  d$rmin <- rank(d$V1,ties.method="min")
  d$milli <- str_pad(as.integer(row.names(d)) - d$rmin + 1, 3, pad="0") 
  options(digits.secs = 3)
  d$pk <- strptime(paste(d$V1,d$milli,sep="."),"%Y%m%d %H%M%OS")
  d[,c("pk","V2")]
}

createPkStr <- function(d) {
  d$rmin <- rank(d$V1,ties.method="min")
  d$milli <- str_pad(as.integer(row.names(d)) - d$rmin + 1, 3, pad="0") 
  options(digits.secs = 3)
  d$pk <- paste(d$V1,d$milli,sep=".")
  d[,c("pk","V2")]
}

load_from_binary <- function(pair,currency.precision) {
  
  ticks <- data.frame()
  options(digits.secs = 3)
  options(digits=13)
  
  for( y in 2014) {
    for( month in 0:7) {
      m <- str_pad(month,2,pad='0')
      monthdata <- data.frame()
      for(day in 1:31)  {
        daydata <- data.frame()
        d <- str_pad(day,2,pad='0')  
        for( hour in 0:23) {
          # increment month value for our own bookeeping (Dukascopy counts months of the year starting at zero)  
          h <- str_pad(hour,2,pad='0')
          realMonth <- str_pad(month+1,2,pad='0')
          dradix <- paste('./ticks/',pair,'_',y,realMonth,d,'_',h,sep='')
          if(!file.exists(dradix)) {
            next
          }
          print(dradix)
          
          fileSize <- file.info(dradix)$size
          data <- file(dradix,'rb')
          alld <- readBin(data,what=raw(),n=fileSize) 
          numRec <- fileSize/(4*5)
          dim(alld) <- c(4*5,numRec)
          
          dt=readBin(alld[1:4,],what="integer",size=4,endian="big",n=numRec)
          
          minute_  = dt %/% 60000
          seconds_ = (dt %/% 1000) %% 60
          mil_ = dt%%1000
          
          dts <- paste(y,
                       realMonth,
                       d,
                       ' ',
                       h,
                       ':',
                       str_pad(minute_,2,pad='0'),
                       ':',
                       str_pad(seconds_,2,pad='0'),
                       '.',
                       str_pad(mil_,3,pad='0'),
                       sep='')
          
          epoch <- unclass(as.POSIXct(strptime(dts,"%Y%m%d %H:%M:%OS")))
          ask=readBin(alld[5:8,],what="integer",size=4,endian="big",n=numRec)/currency.precision
          bid=readBin(alld[9:12,],what="integer",size=4,endian="big",n=numRec)/currency.precision
          spread=ask-bid
          
          hourdata <- data.frame(ts=dts,
                                 epoch=epoch,
                                 year=y,
                                 month=month+1,
                                 day=day,
                                 hour=hour,
                                 minute=minute_,
                                 sec=seconds_,
                                 mil=mil_,
                                 ask=ask,
                                 bid=bid,
                                 spread=spread,
                                 ask.vol=readBin(alld[13:16,],what="numeric",size=4,endian="big",n=numRec),
                                 bid.vol=readBin(alld[17:20,],what="numeric",size=4,endian="big",n=numRec),
                                 stringsAsFactors=FALSE)
          close(data)
          daydata <- rbind(daydata,hourdata)
        }
        monthdata <- rbind(monthdata,daydata)
      }
      ticks <- rbind(ticks,monthdata)
    }
  }
  return(ticks)
}

load_from_binary_light <- function(pair,currency.precision) {
  
  ticks <- data.frame()
  options(digits.secs = 3)
  options(digits=13)
  
  for( y in 2014) {
    for( month in 0:7) {
      m <- str_pad(month,2,pad='0')
      monthdata <- data.frame()
      for(day in 1:31)  {
        daydata <- data.frame()
        d <- str_pad(day,2,pad='0')  
        for( hour in 0:23) {
          # increment month value for our own bookeeping (Dukascopy counts months of the year starting at zero)  
          h <- str_pad(hour,2,pad='0')
          realMonth <- str_pad(month+1,2,pad='0')
          dradix <- paste('./ticks/',pair,'_',y,realMonth,d,'_',h,sep='')
          if(!file.exists(dradix)) {
            next
          }
          print(dradix)
          
          fileSize <- file.info(dradix)$size
          data <- file(dradix,'rb')
          alld <- readBin(data,what=raw(),n=fileSize) 
          numRec <- fileSize/(4*5)
          dim(alld) <- c(4*5,numRec)
          
          dt = readBin(alld[1:4,],what="integer",size=4,endian="big",n=numRec)
          
          dts <- paste(y,
                       realMonth,
                       d,
                       ' ',
                       h,
                       ':',
                       str_pad(dt %/% 60000,2,pad='0'),
                       ':',
                       str_pad((dt %/% 1000) %% 60,2,pad='0'),
                       '.',
                       str_pad(dt%%1000,3,pad='0'),
                       sep='')
          
          epoch <- unclass(as.POSIXct(strptime(dts,"%Y%m%d %H:%M:%OS")))
          
          ask=readBin(alld[5:8,],what="integer",size=4,endian="big",n=numRec)/currency.precision
          
          bid=readBin(alld[9:12,],what="integer",size=4,endian="big",n=numRec)/currency.precision
          
          spread=ask-bid
          
          hourdata <- data.frame(epoch=epoch,
                                 ask=ask,
                                 bid=bid,
                                 spread=spread,
                                 ask.vol=readBin(alld[13:16,],what="numeric",size=4,endian="big",n=numRec),
                                 bid.vol=readBin(alld[17:20,],what="numeric",size=4,endian="big",n=numRec),
                                 stringsAsFactors=FALSE)
          close(data)
          daydata <- rbind(daydata,hourdata)
        }
        monthdata <- rbind(monthdata,daydata)
      }
      ticks <- rbind(ticks,monthdata)
    }
  }
  return(ticks)
}


bestBuyForwardWindow <- function(currencyData, currency.precision) {
  
  nSamples <- 3600*24
  nRecords <- nrow(currencyData)
  maxForwardWindow <- 5000
  maxBackwardWindow <- 5000
  trainingRows <- sample((maxBackwardWindow+1):(nRecords-maxForwardWindow-1),nSamples)
  
  q95 <- NULL
  
  for( forwardWindow in seq(100,maxForwardWindow,100) ) {
    currency.s <- currencyData[trainingRows,]
    currency.f <- currencyData[trainingRows + forwardWindow,]
    buyProfit <- (currency.f$bid - currency.s$ask)*currency.precision
    q95[forwardWindow] <- quantile(buyProfit,probs=c(95)/100)
    if(q95[forwardWindow] >= 10) {
      break
    }
  }
  
  return(forwardWindow)
}

bestSellForwardWindow <- function(currencyData, currency.precision) {
  
  nSamples <- 3600*24
  nRecords <- nrow(currencyData)
  maxForwardWindow <- 5000
  maxBackwardWindow <- 5000
  trainingRows <- sample((maxBackwardWindow+1):(nRecords-maxForwardWindow-1),nSamples)
  
  q95 <- NULL
  
  for( forwardWindow in seq(100,maxForwardWindow,100) ) {
    currency.s <- currencyData[trainingRows,]
    currency.f <- currencyData[trainingRows + forwardWindow,]
    sellProfit <- (currency.f$ask - currency.s$bid)*currency.precision
    q95[forwardWindow] <- quantile(sellProfit,probs=c(95)/100)
    if(q95[forwardWindow] >= 10) {
      break
    }
  }
  
  return(forwardWindow)
}

build_training_set <- function(side="ask",currency.ext,referenceTimes,nSamples,backwardWindow) {
  
  # identify reference times in the target dataset
  currency.refTimesRows <- as.numeric(row.names(currency.ext[!is.na(currency.ext$training),]))
  
  currency.refTimesRowsEnd <- currency.refTimesRows + backwardWindow
  
  # to avoid transpose when scaling
  currency.training <- matrix(nrow=backwardWindow,ncol=nSamples)
  
  i <- 1
  for( i in 1:length(currency.refTimesRows)){ 
    startingRow <- currency.refTimesRows[i]
    print(startingRow)
    endRow <- currency.refTimesRowsEnd[i]
    rec <- currency.ext[startingRow:(endRow-1),side]
    noNAs <- !is.na(rec)
    s <- rec[noNAs]
    j <- 0
    while(length(s) < backwardWindow & (endRow+j<nrow(currency.ext))){
      rec <- c(s,currency.ext[endRow+j,side])
      noNAs <- !is.na(rec)
      s <- rec[noNAs]
      j <- j+1
    }
    currency.training[,i] <- s
    i <- i+1
  }
  return(currency.training)  
}


build_training_set_disk <- function(side="ask",currency.ext.str,referenceTimes,nSamples,backwardWindow) {
  
  # identify reference times in the target dataset
  if(side=="ask"){
    currency.ext <- get(paste(currency.ext.str,".buy.ext",sep=""))
  }else if(side=="bid") {
    currency.ext <- get(paste(currency.ext.str,".sell.ext",sep=""))
  }
  currency.refTimesRows <- as.numeric(row.names(currency.ext[!is.na(currency.ext$training),]))
  
  currency.refTimesRowsEnd <- currency.refTimesRows + backwardWindow - 1
  
  # to avoid transpose when scaling
  currency.firstQuote <- matrix(nrow=2,ncol=nSamples)
  currency.training <- matrix(nrow=1000,ncol=backwardWindow)
  
  for( i in 1:length(currency.refTimesRows)) { 
    
    startingRow <- currency.refTimesRows[i]
    print(startingRow)
    endRow <- currency.refTimesRowsEnd[i]
    rates <- currency.ext[startingRow:endRow,side]
    rates.nona <- rates[!is.na(rates)]
    j <- 1
    while( length(rates.nona) < backwardWindow & ((endRow+j)<nrow(currency.ext))){
      rates <- c(rates.nona, currency.ext[endRow+j,side])
      rates.nona <- rates[!is.na(rates)]
      j <- j+1
    }
    
    # TODO write rec to disk, write last quote of frame to in-mem matrix
    currency.firstQuote[1,i] <- currency.ext[endRow+j-1,"bid"]
    currency.firstQuote[2,i] <- currency.ext[endRow+j-1,"ask"]
    # scale between 0 and 1 like this : 
    # X_std = (X - X.min(axis=0)) / (X.max(axis=0) - X.min(axis=0))
    # X_scaled = X_std / (max - min) + min
    X_std <- (rates.nona - min(rates.nona)) / (max(rates.nona)-min(rates.nona))
    #print(length(X_std))
    #X_scaled <- X_std / (max(rates.nona)-min(rates.nona)) + min(rates.nona)
    currency.training[(i-1)%%1000+1,] <- X_std
    
    if( i%%1000 == 0 ) {
      write.table(currency.training,file=paste(currency.ext.str,".ask.training",sep=""),append=TRUE)
    }

  }
  return(currency.firstQuote)  
}

merge_ref_times <- function(currency.raw,referenceTimes){
  
  # this magically interleaves the target currency timestamps
  # and the reference times while flagging those
  #for( currencyData in c(EURUSD.raw,EURJPY.raw,USDJPY.raw)) { 
  
  currency.ext <- merge(currency.raw,referenceTimes,by.x="epoch",by.y="epoch",all.x=TRUE,all.y=TRUE)
  return(currency.ext)
  
}

build_first_quote <- function(currency.ext,backwardWindow) {
  
  # identify reference times in the target dataset
  currency.refTimesRows <- as.numeric(row.names(currency.ext[!is.na(currency.ext$training),]))
  
  currency.refTimesRowsEnd <- currency.refTimesRows + backwardWindow
  
  # to avoid transpose when scaling
  currency.firstQuote <- matrix(nrow=2,ncol=nSamples)
  
  i <- 1
  for( i in 1:length(currency.refTimesRows)){ 
    startingRow <- currency.refTimesRows[i]
    print(startingRow)
    endRow <- currency.refTimesRowsEnd[i]
    asks <- currency.ext[startingRow:(endRow-1),"ask"]
    asks.nona <- asks[!is.na(asks)]
    j <- 0
    while( length(asks.nona) < backwardWindow & (endRow+j<nrow(currency.ext))){
      asks <- c(asks.nona, currency.ext[endRow+j,"ask"])
      asks.nona <- asks[!is.na(asks)]
      j <- j+1
    }
    currency.firstQuote[1,i] <- currency.ext[endRow+j,"bid"]
    currency.firstQuote[2,i] <- currency.ext[endRow+j,"ask"]    
    i <- i+1
  }
  return(currency.firstQuote)  
}



build_last_quote <- function(currency.ext,backwardWindow,forwardWindow) {
  
  # identify reference times in the target dataset
  currency.refTimesRows <- as.numeric(row.names(currency.ext[!is.na(currency.ext$training),]))
  
  currency.refTimesRowsEnd <- currency.refTimesRows + backwardWindow + forwardWindow - 1
  
  # to avoid transpose when scaling
  currency.lastQuote <- matrix(nrow=2,ncol=nSamples)
  
  #i <- 1
  for( i in 1:length(currency.refTimesRows)){ 
    startingRow <- currency.refTimesRows[i]
    print(startingRow)
    endRow <- currency.refTimesRowsEnd[i]
    asks <- currency.ext[startingRow:endRow,"ask"]
    asks.nona <- asks[!is.na(asks)]
    j <- 1
    while( length(asks.nona) < (backwardWindow+forwardWindow) & ((endRow+j)<nrow(currency.ext))){
      asks <- c(asks.nona, currency.ext[endRow+j,"ask"])
      asks.nona <- asks[!is.na(asks)]
      j <- j+1
    }
    currency.lastQuote[1,i] <- currency.ext[endRow+j-1,"bid"]
    currency.lastQuote[2,i] <- currency.ext[endRow+j-1,"ask"]    
    #i <- i+1
  }
  return(currency.lastQuote)  
}

# v2
closeRates <- function(currency,forwardWindow,sampledf) {
  
  ask_col <- paste(currency,".ask",sep="")
  bid_col <- paste(currency,".bid",sep="")
  
  a <- all.rates[,ask_col]
  b <- all.rates[,bid_col]
  
  openPosition <- as.numeric(row.names(sampledf[sampledf$s == 1,,drop=FALSE]))
  closePosition <- openPosition + forwardWindow - 1
  
  print(closePosition)
  
  # to avoid transpose when scaling
  # [1,] -> open.ask
  # [2,] -> open.bid
  # [3,] -> close.ask
  # [4,] -> close.bid
  
  closeRates <- matrix(nrow=2,ncol=nrow(sampledf))
  
  for( i in 1:length(openPosition)) { 
    
    startingRow <- openPosition[i]
    print(startingRow)
    endRow <- closePosition[i]
    asks <- a[startingRow:endRow]
    asks.nona <- asks[!is.na(asks)]
    
    j <- 1
    while( length(asks.nona) < (forwardWindow) & ((endRow+j)<nrow(all.rates))){
      if(!is.na(a[endRow+j])) {
        asks.nona <- c(asks.nona, a[endRow+j])        
      } 
      j <- j+1
    }
    
    closeRates[1,i] <- b[endRow+j-1]
    closeRates[2,i] <- a[endRow+j-1]    
  }
  return(closeRates)  
}

# v3
ask.closeRates <- function(currency,forwardWindow,sampledf) {
  
  ask_col <- paste(currency,".ask",sep="")
#  bid_col <- paste(currency,".bid",sep="")
  
  a <- all.rates[,ask_col]
 # b <- all.rates[,bid_col]
  
  openPosition <- as.numeric(row.names(sampledf[sampledf$s == 1,,drop=FALSE]))
  closePosition <- openPosition + forwardWindow - 1
  
  #print(closePosition)
  
  # to avoid transpose when scaling
  # [1,] -> open.ask
  # [2,] -> open.bid
  # [3,] -> close.ask
  # [4,] -> close.bid
  
  closeRates <- matrix(nrow=2,ncol=nrow(sampledf))

  a.clean <- !is.na(a[openPosition[1]:length(a)])
  a.nona <- data.frame(ask=a[a.clean])
  row.names(a.nona) <- openPosition
  print(a.nona)
  
  for( i in 1:length(openPosition)) { 
    
    startingRow <- openPosition[i]
    print(startingRow)
    endRow <- closePosition[i]
    asks <- a[startingRow:endRow]
    asks.nona <- asks[!is.na(asks)]
    
    j <- 1
    while( length(asks.nona) < (forwardWindow) & ((endRow+j)<nrow(all.rates))){
      if(!is.na(a[endRow+j])) {
        asks.nona <- c(asks.nona, a[endRow+j])        
      } 
      j <- j+1
    }
    
    closeRates[1,i] <- b[endRow+j-1]
    closeRates[2,i] <- a[endRow+j-1]    
  }
  return(closeRates)  
}



# deprecated in favor writeSinglePng
write_pngs <- function(prefix,ids,red,green,blue) {
  library(stringr)  
  library(png)
  
  nSamples <- length(ids) #dim(red)[2]
  pixels <- dim(red)[1]
  
  library(rPython)
  python.load('goldendims.py')
  python.exec(paste("mygd = GoldenRectangle(",pixels,").dimensions()",.sep=''))
  imageSize <- python.get("mygd")

  fileConn<-file(paste(prefix,"image_size",sep="/"))
  writeLines(paste(imageSize[1],imageSize[2]), fileConn)
  close(fileConn)  
  
  for( i in 1:nSamples) {
    img      <- array(data=NA,dim=c(imageSize[1],imageSize[2],3))
    img[,,1] <- matrix(red[,ids[i]],ncol=imageSize[2],byrow=TRUE)
    img[,,2] <- matrix(green[,ids[i]],ncol=imageSize[2],byrow=TRUE)
    img[,,3] <- matrix(blue[,ids[i]],ncol=imageSize[2],byrow=TRUE)
    writePNG(image=img,target=paste(prefix,str_pad(ids[i],6,pad='0'),'.png',sep=''))
  }
}

# for each currency we need to initialize the lookback buffer
# so we need enough ticks to fill and this helps find 
# the minimum end point we can use for all three currencies
findMinRow <- function(all.rates, currency, backwardWindow) {
  col <- paste(currency,".ask",sep="")
  grab <- all.rates[1:backwardWindow,col]
  grab <- grab[!is.na(grab)]
  i <- 1
  while( length(grab) < backwardWindow ) {
    grab <- all.rates[1:(backwardWindow+i),col]
    grab <- grab[!is.na(grab)]
    i <- i+1
  }
  return(i+backwardWindow-1) 
}

# for each currency we need to initialize the lookback buffer
# so we need enough ticks to fill and this helps find 
# the minimum end point we can use for all three currencies
findMaxRow <- function(d, currency, forwardWindow) {
  end <- nrow(d)
  col <- paste(currency,".ask",sep="")
  grab <- d[(end-forwardWindow-1):end,col]
  grab <- grab[!is.na(grab)]
  i <- 1
  while( length(grab) < forwardWindow ) {
    grab <- d[(end-forwardWindow-1-i):end,col]
    grab <- grab[!is.na(grab)]
    i <- i+1
  }
  return(i+forwardWindow-1) 
}

build_training_set_images <- function(side="ask",backwardWindow,prefix,samplingIndx) {
  
  head <- samplingIdx[1]
  
  red_col <- paste("EURUSD.",side,sep="")
  green_col <- paste("EURJPY.",side,sep="")
  blue_col <- paste("USDJPY.",side,sep="")
  
  red   <- all.rates[,red_col]
  green <- all.rates[,green_col]
  blue  <- all.rates[,blue_col]
  
  library(rPython)
  python.load('goldendims.py')
  python.exec(paste("mygd = GoldenRectangle(",backwardWindow,").dimensions()",.sep=''))
  imageSize <- python.get("mygd")
  
  fileConn<-file(paste(prefix,"image_size",sep="/"))
  writeLines(paste(imageSize[1],imageSize[2]), fileConn)
  close(fileConn)  
  
  red.openPosition <- vector()
  green.openPosition <- vector()
  blue.openPosition <- vector()
  
  buf <- matrix(ncol=3, nrow=backwardWindow)
  buf[,1] <- grab_last(red, head, backwardWindow)
  buf[,2] <- grab_last(green, head, backwardWindow)
  buf[,3] <- grab_last(blue, head, backwardWindow)
  
  red.openPosition[samplingIdx[1]]   <- buf[backwardWindow,1]
  green.openPosition[samplingIdx[1]] <- buf[backwardWindow,2]
  blue.openPosition[samplingIdx[1]]  <- buf[backwardWindow,3]
  
  writeSinglePng(prefix, scale(buf), head, imageSize)
    
  previous_head <- head
  
  for( head in samplingIdx[-1] ) {
    
    skip <- head-previous_head 
    previous_head <- head
    print(paste("head=",head,"skipped=",skip))
    
    red_chunk <- red[(head-skip+1):head]
    green_chunk <- green[(head-skip+1):head]
    blue_chunk <- blue[(head-skip+1):head]
    
    red_chunk <- red_chunk[!is.na(red_chunk)]
    green_chunk <- green_chunk[!is.na(green_chunk)]
    blue_chunk <- blue_chunk[!is.na(blue_chunk)]
    
    if( length(red_chunk) > 0 ){
      rcl <- length(red_chunk)
      buf[,1] <- c(buf[-(1:rcl),1],red_chunk)
      red.openPosition[head] <- red_chunk[rcl]
    } 
    
    if( length(green_chunk) > 0 ){
      gcl <- length(green_chunk)
      buf[,2] <- c(buf[-(1:gcl),2],green_chunk)
      green.openPosition[head] <- green_chunk[gcl]
    } 
    
    if( length(blue_chunk) > 0 ){
      bcl <- length(blue_chunk)
      buf[,3] <- c(buf[-(1:bcl),3],blue_chunk)
      blue.openPosition[head] <- blue_chunk[bcl]
    }
    
    writeSinglePng(prefix,scale(buf),head,imageSize)
  }
  
  return(list(red.openPosition,green.openPosition,blue.openPosition))

}

writeSinglePng <- function(prefix,buf,head,imageSize) {
  
  img      <- array(data=NA,dim=c(imageSize[1],imageSize[2],3))
  
  for( i in 1:3) {
    buf[,i] <- (buf[,i] - min(buf[,i])) / (max(buf[,i])-min(buf[,i]))
    img[,,i] <- matrix(buf[,i],ncol=imageSize[2],byrow=TRUE)
  }
  
  library(stringr)  
  library(png)
  
  writePNG(image=img,target=paste(prefix,str_pad(head,13,pad='0'),'.png',sep=''))
  
}

