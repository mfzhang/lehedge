maxEURUSD <- bestBuyForwardWindow(EURUSD.raw,10000)
print(paste("EURUSD=",maxEURUSD))

maxUSDJPY <- bestBuyForwardWindow(USDJPY.raw,100)
print(paste("USDJPY=",maxUSDJPY))

maxEURJPY <- bestBuyForwardWindow(EURJPY.raw,100)
print(paste("EURJPY=",maxEURJPY))

maxBestBuyForwardWindow <- max( maxEURUSD,
                                maxUSDJPY,
                                maxEURJPY)

print(paste("Best buy max window=",maxBestBuyForwardWindow))
