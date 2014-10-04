Experiment #1
========================================================

## Dataset

```
crossgradient-1:caffe9 francoislelay$ wc -l lehedge_validation.v4.txt 
   17994 lehedge_validation.v4.txt
crossgradient-1:caffe9 francoislelay$ wc -l lehedge_training.v4.txt 
  161947 lehedge_training.v4.txt
```

First attempts would show no accuracy improvements in the early iterations.
Trying over and over again, the random weights used to initialize the network finally allowed the network to start learning. I don't have the random seed used to be able to reproduce and compare different learning policies.



```r
d <- read.table('accuracy.2.txt',stringsAsFactors=FALSE)
plot(row.names(d),d$V1, pch=3, xlab="Iterations (thousands)",ylab="Test Net Accuracy",  main="lr = 2e-6 (fixed policy)")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.png) 

This is quite nice. Remember the rules of the game : I place bets on 3 linked currency pairs. There are 18 possibilities, so I could be wrong 

Next experiment : I am wondering what would be the learning curve if I decrease my learning rate after 100K iterations.
