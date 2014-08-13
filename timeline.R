all_data <- rbind(eurjpy,eurusd,usdjpy)
all_timestamps <- unique(all_data$dt)
head(all_timestamps)
nSamples <- 10000
s <- sample(all_timestamps,nSamples)
dttrain <- data.frame(dt=s,t=rep(1,nSamples))

eurusd_train <- merge(eurusd,dttrain,by.x=c("dt"),by.y=c("dt"), all.x=TRUE)  

subset(eurusd_train,t==1)
