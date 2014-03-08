import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
#import pylab
#import scipy
import numpy as np
import cPickle as pickle
#import theano
#import theano.tensor as T
import sklearn.preprocessing
import datetime as dt
#import math
import goldendims as gd
import string

#from PIL import Image
#from theano.tensor.nnet import conv


pd.set_option('display.max_columns', 15)
pd.set_option('display.width', 400)
pd.set_option('display.mpl_style', 'default')
mpl.rcParams['figure.figsize'] = (14, 7)
font = {'family': 'sans',
        'weight': 'bold',
        'size': 12}

mpl.rc('font', **font)

class CurrencyData:

    tick_res  = 10000
    filename  = ''

    def __init__(self, filename, tick_res):
        self.tick_res  = tick_res
        self.filename  = filename

    def load_historical_data(self):

        print "Loading " + self.filename
        h = pd.read_csv(self.filename, sep=";")
        h.columns = ['ts', 'rate', 'volume']
        print "Dropping volume column"
        h = h.drop('volume', 1)

        print "Creating unique timestamp for each tick"
        parse_ts = lambda x: dt.datetime.strptime(x, '%Y%m%d %H%M%S')
        h['dt'] = h.apply(lambda row: parse_ts(row['ts']), axis=1)
        gb = h.groupby('ts')
        h['dtrank'] = gb['dt'].rank(method='first')
        parse_with_millisecond = lambda x: dt.datetime.strptime(x, '%Y%m%d %H%M%S %f')
        h['dtmil'] = h.apply(lambda row: parse_with_millisecond(row['ts'] + ' ' + str(int(row['dtrank']))), axis=1)

        print "Associating random number to each row for later sampling"
        h['rnd'] = np.random.random_sample((len(h),))

        self.h = h

    def compute_forward_window_length(self):

        print "Computing best forward window length (maximum 3000 ticks)"
        range_of_window_sizes = range(0, 3000, 50)
        best_window_size = 0
        for window_size in range_of_window_sizes:
            tmp = self.tick_res * (self.h['rate'].shift(-window_size) - self.h['rate'])
            q = tmp.quantile(0.98)
            if round(q) >= 10.0:
                best_window_size = window_size
                break
        print "Best window size is %d ticks" % (best_window_size)

        self.best_window_size = best_window_size

    # strategy : use longest window

    def filter_incomplete_duration(self):

        print "Computing forward window duration as datetime"
        self.h['forward_window_duration'] = self.h['dtmil'].shift(-self.best_window_size) - self.h['dtmil']
        print "Filtering out rows for which we have no complete forward window"
        self.h = self.h[self.h['forward_window_duration'].notnull()]
        print "Computing forward window duration in seconds"
        self.h['forward_window_duration_seconds'] = self.h['forward_window_duration'] / np.timedelta64(1, 's')
        print "Filtering out rows part of everlasting forward windows (> 2 hours)"
        a_long_enough_period_to_identify_closed_markets = 7200
        self.h = self.h[self.h['forward_window_duration_seconds'] < a_long_enough_period_to_identify_closed_markets]


    def filter_incomplete_profit(self):

        print "Computing forward window profit in pips used for classification"
        self.h['forward_window_profit'] = self.tick_res * (self.h['rate'].shift(-self.best_window_size) - self.h['rate'])

        print "Filtering out rows with null profit and casting profit to int"
        self.h['forward_window_profit'] = self.h['forward_window_profit'][self.h['forward_window_profit'].notnull()].round().astype('int')


    def create_backward_windows(self):

        print "Creating backward windows with twice the length of the forward window for each row"
        backward_window_size = self.best_window_size*2
        for lag in range(0, backward_window_size):
            colname = 'r' + str(lag)
            self.h[colname] = self.h['rate'].shift(lag)

        print "Filtering out rows with incomplete backward window"
        self.d = self.h[self.h['r' + str(backward_window_size - 1)].notnull()]


    def build_datasets(self):

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

            if d_train_x == []:
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

    def plot_images(self):
        selection = np.random.choice(len(self.d_learn[0][0]),25)
        #s = self.d_learn[0][0][selection]
        fig = plt.figure()
        rows = 5
        cols = 5
        dims = gd.GoldenRectangle(len(self.d_learn[0][0][0])).dimensions()
        print dims
        for i in range(0, rows):
            for j in range(0, cols):
                ax = fig.add_subplot(rows, cols, i * rows + j)
                ax.set_xticks([])
                ax.set_yticks([])
                #where = offset + i * ix + j * jx
                where = selection[i*rows+j]
                xo = self.d_learn[0][0][where]
                yo = 1 / (1 + np.exp(-xo)) * 255
                print "image length=%d" % (len(yo))
                ax.set_title(str(where) + '->' + str(self.d_learn[0][1][where]))
                ax.imshow(np.reshape(yo, (dims[0],dims[1])), vmin=0, vmax=255)
                plotfile = string.replace(string.replace(self.filename,'.','_'),'/$','') + '.png'
                plt.savefig(plotfile)

#print "Training set : %d" % (len(d_learn[0][0]))
#print "Test set : %d" % (len(d_learn[1][0]))

#with open("d_learn", 'wb') as fp:
#    pickle.dump(d_learn, fp)

#d_learn
