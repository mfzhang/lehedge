library(stringr)

options(digits.secs = 3)

for( month in 0:0) {
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
      dradix <- paste('ticks/EURUSD_2014',str_pad(month+1,2,pad='0'),d,'_',h,sep='')
      dest <- paste(dradix,'.lzma',sep='')
      print(uri)
      try(download.file(uri,destfile=dest,extra="-H 'Origin: http://freeserv.dukascopy.com' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36' -H 'Accept: */*' -H 'Referer: http://freeserv.dukascopy.com/2.0/?path=historical_data_feed/index&width=100%25&height=600' -H 'Connection: keep-alive'",method='curl'))
      if(file.exists(dest)) {
        try(system(paste('easylzma/build/easylzma/bin/unelzma',dest)))
      } 
    }
  }
}
