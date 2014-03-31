from lehedge import *
import datetime as dt
import pandas as pd
import numpy as np
import sklearn.preprocessing
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

class Portfolio:

    currencies      = []
    source_data     = []
    working_sets    = {}

    def __init__(self):
        print "init"

    def add_currency(self,filename,tick_res):
        self.currencies.append((filename,tick_res))

    def load_data(self):
        for (f,tick_res) in self.currencies:
            pair = CurrencyData(f,tick_res)
            pair.load_historical_data()
            pair.compute_period()
            self.source_data.append(pair)

    def compute_maximum_forward_size(self):
        '''
        what is the max of all best forward windows?
        longer windows = more profit
        '''
        self.common_forward_window_size = 0
        for cd in self.source_data:
            cd.compute_forward_window_length()
            if( cd.best_window_size > self.common_forward_window_size ): self.common_forward_window_size=cd.best_window_size

    def set_common_window_size(self):
        '''
        the code is clear
        '''
        self.common_backward_window_size  = self.common_forward_window_size*2
        for cd in self.source_data:
            cd.set_forward_window_length(self.common_forward_window_size)
            cd.set_backward_window_length(self.common_backward_window_size)

    def compute_forward_profit(self):
        '''
        based on previously set forward window length we can now compute price difference
        we call it profit but it doesn't take spread into account
        '''
        for cd in self.source_data:
            cd.compute_forward_profit()


    def clean_data(self):
        '''
        clean up NaN profit records frames that overlap week-ends
        '''
        for cd in self.source_data:
            cd.filter_incomplete_duration()
            cd.filter_incomplete_profit()

    def align_start_times(self):
        '''
        useless
        '''
        max_start = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.source_data :
            if( cd.start_time > max_start) :
                max_start = cd.start_time

        for cd in self.source_data:
            cd.trim_before(max_start)

    def create_learning_windows(self):
        '''
        useless
        '''
        for cd in self.source_data:
            cd.create_backward_windows()

    def compute_minimum_series_length(self):
        '''
        useless
        used to compute training set size as a fraction of minimum size
        '''
        self.minimum_series_length = 1000000000
        for cd in self.source_data:
            if( len(cd.h) < self.minimum_series_length ): self.minimum_series_length=len(cd.h)

    def compute_total_forward_profit(self):
        '''
        useless
        '''
        self.forward_profit = self.source_data[0].h['forward_window_profit'] + \
                              self.source_data[1].h['forward_window_profit'] + \
                              self.source_data[2].h['forward_window_profit']


    def build_timeline(self):
        '''
        build union of all tiemstamps appearing in all 3 channels
        '''
        self.source_data[0].h.sort()
        self.source_data[1].h.sort()
        self.source_data[2].h.sort()

        self.init_timestamp = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.source_data:
            if cd.h['dtmil'][self.common_backward_window_size] > self.init_timestamp:
                self.init_timestamp = cd.h['dtmil'][self.common_backward_window_size]

        self.min_ts = dt.datetime(2070, 1, 1, 0, 0, 0, 000000)
        for cd in self.source_data:
            if max(cd.h['dtmil']) <= self.min_ts:
                self.min_ts = max(cd.h['dtmil'])

        distinct_timestamps = np.unique(np.hstack([self.source_data[0].h['dtmil'], self.source_data[1].h['dtmil'], self.source_data[2].h['dtmil']]))
        trim_end = distinct_timestamps[distinct_timestamps <= np.datetime64(self.min_ts.to_pydatetime())]
        trim_beginning = trim_end[trim_end >= np.datetime64(self.init_timestamp.to_pydatetime())]
        randomizer = np.random.random_sample((len(trim_beginning),))
        self.timeline = pd.Series(randomizer,index=trim_beginning)


    def eat(self,name,lower_rnd=0.0,higher_rnd=0.1):
        '''
        # at each millisecond, fetch the latest bacward_window_size ticks
        # for each currency
        # init time = max timestamp such as all 3 buffers can be entirely filled
        #self.timeline.sort()
        #tenpct = ((self.timeline <= 0.1) & (self.timeline.index > self.init_timestamp))
        '''
        samples_count = len(self.timeline)
        #threshold = 15000.0 / samples_count
        #tenpct = ( lower_rnd <= self.timeline and self.timeline < higher_rnd )
        lowpass = self.timeline[self.timeline < higher_rnd]
        hipass  = lowpass[lowpass>lower_rnd]
        self.training_timestamps = hipass.index
        print self.training_timestamps

        common  = np.zeros((3,len(self.training_timestamps), self.common_backward_window_size))
        profits = np.zeros((len(self.training_timestamps),3))
        print "sampling %d frames with length %d" % (len(self.training_timestamps),self.common_backward_window_size)

        for i in range(0,len(self.training_timestamps)):
            ts = self.training_timestamps[i]
            common[0][i] = sklearn.preprocessing.scale(self.source_data[0].h[self.source_data[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            common[1][i] = sklearn.preprocessing.scale(self.source_data[1].h[self.source_data[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            common[2][i] = sklearn.preprocessing.scale(self.source_data[2].h[self.source_data[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            pidxR = max(self.source_data[0].h[self.source_data[0].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            profits[i][0] =   self.source_data[0].h[self.source_data[0].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxR]
            pidxG = max(self.source_data[1].h[self.source_data[1].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            profits[i][1] =   self.source_data[1].h[self.source_data[1].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxG]
            pidxB = max(self.source_data[2].h[self.source_data[2].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'].index)
            profits[i][2] =   self.source_data[2].h[self.source_data[2].h['dtmil'] < ts][-self.common_backward_window_size:]['forward_window_profit'][pidxB]

        self.working_sets[name] = (common.swapaxes(0,2).swapaxes(0,1),profits)


    def sigmoidize(self,name):
        data = self.working_sets[name][0]
        self.working_sets[name] = (1 / (1 + np.exp(-data)),self.working_sets[name][1])

    def cluster_profit_triples(self):
        self.km = KMeans(init='k-means++',n_clusters=9)

    def plot_working_set_sample(self,name):
        rows = 5
        cols = 5
        selection = np.random.choice(len(self.working_sets[name][0]),rows*cols)
        dims = gd.GoldenRectangle(self.common_backward_window_size).dimensions()
        print dims
        for i in range(0, rows):
            for j in range(0, cols):
                fig = plt.figure()
                if dims[0]>dims[1]:
                    fig.set_size_inches(dims[1]/100.0,dims[0]/100.0)
                else:
                    fig.set_size_inches(dims[0]/100.0,dims[1]/100.0)
                #ax = fig.add_subplot(rows, cols, i * rows + j)
                #ax.set_xticks([])
                #ax.set_yticks([])
                where = selection[i*rows+j]
                #print "image length=%d" % (len(yo))
                profits = self.working_sets[name][1][where]
                #ax.set_title('('+str(round(profits[0]))+','+str(round(profits[1]))+','+str(round(profits[2]))+')')
                fname = '('+str(round(profits[0]))+','+str(round(profits[1]))+','+str(round(profits[2]))+')'
                #ax.imshow(np.reshape(self.working_sets[name][0][where], (dims[0],dims[1],3)))
                fig.figimage(np.reshape(self.working_sets[name][0][where], (dims[0],dims[1],3)),0,0)
                plt.show()
                plt.savefig('working_set-'+fname+'.png',dpi=100)
                plt.close(fig)

