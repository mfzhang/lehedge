source('munging_functions.R')

system.time(EURUSD.ticks <- load_from_binary('EURUSD',100000))
system.time(USDJPY.ticks <- load_from_binary('USDJPY',1000))
system.time(EURJPY.ticks <- load_from_binary('EURJPY',1000))