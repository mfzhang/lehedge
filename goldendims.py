from math import *

class GoldenRectangle:

    def __init__(self, s, minRatio, maxRatio ):
        # golden number
        self.r = (1+sqrt(5))/2
        self.s = s
        self.minRatio = minRatio
        self.maxRatio = maxRatio

    def dimensions(self):
        x0 = floor(sqrt(self.s * self.r))
        return (self.xg(x0), self.xd(x0+1))

    def xg(self, a):
        ret = 0
        if ( (fmod(self.s,a)!=0) and ((a*a)/self.s>=self.minRatio) ):
            ret = self.xg(a-1)
        else:
            if ((a*a)/self.s >= self.minRatio):
                ret = a
        return ret


    def xd(self, a):
        ret = 0
        if ( (fmod(self.s,a)!=0) and ((a*a)/self.s <= self.maxRatio) ):
            self.xd(a+1)
        else:
            if ((a*a)/ self.s <= self.maxRatio) :
                ret = a
        return ret

GoldenRectangle(1880,1.5,1.7).dimensions()
