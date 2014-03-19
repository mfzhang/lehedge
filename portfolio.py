from lehedge import *
import datetime as dt
import pandas as pd
import numpy as np
import sklearn.preprocessing

class Portfolio:

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

    def compute_maximum_forward_size(self):
        '''
        what is the max of all best forward windows?
        longer windows = more profit
        '''
        self.common_forward_window_size = 0
        for cd in self.d:
            cd.compute_forward_window_length()
            if( cd.best_window_size > self.common_forward_window_size ): self.common_forward_window_size=cd.best_window_size

    def set_common_window_size(self):
        '''
        the code is clear
        '''
        self.common_backward_window_size  = self.common_forward_window_size*2
        for cd in self.d:
            cd.set_forward_window_length(self.common_forward_window_size)
            cd.set_backward_window_length(self.common_backward_window_size)

    def compute_forward_profit(self):
        '''
        based on previously set forward window length we can now compute price difference
        we call it profit but it doesn't take spread into account
        '''
        for cd in self.d:
            cd.compute_forward_profit()


    def clean_data(self):
        '''
        clean up NaN profit records frames that overlap week-ends
        '''
        for cd in self.d:
            cd.filter_incomplete_duration()
            cd.filter_incomplete_profit()

    def align_start_times(self):
        '''
        useless
        '''
        max_start = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.d :
            if( cd.start_time > max_start) :
                max_start = cd.start_time

        for cd in self.d:
            cd.trim_before(max_start)

    def create_learning_windows(self):
        '''
        useless
        '''
        for cd in self.d:
            cd.create_backward_windows()

    def compute_minimum_series_length(self):
        '''
        useless
        used to compute training set size as a fraction of minimum size
        '''
        self.minimum_series_length = 1000000000
        for cd in self.d:
            if( len(cd.h) < self.minimum_series_length ): self.minimum_series_length=len(cd.h)

    def compute_total_forward_profit(self):
        '''
        useless
        '''
        self.forward_profit = self.d[0].h['forward_window_profit'] + \
                              self.d[1].h['forward_window_profit'] + \
                              self.d[2].h['forward_window_profit']


    def build_timeline(self):
        '''
        build union of all tiemstamps appearing in all 3 channels
        '''
        self.d[0].h.sort()
        self.d[1].h.sort()
        self.d[2].h.sort()

        self.init_timestamp = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.d:
            if cd.h['dtmil'][self.common_backward_window_size] > self.init_timestamp:
                self.init_timestamp = cd.h['dtmil'][self.common_backward_window_size]

        self.min_ts = dt.datetime(2070, 1, 1, 0, 0, 0, 000000)
        for cd in self.d:
            if max(cd.h['dtmil']) <= self.min_ts:
                self.min_ts = max(cd.h['dtmil'])

        distinct_timestamps = np.unique(np.hstack([self.d[0].h['dtmil'], self.d[1].h['dtmil'], self.d[2].h['dtmil']]))
        trim_end = distinct_timestamps[distinct_timestamps <= np.datetime64(self.min_ts.to_pydatetime())]
        trim_beginning = trim_end[trim_end >= np.datetime64(self.init_timestamp.to_pydatetime())]
        randomizer = np.random.random_sample((len(trim_beginning),))
        self.timeline = pd.Series(randomizer,index=trim_beginning)


    def eat(self):
        '''
        # at each millisecond, fetch the latest bacward_window_size ticks
        # for each currency
        # init time = max timestamp such as all 3 buffers can be entirely filled
        #self.timeline.sort()
        #tenpct = ((self.timeline <= 0.1) & (self.timeline.index > self.init_timestamp))
        '''
        samples_count = len(self.timeline)
        threshold = 15000.0 / samples_count
        tenpct = (self.timeline <= threshold)
        self.training_timestamps = self.timeline[tenpct].index
        print self.training_timestamps

        self.common  = np.zeros((3,len(self.training_timestamps), self.common_backward_window_size))
        self.profits = np.zeros((len(self.training_timestamps),3))
        print "sampling %d frames with length %d" % (len(self.training_timestamps),self.common_backward_window_size)

        for i in range(0,len(self.training_timestamps)):
            ts = self.training_timestamps[i]
            self.common[0][i] = sklearn.preprocessing.scale(self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            self.common[1][i] = sklearn.preprocessing.scale(self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            self.common[2][i] = sklearn.preprocessing.scale(self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            pidxR = max(self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            self.profits[i][0] =   self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxR]
            pidxG = max(self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            self.profits[i][1] =   self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxG]
            pidxB = max(self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            self.profits[i][2] =   self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxB]

        self.training = self.common.swapaxes(0,2).swapaxes(0,1)


    def sigmoidize(self):
        self.training = 1 / (1 + np.exp(-self.training))


    def plot(self):
        rows = 5
        cols = 5
        selection = np.random.choice(len(self.training),rows*cols)
        fig = plt.figure()
        dims = gd.GoldenRectangle(self.common_backward_window_size).dimensions()
        print dims
        for i in range(0, rows):
            for j in range(0, cols):
                ax = fig.add_subplot(rows, cols, i * rows + j)
                ax.set_xticks([])
                ax.set_yticks([])
                where = selection[i*rows+j]
                #print "image length=%d" % (len(yo))
                profits = self.profits[where]
                ax.set_title('('+str(round(profits[0]))+','+str(round(profits[1]))+','+str(round(profits[2]))+')')
                ax.imshow(np.reshape(self.training[where], (dims[0],dims[1],3)))
                plt.show()
                plt.savefig('common.png')

