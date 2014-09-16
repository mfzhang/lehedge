library(stringr)  
library(png)

# what we learn from
backwardWindow <- 2*maxBestBuyForwardWindow
forwardWindow  <- maxBestBuyForwardWindow

# this gives us the first row of the dataset for which 
# we know we have enough ticks for all 3 currencies to fill the backward window
# it is where we should initialize the head of the tick reader

nData <- nrow(all.profit)
minRow <- backwardWindow
maxRow <- nData-forwardWindow+1 

print(paste("head initialization row = ",minRow,sep=""))

# let the image generation happen!!
# this will generate 960K images, about 10GB when backward window is 10600 pixels

samplingIdx <- sort(which(all.profit[,"sample"]==1))
croppedIdx <- sort(samplingIdx[samplingIdx >= minRow & samplingIdx <= maxRow])
spit_sample_images(backwardWindow,"img/", croppedIdx)

