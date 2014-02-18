# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

import pandas as pd
pd.set_option('display.max_columns', 15)
pd.set_option('display.line_width', 400)
pd.set_option('display.mpl_style', 'default')
rcParams['figure.figsize'] = (14, 7)
import matplotlib
font = {'family' : 'sans',
        'weight' : 'bold',
        'size'   : 12}

matplotlib.rc('font', **font)

# <markdowncell>

# ### Loading AUDUSD ask prices
#
# The time serie has format "ts;rate;volume", with ";" delimitor.

# <codecell>

import pandas as pd
audusdask = pd.read_csv("./AUDUSD.Ask",sep=";")
audusdask.columns = ['ts','rate','volume']
audusdask.describe()

# <markdowncell>

# Volume is always equal to one so we can safely drop it.

# <codecell>

audusdask =  audusdask.drop('volume',1)
audusdask.describe()

# <markdowncell>

# Let's examine *ts* a bit.

# <codecell>

audusdask['ts']

# <markdowncell>

# The timestamp do not carry a millisecond component in FXCM historical feed.
# Some ticks happen in the same second (see records 10,11,12 all timestamped 20131222 220114), so we can't use *ts* as a pandas Serie index which requires unique values. This is further verified by examining the full distribution of timestamps.

# <codecell>

ts_distro = audusdask.groupby('ts').aggregate(len)

# <codecell>

ts_distro.describe()

# <markdowncell>

# So this is very interesting, we have an average 3.5 ticks (price changes) per second. The maximum is at 49 ticks per second.
# So if we want to build a datetime index from these timestamps we can artificially create a milliseconds field based on the row ordering and current minute. Since we never have more than a thousand ticks per second it is OK to do so.

# <markdowncell>

# Let's use the rank of identical to-the-second precision timestamps to create an artificial milliseconds field.
# Not be noted : we assume our data provider provided a properly ordered dataset.
# We need a proper datetime rather than a string to use the ranking function.

# <codecell>

import datetime as dt
parse = lambda x: dt.datetime.strptime(x, '%Y%m%d %H%M%S')
audusdask['dt'] = audusdask.apply(lambda row: parse(row['ts']),axis=1)

# <codecell>

gb = audusdask.groupby('ts')
audusdask['dtrank'] = gb['dt'].rank(method='first')

# <codecell>

parse_with_millisecond = lambda x: dt.datetime.strptime(x, '%Y%m%d %H%M%S %f')
audusdask['dtmil'] = audusdask.apply(lambda row: parse_with_millisecond(row['ts']+' '+str(int(row['dtrank']))),axis=1)

# <codecell>

audusdask.head(n=15)

# <markdowncell>

# **Nice!!!** We now have a proper timestamp with unique values to create a Serie index.

# <codecell>

audusdask_ts = pd.Series(audusdask['rate'].values,index=audusdask['dtmil'])
audusdask_ts

# <markdowncell>

# We can now plot this time series. Note we have large data gaps because the markets are closed over the week-ends, on Christmas day and New Year's day. I will fetch new data with less gaps as soon as possible. Ho yeah, the plot below is broken in pandas 0.12, solved by upgrading to 0.13

# <codecell>

audusdask_ts.plot()

# <markdowncell>

# We can also plot it without gaps.

# <codecell>

pylab.plot(audusdask_ts)

# <markdowncell>

# Now let's create a random value taken from Uniform(0,1) distro for each example.

# <codecell>

audusdask['rnd'] = np.random.random_sample((len(audusdask),))

# <markdowncell>

# We assume the following characteristics fro our trading system :
#
#  - short position duration, expressed in ticks rather than time.
#  - small target profit : between 10 and 15 pips after spread/transaction cost deduction
#
# Let's dive in a bit to figure out if the data supports these expectations.

# <codecell>

r = range(0,3000,50)
d = np.zeros((len(r),2))
i = 0
for window_size in r:
    tmp = 10000*(audusdask['rate'].shift(-window_size)-audusdask['rate'])
    d[i][0]=tmp.quantile(0.95)
    d[i][1]=tmp.quantile(0.98)
    i = i+1
df = pd.DataFrame(d,index=r,columns=['Q95','Q98'])
df.plot(rot=90,xticks=r)

# <markdowncell>

# Ok let's pick this one : 2% of all 950-tick windows bring 10 pips profit or more.
# Depending on volatility 950-tick windows have a different duration. Let's describe this.

# <codecell>

audusdask['timediff_950'] = audusdask['dtmil'].shift(-950) -audusdask['dtmil']
audusdask['pips_950']     = 10000*(audusdask['rate'].shift(-950) -audusdask['rate'])

# <codecell>

audusdask = audusdask[audusdask['timediff_950'].notnull()]
audusdask['timediff_950_seconds'] = audusdask['timediff_950'] / np.timedelta64(1, 's')
audusdask['timediff_950_seconds'].plot()

# <markdowncell>

# So here come the gap days again. Let's filter these out.

# <codecell>

audusdask = audusdask[audusdask['timediff_950_seconds']<20000]

# <codecell>

plt.figure()
audusdask.timediff_950_seconds.plot()
audusdask[audusdask.pips_950>=10].pips_950.plot(secondary_y=True, style='ro',ylim=(0,24))

# <markdowncell>

# It is a bit hard to visualize association between position duration and profit on this time series graph.
# Let's use a scatter plot instead.

# <codecell>

plt.scatter(audusdask[audusdask.pips_950>=10].pips_950,audusdask[audusdask.pips_950>=10].timediff_950_seconds)

# <markdowncell>

# Ok there's clearly no linear association between the 2 variables.
# Let's describe them a bit further.

# <headingcell level=3>

# Profit description for 950-ticks windows

# <codecell>

audusdask[audusdask.pips_950>=10].pips_950.hist()

# <codecell>

audusdask[audusdask.pips_950>=10].pips_950.describe()

# <codecell>

import sklearn.preprocessing
pips950_scaled = sklearn.preprocessing.scale(audusdask.pips_950)

# <codecell>

hist(pips950_scaled,bins=30)

# <markdowncell>

# Let's check is profits are normally distributed with a Kolmogorov-Smirnov test.

# <codecell>

from scipy import stats
from scipy.stats import kstest
kstest(pips950_scaled,'norm')

# <markdowncell>

# The zero p-value tells us we can reject the null hypothesis that profits are normally distributed. This is actually confirmed by the skew test, null hypothesis is identical skewness of sample and normal distribution.

# <codecell>

import scipy
scipy.stats.skewtest(pips950_scaled)

# <headingcell level=3>

# Duration description for 950-tick windows

# <markdowncell>

# Not sure what to think yet about this.
# Here is a rule we can use to create good binning values.

# <codecell>

sturges = lambda n: int(log2(n) + 1)
square_root = lambda n: int(sqrt(n))
from scipy.stats import kurtosis
doanes = lambda data: int(1 + log(len(data)) + log(1 + kurtosis(data) * (len(data) / 6.) ** 0.5))

n = len(audusdask[audusdask.pips_950>=10].timediff_950_seconds)
sturges(n), square_root(n), doanes(audusdask[audusdask.pips_950>=10].timediff_950_seconds)

# <codecell>

audusdask[audusdask.pips_950>=10].timediff_950_seconds.hist(bins=15)

# <codecell>

audusdask[audusdask.pips_950>=10].timediff_950_seconds.describe()

# <markdowncell>

# So half profitable windows have a duration between ~1 minute 30s and 6 min 25s. 75% trades would last less than 10 minutes, and the maximum is half an hour.

# <codecell>

timediff_950_seconds_scaled = sklearn.preprocessing.scale(audusdask.timediff_950_seconds)
hist(timediff_950_seconds_scaled,bins=15)

# <markdowncell>

# This is very skewed, not worth testing for normality.
# Last one, let's focus on durations distribution for 950-tick windows that generate 10 pips exactly :

# <codecell>

# just for fun
scipy.stats.skewtest(timediff_950_seconds_scaled)

# <codecell>

mask = ((audusdask.pips_950>=10.0) & (audusdask.pips_950<10.5))
d = audusdask[mask]
d = sklearn.preprocessing.scale(d.timediff_950_seconds)
kstest(d,'norm')

# <codecell>

audusdask.pips_950

# <codecell>

round(-9.51)

# <codecell>

#audusdask.drop('pips_950i',1)
audusdask['pips_950i'] = audusdask['pips_950'][audusdask['pips_950'].notnull()].round().astype('int')

# <codecell>

dbydelta = audusdask.groupby('pips_950i')

# <codecell>

dbydelta['rate'].aggregate(len).plot()

# <codecell>

deltahist = dbydelta['rate'].aggregate(len)

# <codecell>

deltahist.index

# <codecell>

log(deltahist[[-28.0, -27.0, -26.0, -25.0, -24.0, -23.0, -22.0, -21.0, -20.0, -19.0, -18.0, -17.0, -16.0, -15.0, -14.0, -13.0, -12.0, -11.0, -10.0,10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0]]).plot()

# <headingcell level=3>

# Maximum profit

# <codecell>

(deltahist[[-15.0,-14.0,-13.0,-12.0,-11.0,-10.0,10.0,11.0,12.0,13.0,14.0,15.0]]).sum()

# <headingcell level=3>

# Data windows

# <markdowncell>

# Now we want to build the actual data set we will use to train and test our algorithms.
#
# #### Objective
# Our trading system should take market positions held for 950 consecutive ticks (price changes).
# Question : how much data should we use to predict direction and market entry points?
# Answer :  this is clearly a hyper-parameter of our design and will require optimization. Let's start with about twice the size of the forward window, that is **1904 pre-ticks history** for a prediction at 950 post-ticks. We want to build images from data, it doesn't matter what the shape of it is but let's make introduce the golden number in there.

# <codecell>

pre_window_size = 1904
# xy = 1904
# x/y ~= 1.618
golden = (1+sqrt(5))/2
y = sqrt(1900/golden)
x = golden*y
x, y
56/34.0

# <codecell>

#for i in range(0,pre_window_size):
#    colname = 'r' + str(i)
#    audusdask.drop(colname,1)
for i in range(0,pre_window_size):
    colname = 'r' + str(i)
    audusdask[colname] = audusdask['rate'].shift(i)

# <codecell>

audusdask['r1903']

# <codecell>

audusdask['pips_950'].round().astype('int')

# <codecell>

(10000/560939.0)*0.8

# <codecell>

import sklearn.preprocessing
import cPickle as pickle

#bins = { (int(audusdask['pips_950i'].min()),-16.0) : -2,
#         (-15.0,-10.0) : -1,
#         (-9.0,9.0) : 0,
#         (10.0,15.0) : 1,
#         (16.0, int(audusdask['pips_950i'].max())) : 2 }

window_size = 1904

d = audusdask[audusdask['r'+str(window_size-1)].notnull()]

bins = { (int(d['pips_950i'].min()),-10.0) : -1,
         (-9.0,9.0) : 0,
         (10.0, int(d['pips_950i'].max())) : 1 }

train_per_class = 10000
test_per_class  = 2000
d_test_x = [] #np.zeros((train_per_class*len(bins),window_size))
d_test_y = [] #np.zeros(train_per_class*len(bins),dtype=numpy.int)
d_train_x = []
d_train_y = []

j = 0
for (r,label) in bins.iteritems():

    print "bin (%d,%d] -> class %d" % (r[0],r[1],label)

    # isolate same-class records
    mask = ((d['pips_950i']>=r[0]) & (d['pips_950i']<=r[1]))
    df = d[mask]
    examplesCount = len(df)
    print "There are %d examples with label %d" % (examplesCount,label)

    # set 20% of data aside for test in the limit of 2000 examples
    test_mask        = (df['rnd']>0.8)
    df_test          =  df[test_mask]
    testRecordsCount = len(df_test)
    print "There are %d test examples with label %d" % (testRecordsCount,label)
    # truncate and copy data held in named cols to pure numpy array
    test_a = np.array(df_test[:test_per_class].values)
    #test_b = np.delete(test_a, np.s_[:7],1)
    x_test = np.delete(test_a, np.s_[:10],1).astype('float')

    # use remaining 80% of data aside for training in the limit of 10000 examples
    training_mask    = (df['rnd']<=0.8)
    df_training      =  df[training_mask]
    trainingRecordsCount = len(df_training)
    print "There are %d training examples with label %d" % (trainingRecordsCount,label)
    sampling_threshold = min(1,(1.0*train_per_class/trainingRecordsCount))*0.8
    print "Sampling threshold : %.10f" % (sampling_threshold)
    sampling_mask = (df_training['rnd']<=sampling_threshold)
    train_a = np.array(df_training[sampling_mask].values)
    print "Sampled %d examples" % (len(train_a))
    #train_a = np.array(df_training[:train_per_class].values)
    #train_b = sample(train_a, train_per_class)
    x_train = np.delete(train_a, np.s_[:10],1).astype('float')

    for i in range(0,len(x_train)):
        x_train[i] = sklearn.preprocessing.scale(x_train[i])
    for i in range(0,len(x_test)):
        x_test[i] = sklearn.preprocessing.scale(x_test[i])

    with open("training_rows#"+str(label),'wb') as fp:
        pickle.dump(x_train,fp)
    with open("test_rows#"+str(label),'wb') as fp:
        pickle.dump(x_test,fp)

    y_test  = np.ones((len(x_test),), dtype=np.int)*label
    y_train = np.ones((len(x_train),), dtype=np.int)*label

    if d_train_x == []:
        d_train_x = x_train
        d_train_y = y_train
        d_test_x  = x_test
        d_test_y  = y_test
    else:
        d_train_x = np.concatenate((d_train_x, x_train), axis=0)
        d_train_y = np.concatenate((d_train_y, np.ones((len(y_train),), dtype=np.int)*label), axis=0)
        d_test_x  = np.concatenate((d_test_x, x_test), axis=0)
        d_test_y  = np.concatenate((d_test_y, np.ones((len(y_test),), dtype=np.int)*label), axis=0)

d_learn = ((d_train_x,d_train_y),(d_test_x,d_test_y))

# <markdowncell>

# Let's confirm the size of our training and test sets.

# <codecell>

print "Training set : %d" % (len(d_learn[0][0]))
print "Test set : %d" % (len(d_learn[1][0]))

# <codecell>

import cPickle as pickle
with open("d_learn",'wb') as fp:
        pickle.dump(d_learn,fp)

# <markdowncell>

# d_learn dataset weighs 1.5 GB on disk

# <codecell>

d_learn

# <codecell>

fig = plt.figure()
rows = 5
cols = 5
for i in range(0,rows):
    for j in range(0,cols):
        ax = fig.add_subplot(rows,cols,i*rows+j)
        ax.set_xticks([])
        ax.set_yticks([])
        where = i*2000+j*100
        xo = d_learn[0][0][where]
        yo = 1/(1+exp(-xo))*255
        ax.set_title(str(where) + '->' + str(d_learn[0][1][where]))
        ax.imshow(reshape(yo,(34,56)), vmin = 0, vmax = 255)

# <codecell>

fig = plt.figure()
rows = 5
cols = 5
for i in range(0,rows):
    for j in range(0,cols):
        ax = fig.add_subplot(rows,cols,i*rows+j)
        ax.set_xticks([])
        ax.set_yticks([])
        where = 10000+i*1800+j*100
        xo = d_learn[0][0][where]
        yo = 1/(1+exp(-xo))*255
        ax.set_title(str(where) + '->' + str(d_learn[0][1][where]))
        ax.imshow(reshape(yo,(34,56)), vmin = 0, vmax = 255)

# <codecell>

fig = plt.figure()
rows = 5
cols = 5
for i in range(0,rows):
    for j in range(0,cols):
        ax = fig.add_subplot(rows,cols,i*rows+j)
        ax.set_xticks([])
        ax.set_yticks([])
        where = 18000+i*1800+j*100
        xo = d_learn[0][0][where]
        yo = 1/(1+exp(-xo))*255
        ax.set_title(str(where) + '->' + str(d_learn[0][1][where]))
        ax.imshow(reshape(yo,(34,56)), vmin = 0, vmax = 255)

# <codecell>

import theano
from theano.tensor.nnet import conv
import theano.tensor as T

rng = numpy.random.RandomState(23455)

# instantiate 4D tensor for input
input = T.tensor4(name='input')

# initialize shared variable for weights.
w_shp = (2, 3, 9, 9)
w_bound = numpy.sqrt(3 * 9 * 9)
W = theano.shared( numpy.asarray(
            rng.uniform(
                low=-1.0 / w_bound,
                high=1.0 / w_bound,
                size=w_shp),
            dtype=input.dtype), name ='W')

# initialize shared variable for bias (1D tensor) with random values
# IMPORTANT: biases are usually initialized to zero. However in this
# particular application, we simply apply the convolutional layer to
# an image without learning the parameters. We therefore initialize
# them to random values to "simulate" learning.
b_shp = (2,)
b = theano.shared(numpy.asarray(
            rng.uniform(low=-.5, high=.5, size=b_shp),
            dtype=input.dtype), name ='b')

# build symbolic expression that computes the convolution of input with filters in w
conv_out = conv.conv2d(input, W)

# build symbolic expression to add bias and apply activation function, i.e. produce neural net layer output
# A few words on ``dimshuffle`` :
#   ``dimshuffle`` is a powerful tool in reshaping a tensor;
#   what it allows you to do is to shuffle dimension around
#   but also to insert new ones along which the tensor will be
#   broadcastable;
#   dimshuffle('x', 2, 'x', 0, 1)
#   This will work on 3d tensors with no broadcastable
#   dimensions. The first dimension will be broadcastable,
#   then we will have the third dimension of the input tensor as
#   the second of the resulting tensor, etc. If the tensor has
#   shape (20, 30, 40), the resulting tensor will have dimensions
#   (1, 40, 1, 20, 30). (AxBxC tensor is mapped to 1xCx1xAxB tensor)
#   More examples:
#    dimshuffle('x') -> make a 0d (scalar) into a 1d vector
#    dimshuffle(0, 1) -> identity
#    dimshuffle(1, 0) -> inverts the first and second dimensions
#    dimshuffle('x', 0) -> make a row out of a 1d vector (N to 1xN)
#    dimshuffle(0, 'x') -> make a column out of a 1d vector (N to Nx1)
#    dimshuffle(2, 0, 1) -> AxBxC to CxAxB
#    dimshuffle(0, 'x', 1) -> AxB to Ax1xB
#    dimshuffle(1, 'x', 0) -> AxB to Bx1xA
output = T.nnet.sigmoid(conv_out + b.dimshuffle('x', 0, 'x', 'x'))

# create theano function to compute filtered images
f = theano.function([input], output)

# <codecell>

import cPickle as pickle
with open("d_learn",'rb') as fp:
        d_learn = pickle.load(fp)

# <codecell>

import pylab
from PIL import Image

fig = plt.gcf()
xo = d_learn[0][0][0]
yo = 1/(1+exp(-xo))*255
img = imshow(reshape(yo,(34,56)), vmin = 0, vmax = 255)
fig.savefig("img0.png",dpi=80)

img = Image.open("./img0.png")
#mg.getpixel(11)
img.getdata()
#np.array(img)
#img_ = img.swapaxes(0, 2).swapaxes(1, 2).reshape(1, 3, 56, 34)
#filtered_img = f(img_)

# plot original image and first and second components of output
#pylab.subplot(1, 3, 1); pylab.axis('off'); pylab.imshow(img)
#pylab.gray();
# recall that the convOp output (filtered image) is actually a "minibatch",
# of size 1 here, so we take index 0 in the first dimension:
#pylab.subplot(1, 3, 2); pylab.axis('off'); pylab.imshow(filtered_img[0, 0, :, :])
#pylab.subplot(1, 3, 3); pylab.axis('off'); pylab.imshow(filtered_img[0, 1, :, :])
#pylab.show()

# <codecell>

import _imaging

