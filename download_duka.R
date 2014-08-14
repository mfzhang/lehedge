library(stringr)
library(data.table)

#eurusd <- data.frame()
currency.precision <- 100000
options(digits.secs = 3)

for( month in 4:4) {
  for(day in 1:31)  {
    daydata <- data.frame()
    for( hour in 0:23) {
      # increment month value for our own bookeeping (Dukascopy counts months of the year starting at zero)
      m <- str_pad(month,2,pad='0')
      d <- str_pad(day,2,pad='0')
      h <- str_pad(hour,2,pad='0')
      uri <- paste('http://www.dukascopy.com/datafeed/EURUSD/2014/',
                        m, '/',
                        d, '/',
                        h,
                        'h_ticks.bi5',
                        sep=''
                        )
      dradix <- paste('./dukascopy/EURUSD_2014',str_pad(month+1,2,pad='0'),d,'_',h,sep='')
      dest <- paste(dradix,'.lzma',sep='')
      print(uri)
      try(download.file(uri,destfile=dest,extra="-H 'Origin: http://freeserv.dukascopy.com' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://freeserv.dukascopy.com/2.0/?path=historical_data_feed/index&width=100%25&height=600' -H 'Connection: keep-alive'",method='curl'))
      if(file.exists(dest)) {
        #Sys.sleep(2)
        try(system(paste('./easylzma/build/easylzma-0.0.8/bin/unelzma',dest)))
        if(!file.exists(dradix)){
          print('no file')
          next
        }
      } else {
        next
      }
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
    eurusd <- rbind(eurusd,daydata)
  }
}
