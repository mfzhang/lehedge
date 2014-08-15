library(stringr)

eurusd.dukascopy <- data.frame()
currency.precision <- 100000
options(digits.secs = 3)

for( month in 0:7) {
  m <- str_pad(month,2,pad='0')
  for(day in 1:31)  {
    daydata <- data.frame()
    d <- str_pad(day,2,pad='0')  
    for( hour in 0:23) {
      # increment month value for our own bookeeping (Dukascopy counts months of the year starting at zero)  
      h <- str_pad(hour,2,pad='0')
      realMonth <- str_pad(month+1,2,pad='0')
      dradix <- paste('./dukascopy/EURUSD_2014',realMonth,d,'_',h,sep='')
      if(!file.exists(dradix)) {
        next
      }
      print(dradix)
      data <- file(dradix,'rb')
      firstThreeInts <-  readBin(data,integer(),endian="big",n=3)
      allmilli <- firstThreeInts[1]
      hourdata <- data.frame()
      
      while( allmilli >= 0 & allmilli < 3600000) {
        #allsecs <- allmilli %/% 1000
        #minutes <- allsecs %/% 60
        #secs <- allsecs - minutes*60
        #millisecs <- allmilli - allsecs*1000
        # dt 
        dt <- strptime(paste('2014',
                             realMonth,
                             d,
                             ' ',
                             h,
                             ':',
                             allmilli %/% 60000, #minutes,
                             ':',
                             (allmilli %/% 1000) %% 60, #secs,
                             '.',
                             allmilli %% 1000,#millisecs,
                             sep=''), "%Y%m%d %H:%M:%OS")
        #price <- readBin(data,integer(),endian="big",n=2)/currency.precision
        #print(price)
        #bid <- readBin(data,integer(),endian="big")/currency.precision
        volume <- readBin(data,double(),size=4,n=2,endian="big")
        #print(volume)
        #bid.vol <- readBin(data,double(),size=4,endian="big")
        #hourdata <- rbind(hourdata,data.frame(dt,ask,bid,ask.vol,bid.vol))
        #hourdata <- rbind(hourdata,data.frame(dt,price[1],price[2],volume[1],volume[2]))
        #print(firstThreeInts)
        hourdata <- rbind(hourdata,data.frame(dt,firstThreeInts[2]/currency.precision,firstThreeInts[3]/currency.precision,volume[1],volume[2]))
        
        #print(hourdata)
        firstThreeInts <-  readBin(data,integer(),endian="big",n=3)
        allmilli <- firstThreeInts[1]
        #allmilli <- readBin(data,integer(),endian="big")
        if( is.na(allmilli) ) {break}
      }
      close(data)
      daydata <- rbind(daydata,hourdata)
    }
    eurusd.dukascopy <- rbind(eurusd.dukascopy,daydata)
  }
}
