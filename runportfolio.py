from lehedge import *
import numpy as np
import goldendims as gd
import portfolio


p = portfolio.Portfolio()

askFull = {"./$AUDUSD.Ask.txt":10000,
       "./$EURUSD.Ask.txt":10000,
       "./$USDJPY.Ask.txt":100}

askTest = {"./AUDUSD.Ask.Test.txt":10000,
       "./EURUSD.Ask.Test.txt":10000,
       "./USDJPY.Ask.Test.txt":100}

ask = askTest

for (f,tick_res) in ask.iteritems():
    p.add_currency(f,tick_res)

p.load_data()
p.compute_maximum_forward_size()
p.compute_minimum_series_length()
p.set_common_window_size()
p.compute_forward_profit()
p.clean_data()
p.build_timeline()
p.eat('training')
p.sigmoidize('training')
p.plot_working_set_sample('training')
