from lehedge import *

audusd = CurrencyData("./$AUDUSD.Ask.txt",10000)
audusd.load_historical_data()
audusd.compute_forward_window_length()
audusd.filter_incomplete_duration()
audusd.filter_incomplete_profit()
audusd.create_backward_windows()
audusd.build_datasets()
audusd.plot_images()
#audusd.plot_images(10000,1800,100)
#audusd.plot_images(18000,1800,100)

eurusd = CurrencyData("./$EURUSD.Ask.txt",10000)
eurusd.load_historical_data()
eurusd.compute_forward_window_length()
eurusd.filter_incomplete_duration()
eurusd.filter_incomplete_profit()
eurusd.create_backward_windows()
eurusd.build_datasets()
eurusd.plot_images()



d_learn_1 = audusd.d_learn[0][0] #((d_train_x, d_train_y), (d_test_x, d_test_y))
d_learn_2 = eurusd.d_learn[0][0]
