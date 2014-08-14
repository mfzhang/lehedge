library(stringr)

#eurusd <- data.frame()
currency.precision <- 100000

for( month in 3:3) {
  for(day in 7:11)  {
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
      download.file(uri,destfile=dest,extra="-H 'Origin: http://freeserv.dukascopy.com' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://freeserv.dukascopy.com/2.0/?path=historical_data_feed/index&width=100%25&height=600' -H 'Connection: keep-alive'",method='curl')      
      system(paste('./dukascopy/lloyd-easylzma-29a7d54/build/easylzma-0.0.7/bin/unelzma',dest))

      data <- file(dradix,'rb')
      allmilli <- readBin(data,integer(),endian="big")
      options(digits.secs = 3)
      
      while( allmilli >= 0 & allmilli < 3600000) {
        allsecs <- allmilli %/% 1000
        minutes <- allsecs %/% 60
        secs <- allsecs - minutes*60
        millisecs <- allmilli - allsecs*1000
        dt <- strptime(paste('2014',str_pad(month+1,2,pad='0'),d,' ',h,':',minutes,':',secs,'.',millisecs,sep=''), "%Y%m%d %H:%M:%OS")
        #print(dt)
        ask <- readBin(data,integer(),endian="big")/currency.precision
        bid <- readBin(data,integer(),endian="big")/currency.precision
        ask.vol <- readBin(data,double(),size=4,endian="big")
        bid.vol <- readBin(data,double(),size=4,endian="big")
        eurusd <- rbind(eurusd, data.frame(dt,ask,bid,ask.vol,bid.vol))
        allmilli <- readBin(data,integer(),endian="big")
        if( is.na(allmilli[1]) ) {break}
      }
      close(data)
    }
  }
}
