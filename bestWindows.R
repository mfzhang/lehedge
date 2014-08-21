source('munging_functions.R')

maxEURUSD <- bestBuyForwardWindow(EURUSD.ticks,10000)
print(paste("EURUSD=",maxEURUSD))

maxUSDJPY <- bestBuyForwardWindow(USDJPY.ticks,100)
print(paste("USDJPY=",maxUSDJPY))

maxEURJPY <- bestBuyForwardWindow(EURJPY.ticks,100)
print(paste("EURJPY=",maxEURJPY))

maxBestBuyForwardWindow <- max( maxEURUSD,
                                maxUSDJPY,
                                maxEURJPY)

print(paste("Best buy max window=",maxBestBuyForwardWindow))

maxEURUSD <- bestSellForwardWindow(EURUSD.ticks,10000)
print(paste("EURUSD=",maxEURUSD))

maxUSDJPY <- bestSellForwardWindow(USDJPY.ticks,100)
print(paste("USDJPY=",maxUSDJPY))

maxEURJPY <- bestSellForwardWindow(EURJPY.ticks,100)
print(paste("EURJPY=",maxEURJPY))

maxBestSellForwardWindow <- max( maxEURUSD,
                                maxUSDJPY,
                                maxEURJPY)

print(paste("Best sell max window=",maxBestSellForwardWindow))
