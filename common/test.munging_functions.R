library(stringr)

test.load_from_binary_light <- function(pair,currency.precision) {
  
  ticks <- data.frame()
  options(digits.secs = 3)
  options(digits=13)
  
  for( y in 2014) {
    for( month in 0:0) {
      m <- str_pad(month,2,pad='0')
      monthdata <- data.frame()
      for(day in 1:3)  {
        daydata <- data.frame()
        d <- str_pad(day,2,pad='0')  
        for( hour in 0:0) {
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
          str(dt)
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
          str(dts)
          epoch <- unclass(as.POSIXct(strptime(dts,"%Y%m%d %H:%M:%OS")))
          str(epoch)
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

some <- test.load_from_binary_light('EURUSD',100000)

grab_last <- function(v, head, count) {
  grab <- v[(head-count+1):head]
  grab <- grab[!is.na(grab)]
  i <- 1
  while( length(grab) < count ) {
    grab <- v[(head-count-i):head]
    grab <- grab[!is.na(grab)]
    i <- i+1
  }
  return(grab)   
}

process_last <- function(chunk, head, count) {
  #grab <- v[(head-count+1):head]
  chunk <- chunk[!is.na(chunk)]
  i <- 1
  while( length(grab) < count ) {
    grab <- v[(head-count-i):head]
    grab <- grab[!is.na(grab)]
    i <- i+1
  }
  return(grab)   
}

previous_head <- 5
skip <- 5
head <- 10
side <- "ask"
red_chunk <- all.rates[(head-skip):head,paste("EURUSD.",side,sep="")]

# init phase
# ''''''''''
# given
window <- 6
# and
v <- c(3,2,1,0,NA,NA,1,NA,2,3,NA,2,1,NA,0,NA,NA,NA,1,NA) # length 20
# and 
head <- 9
# and
w <-v[1:head]
w.nona <- w[!is.na(w)] 
# then 
w.nona == c(3,2,1,0,1,2)


# next step
#''''''''''
# given
window <- 6
# and
v <- c(3,2,1,0,NA,NA,1,NA,2,3,NA,2,1,NA,0,NA,NA,NA,1,NA) # length 20
# and
head <- 14
# and
skip <- 5
# and
w <- c(3,2,1,0,1,2)
# and
skipped <- v[(head-skip+1):head]
skipped.nona <- skipped[!is.na(skipped)]
if(length(skipped.nona) > 0){
  w_should <- c(w[-(1:length(skipped.nona))], skipped.nona)
} else {
  w_should <- w
}
# then 
w_should == c(0,1,2,3,2,1)








