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
                       str_pad(dt %% 1000,3,pad='0'),
                       sep='')
          
          hourdata <- data.frame(ts=dts,
                                 year=y,
                                 month=month+1,
                                 day=day,
                                 hour=hour,
                                 minute=dt %/% 60000,
                                 sec=(dt %/% 1000) %% 60,
                                 mil=dt%%1000,
                                 ask=readBin(alld[5:8,],what="integer",size=4,endian="big",n=numRec)/currency.precision,
                                 bid=readBin(alld[9:12,],what="integer",size=4,endian="big",n=numRec)/currency.precision,
                                 ask.vol=readBin(alld[13:16,],what="numeric",size=4,endian="big",n=numRec),
                                 bid.vol=readBin(alld[17:20,],what="numeric",size=4,endian="big",n=numRec))
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
