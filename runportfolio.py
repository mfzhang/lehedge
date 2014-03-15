from lehedge import *
import numpy as np
import goldendims as gd
import portfolio


p = portfolio.Portfolio()

ask = {"./$AUDUSD.Ask.txt":10000,
       "./$EURUSD.Ask.txt":10000,
       "./$USDJPY.Ask.txt":100}

for (f,tick_res) in ask.iteritems():
    p.add_currency(f,tick_res)

p.load_data()
p.align_start_times()
p.compute_maximum_forward_size()
p.compute_minimum_series_length()
p.set_common_window_size()
p.clean_data()
p.build_timeline()
p.eat()
#p.go()
#p.plot()
