Analysis of experiments
========================================================

## Dataset #1

- found in /data/1
- images are RGB PNG files of wxh=100*106
- 161947 training images
- 17994 validation images

### Experiment 1 

First attempts would show no accuracy improvements in the early iterations.
Trying over and over again, the random weights used to initialize the network finally allowed the network to start learning. I don't have the random seed used to be able to reproduce and compare different learning policies.



```r
d <- read.table('1/accuracy.txt',stringsAsFactors=FALSE)
plot(row.names(d),d$V1, pch=3, xlab="Iterations (thousands)",ylab="Test Net Accuracy",  main="lr = 2e-6 (fixed policy)")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.png) 

This is quite nice. Remember the rules of the game : I place bets on 3 linked currency pairs. There are 18 possibilities, so I could be wrong 94.5% of the time by placing a purely random bet. Instead this classifier reduces that probability to 57%.

### Experiment 2

I am wondering what would be the learning curve if I decrease my learning rate after 100K iterations.
We will multiply the learning rate by 0.4 every 100K iters.


```r
d <- read.table('2/accuracy.txt',stringsAsFactors=FALSE)
plot(row.names(d),d$V1, pch=3, xlab="Iterations (thousands)",ylab="Test Net Accuracy",  main="lr = 2e-6,8e-7,3.2e-7,1.28e-7,5.12e-8 (step policy)")
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.png) 



