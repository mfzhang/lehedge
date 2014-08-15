library(stringr)

eurjpy.dukascopy <- data.frame()
currency.precision <- 1000
options(digits.secs = 3)

for( month in 0:7) {
  for(day in 1:31)  {
    daydata <- data.frame()
    for( hour in 0:23) {
      # increment month value for our own bookeeping (Dukascopy counts months of the year starting at zero)
      m <- str_pad(month,2,pad='0')
      d <- str_pad(day,2,pad='0')
      h <- str_pad(hour,2,pad='0')
      dradix <- paste('./dukascopy/EURJPY_2014',str_pad(month+1,2,pad='0'),d,'_',h,sep='')
      if(!file.exists(dradix)) {
        print(paste("file",dradix,"doesn't exist"))
        next
      }
      print(dradix)
      data <- file(dradix,'rb')
      allmilli <- readBin(data,integer(),endian="big")
      
      hourdata <- data.frame()
      
      while( allmilli >= 0 & allmilli < 3600000) {
        allsecs <- allmilli %/% 1000
        minutes <- allsecs %/% 60
        secs <- allsecs - minutes*60
        millisecs <- allmilli - allsecs*1000
        # dt 
        dt <- strptime(paste('2014',
                             str_pad(month+1,2,pad='0'),
                             d,
                             ' ',
                             h,
                             ':',
                             minutes,
                             ':',
                             secs,
                             '.',
                             millisecs,
                             sep=''), "%Y%m%d %H:%M:%OS")
        ask <- readBin(data,integer(),endian="big")/currency.precision
        bid <- readBin(data,integer(),endian="big")/currency.precision
        ask.vol <- readBin(data,double(),size=4,endian="big")
        bid.vol <- readBin(data,double(),size=4,endian="big")
        hourdata <- rbind(hourdata,data.frame(dt,ask,bid,ask.vol,bid.vol))
        #print(hourdata)
        allmilli <- readBin(data,integer(),endian="big")
        i <- as.integer(i+1)
        if( is.na(allmilli[1]) ) {break}
      }
      close(data)
      daydata <- rbind(daydata,hourdata)
    }
    eurjpy.dukascopy <- rbind(eurjpy.dukascopy,daydata)
  }
}
