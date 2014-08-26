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
          dradix <- paste('./dukascopy/',pair,'_',y,realMonth,d,'_',h,sep='')
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
          dradix <- paste('./dukascopy/',pair,'_',y,realMonth,d,'_',h,sep='')
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
  
  i <- 1
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
    i <- i+1
  }
  return(currency.lastQuote)  
}

write_pngs <- function(red,green,blue) {
  nSamples <- dim(red)[2]
  for( i in 1:nSamples) {
    img      <- array(data=NA,dim=c(75,40,3))
    img[,,1] <- matrix(red[,i],ncol=40,byrow=TRUE)
    img[,,2] <- matrix(green[,i],ncol=40,byrow=TRUE)
    img[,,3] <- matrix(blue[,i],ncol=40,byrow=TRUE)
    writePNG(image=img,target=paste('img/training-',i,'.png',sep=''))
  }
}




