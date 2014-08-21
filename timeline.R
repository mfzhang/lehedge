
min_eurusd_ts <- min(eurusd$dt)
min_usdjpy_ts <- min(usdjpy$dt)
min_eurjpy_ts <- min(eurjpy$dt)

max_eurusd_ts <- max(eurusd$dt)
max_usdjpy_ts <- max(usdjpy$dt)
max_eurjpy_ts <- max(eurjpy$dt)

maxmin <- max(min_eurjpy_ts,min_eurusd_ts,min_usdjpy_ts)
minmax <- min(max_eurjpy_ts,max_eurusd_ts,max_usdjpy_ts)

all_data <- rbind(eurjpy,eurusd,usdjpy)
all_timestamps <- data.frame(ts=unique(all_data$dt),stringsAsFactors=FALSE)
head(all_timestamps)
common_timestamps <- all_timestamps[all_timestamps$ts > maxmin & all_timestamps$ts < minmax,]
head(common_timestamps)
nSamples <- 100

s <- sort(sample(common_timestamps,nSamples))

rgb <- NULL
for(t in s){
  r <- t(as.matrix(head(eurusd[eurusd$dt >= t,"bid"],n=1200)))
  rgb <- rbind(rgb,r)
}

dttrain <- data.frame(dt=s,t=1:nSamples)

eurusd_train <- merge(eurusd,dttrain,by.x=c("dt"),by.y=c("dt"), all.x=TRUE)  

subset(eurusd_train,t==1)
