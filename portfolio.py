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
        self.common_forward_window_size = 0
        for cd in self.d:
            cd.compute_forward_window_length()
            if( cd.best_window_size > self.common_forward_window_size ): self.common_forward_window_size=cd.best_window_size

    def set_common_window_size(self):
        self.common_backward_window_size  = self.common_forward_window_size*2
        for cd in self.d:
            cd.set_forward_window_length(self.common_forward_window_size)
            cd.set_backward_window_length(self.common_backward_window_size)

    def clean_data(self):
        for cd in self.d:
            cd.filter_incomplete_duration()
            cd.filter_incomplete_profit()

    def align_start_times(self):
        # post-filtering
        max_start = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.d :
            if( cd.start_time > max_start) :
                max_start = cd.start_time

        for cd in self.d:
            cd.trim_before(max_start)

    def create_learning_windows(self):
        for cd in self.d:
            cd.create_backward_windows()

    def compute_minimum_series_length(self):
        # used to compute training set size as a fraction of minimum size
        self.minimum_series_length = 1000000000
        for cd in self.d:
            if( len(cd.h) < self.minimum_series_length ): self.minimum_series_length=len(cd.h)

    def compute_forward_profit(self):
        """

        :type self: int
        """
        self.forward_profit = self.d[0].h['forward_window_profit'] + \
                              self.d[1].h['forward_window_profit'] + \
                              self.d[2].h['forward_window_profit']


    def fast_forward(self):
        #  consider the following tick streams
        #  time   S - - - - - - - - - - - - - - - S - - - - >
        #  ticksR *     *   * *   * * *   *   * *
        #  ticksG   *   * *   * * * * * * * d d
        #  ticksB *   * * * * * * * * *   d d   d
        #
        # S is the start timestamp of a new RGB buffer of 10 ticks
        # ticksB buffer of 10 gets filled first, and ticksR last
        # We want to drop the d ticks in ticksG and ticksB before
        # starting filling a new RGB buffer
        # this method does just that, based on the timestamp of the last
        # tick arriving in buffer ticksR
        pass

    def build_timeline(self):
        # build union of all tiemstamps appearing in all 3 channels
        self.d[0].h.sort()
        self.d[1].h.sort()
        self.d[2].h.sort()
        self.init_timestamp = dt.datetime(1970, 1, 1, 0, 0, 0, 000000)
        for cd in self.d:
            if cd.h['dtmil'][self.common_backward_window_size] > self.init_timestamp:
                self.init_timestamp = cd.h['dtmil'][self.common_backward_window_size]

        distinct_timestamps = np.unique(np.hstack([self.d[0].h['dtmil'], self.d[1].h['dtmil'], self.d[2].h['dtmil']]))
        randomizer = np.random.random_sample((len(distinct_timestamps),))
        self.timeline = pd.Series(randomizer,index=distinct_timestamps)
        #self.timeline = self.timeline[self.timeline>=self.init_timestamp]

        #pass

    def eat(self):
        # at each millisecond, fetch the latest bacward_window_size ticks
        # for each currency
        # init time = max timestamp such as all 3 buffers can be entirely filled
        #self.timeline.sort()
        tenpct = ((self.timeline <= 0.1) & (self.timeline.index > self.init_timestamp))
        self.training_timestamps = self.timeline[tenpct].index
        print self.training_timestamps

        self.common = np.zeros((3,len(self.training_timestamps), self.common_backward_window_size))
        print "sampling %d frames with length %d" % (len(self.training_timestamps),self.common_backward_window_size)

        for i in range(0,len(self.training_timestamps)):
            ts = self.training_timestamps[i]
            #print "i= %d, ts=%s" % (i,ts.strftime("%A, %d. %B %Y %I:%M%p"))
            #startR = min(self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'].index)
            #startG = min(self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'].index)
            #startB = min(self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'].index)
            self.common[0][i] = sklearn.preprocessing.scale(self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            self.common[1][i] = sklearn.preprocessing.scale(self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            self.common[2][i] = sklearn.preprocessing.scale(self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'])
            #for j in range(0, self.common_backward_window_size):
                #print self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate']
                #self.common[i][j][0] = self.d[0].h[self.d[0].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'][j+startR]
                #print self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate']
                #self.common[i][j][1] = self.d[1].h[self.d[1].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'][j+startG]
                #print self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate']
                #self.common[i][j][2] = self.d[2].h[self.d[2].h['dtmil'] < ts][-self.common_backward_window_size:]['rate'][j+startB]
        self.training = self.common.swapaxes(0,2).swapaxes(0,1)


    def go(self):
        for cd in self.d:
            cd.build_datasets()

        self.common = np.zeros((self.minimum_series_length,self.common_backward_window_size,3))

        for i in range(0,self.minimum_series_length):
            for j in range(0, self.common_backward_window_size):
                self.common[i][j][0] = 1 / (1 + np.exp(-self.d[0].d_learn[0][0][i][j]))
                self.common[i][j][1] = 1 / (1 + np.exp(-self.d[1].d_learn[0][0][i][j]))
                self.common[i][j][2] = 1 / (1 + np.exp(-self.d[2].d_learn[0][0][i][j]))

    def build_learning_datasets(self):
        bins = {(int(self.d['forward_window_profit'].min()), -10.0): -1,
                (-9.0, 9.0): 0,
                (10.0, int(self.d['forward_window_profit'].max())): 1}

        train_per_class = 7000
        test_per_class = 3000
        d_test_x = []  #np.zeros((train_per_class*len(bins),window_size))
        d_test_y = []  #np.zeros(train_per_class*len(bins),dtype=numpy.int)
        d_train_x = []
        d_train_y = []

        for (r, label) in bins.iteritems():

            print "bin (%d,%d] -> class %d" % (r[0], r[1], label)

            # isolate same-class records
            mask = ((self.d['forward_window_profit'] >= r[0]) & (self.d['forward_window_profit'] <= r[1]))
            df = self.d[mask]
            examplesCount = len(df)
            print "There are %d examples with label %d" % (examplesCount, label)

            # set 20% of data aside for test in the limit of 2000 examples
            test_mask = (df['rnd'] > 0.8)
            df_test = df[test_mask]
            testRecordsCount = len(df_test)
            print "There are %d test examples with label %d" % (testRecordsCount, label)
            # truncate and copy data held in named cols to pure numpy array
            test_a = np.array(df_test[:test_per_class].values)
            #test_b = np.delete(test_a, np.s_[:7],1)
            x_test = np.delete(test_a, np.s_[:9], 1).astype('float')

            # use remaining 80% of data aside for training in the limit of 10000 examples
            training_mask = (df['rnd'] <= 0.8)
            df_training = df[training_mask]
            trainingRecordsCount = len(df_training)
            print "There are %d training examples with label %d" % (trainingRecordsCount, label)
            sampling_threshold = min(1, (1.0 * train_per_class / trainingRecordsCount)) * 0.8
            print "Sampling threshold : %.10f" % (sampling_threshold)
            sampling_mask = (df_training['rnd'] <= sampling_threshold)
            train_a = np.array(df_training[sampling_mask].values)
            print "Sampled %d examples" % (len(train_a))
            #train_a = np.array(df_training[:train_per_class].values)
            #train_b = sample(train_a, train_per_class)
            x_train = np.delete(train_a, np.s_[:9], 1).astype('float')

            for i in range(0, len(x_train)):
                x_train[i] = sklearn.preprocessing.scale(x_train[i])
            for i in range(0, len(x_test)):
                x_test[i] = sklearn.preprocessing.scale(x_test[i])

            #with open("training_rows#" + str(label), 'wb') as fp: pickle.dump(x_train, fp)
            #with open("test_rows#" + str(label), 'wb') as fp: pickle.dump(x_test, fp)

            y_test = np.ones((len(x_test),), dtype=np.int) * label
            y_train = np.ones((len(x_train),), dtype=np.int) * label

            if not d_train_x:
                d_train_x = x_train
                d_train_y = y_train
                d_test_x = x_test
                d_test_y = y_test
            else:
                d_train_x = np.concatenate((d_train_x, x_train), axis=0)
                d_train_y = np.concatenate((d_train_y, np.ones((len(y_train),), dtype=np.int) * label), axis=0)
                d_test_x = np.concatenate((d_test_x, x_test), axis=0)
                d_test_y = np.concatenate((d_test_y, np.ones((len(y_test),), dtype=np.int) * label), axis=0)

        self.d_learn = ((d_train_x, d_train_y), (d_test_x, d_test_y))



    def plot(self):
        rows = 5
        cols = 5
        selection = np.random.choice(self.minimum_series_length,rows*cols)
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
                ax.set_title('')
                ax.imshow(np.reshape(self.common[where], (dims[0],dims[1],3)))
                plt.savefig('common.png')

