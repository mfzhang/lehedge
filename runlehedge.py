from lehedge import *
import numpy as np
import goldendims as gd


ask = {"./AUDUSD.Ask.Test.txt":10000,
       "./EURUSD.Ask.Test.txt":10000,
       "./USDJPY.Ask.Test.txt":100}

min_train_size = 10000000
min_window_size = 10000000
d=[]

for (f,tick_res) in ask.iteritems():
    pair = CurrencyData(f,tick_res)
    pair.load_historical_data()
    pair.compute_forward_window_length()
    pair.filter_incomplete_duration()
    pair.filter_incomplete_profit()
    pair.create_backward_windows()
    pair.build_datasets()
    pair.plot_images()
    if ( len(pair.d_learn[0][0]) < min_train_size ): min_train_size =len(pair.d_learn[0][0])
    if ( len(pair.d_learn[0][0][0]) < min_window_size ): min_window_size =len(pair.d_learn[0][0][0])
    d.append(pair.d_learn)

common = np.zeros((min_train_size,min_window_size,3))

for i in range(0,min_train_size):
    for j in range(0, min_window_size):
        common[i][j][0] = 1 / (1 + np.exp(-d[0][0][0][i][j]))
        common[i][j][1] = 1 / (1 + np.exp(-d[1][0][0][i][j]))
        common[i][j][2] = 1 / (1 + np.exp(-d[2][0][0][i][j]))


selection = np.random.choice(min_train_size,25)
fig = plt.figure()
rows = 5
cols = 5
dims = gd.GoldenRectangle(min_window_size).dimensions()
print dims
for i in range(0, rows):
    for j in range(0, cols):
        ax = fig.add_subplot(rows, cols, i * rows + j)
        ax.set_xticks([])
        ax.set_yticks([])
        where = selection[i*rows+j]
        #print "image length=%d" % (len(yo))
        ax.set_title('')
        ax.imshow(np.reshape(common[where], (dims[0],dims[1],3)))
        plt.savefig('common.png')
