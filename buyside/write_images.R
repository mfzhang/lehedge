write_pngs('buyside/img/train/',
           all_records[! all_records %in% buy.validation],
           EURUSD.ask.scaled.sigmoid,
           EURJPY.ask.scaled.sigmoid,
           USDJPY.ask.scaled.sigmoid)

write_pngs('buyside/img/val/',
           buy.validation,
           EURUSD.ask.scaled.sigmoid,
           EURJPY.ask.scaled.sigmoid,
           USDJPY.ask.scaled.sigmoid)
