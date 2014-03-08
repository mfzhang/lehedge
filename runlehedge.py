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

