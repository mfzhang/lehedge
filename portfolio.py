from lehedge import *
import datetime as dt

class Portfolio:

    min_train_size  = 10000000
    min_window_size = 10000000
    currencies      = []
    d               = []

    def __init__(self):
        print "init"

    def add_currency(self,filename,tick_res):
        self.currencies.append((filename,tick_res))

    def load_data(self):
        for (f,tick_res) in self.currencies:
            pair = CurrencyData(f,tick_res)
            pair.load_historical_data()
            pair.compute_period()
            self.d.append(pair)

    def align_start_times(self):
        max_start = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.d :
            if( cd.start_time > max_start) :
                max_start = cd.start_time

        for cd in self.d:
            cd.trim_before(max_start)

    #def

    #        pair.compute_forward_window_length()
    #        pair.compute_backward_window_length()
    #        pair.filter_incomplete_duration()
    #        pair.filter_incomplete_profit()
    #        pair.create_backward_windows()
            #pair.build_datasets()

    #def select_backward_window_size(self):



            #pair.plot_images()
    #        if ( len(pair.d_learn[0][0]) < self.min_train_size ): self.min_train_size =len(pair.d_learn[0][0])
    #        if ( len(pair.backward_window_length) < self.min_window_size ): self.min_window_size =len(pair.d_learn[0][0][0])
    #        self.d.append(pair.d_learn)
