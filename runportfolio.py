from lehedge import *
import numpy as np
import goldendims as gd
import portfolio


p = portfolio.Portfolio()

askFull = {"./$AUDUSD.Ask.txt":10000,
       "./$EURUSD.Ask.txt":10000,
       "./$USDJPY.Ask.txt":100}

askLatest = {"/Users/fly/PycharmProjects/lehedge/EURJPY-Ask-0622-0718.txt":100,
       "/Users/fly/PycharmProjects/lehedge/EURUSD-Ask-0622-0718.txt":10000,
       "/Users/fly/PycharmProjects/lehedge/USDJPY-Ask-0620-0718.txt":100}

askLatest100k = {"/Users/fly/PycharmProjects/lehedge/EURJPY-Ask-0622-0718.100k.txt":100,
       "/Users/fly/PycharmProjects/lehedge/EURUSD-Ask-0622-0718.100k.txt":10000,
       "/Users/fly/PycharmProjects/lehedge/USDJPY-Ask-0620-0718.100k.txt":100}

askTest = {"./AUDUSD.Ask.Test.txt":10000,
       "./EURUSD.Ask.Test.txt":10000,
       "./USDJPY.Ask.Test.txt":100}

ask = askLatest100k

for (f,tick_res) in ask.iteritems():
    p.add_currency(f,tick_res)

p.load_data()
p.compute_maximum_forward_size()
p.compute_minimum_series_length()
p.set_common_window_size()
p.compute_forward_profit()
p.clean_data()
p.build_timeline()
#p.eat('training')
p.build_datasets(1000,300,300)
p.sigmoidize('training')
p.dump_working_sets_as_png('training')
p.dump_profits()
#p.plot_working_set_sample('training')
