__author__ = 'francoislelay'

from goldendims import *
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from pylab import *
import sklearn.preprocessing



N = 1000
X = np.arange(N)
Y = np.zeros(N)
Y2 = np.zeros(N)

for n in X:
    gr = GoldenRectangle(n+1).dimensions()
    Y[n] = float(gr[0])/gr[1]
    if( Y[n] < 150 ):
        Y2[n] = Y[n]
    else: Y2[n]=0
    print "%d %2f" % (n, Y[n])

Z = sklearn.preprocessing.scale(Y)

plot(X, Y2)
show()
#hist(Z,100)
#show()

