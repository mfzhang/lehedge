from math import *

def notAnInteger(n):
    return fmod(n,1)!=0

class GoldenRectangle:

    def __init__(self, s, minRatio, maxRatio ):
        # golden number
        self.r = (1+sqrt(5))/2
        self.s = float(s)
        self.minRatio = minRatio
        self.maxRatio = maxRatio


    def dimensions(self):
        x0 = int(sqrt(self.s * self.r))
        print "x0=%d" % x0
        Lg = self.xg(x0)
        # lg = self.s/Lg
        # leftDiff = self.r-Lg/lg
        Ld = self.xd(x0+1)
        # ld = self.s/Ld
        # rightDiff = Ld/ld-self.r
        if ( Lg ==0 ):
            if( Ld == 0):
                return 0
            else:
                return Ld
        elif (Ld == 0):
            return Lg
        else:
            lg = self.s/Lg
            leftDiff = self.r-Lg/lg
            ld = self.s/Ld
            rightDiff = Ld/ld-self.r
            if( leftDiff < rightDiff) :
                return Lg
            else: return Ld

        #        elif (leftDiff < rightDiff):
        #             return Lg
        #         else:
        #             return Ld

    def xg(self, a):
        print "a = %d" % notAnInteger(self.s/a)
        if ((a*a)/self.s >= self.minRatio ):
            if( notAnInteger(self.s/a) ):
                return self.xg(a-1)
            else: return a
        else: return 0

        #        if ( notAnInteger(self.s/a) and ((a*a)/self.s >= self.minRatio) ):
        #             print "xg1 %d" % (a)
        #             return self.xg(a-1)
        #         elif ((a*a)/self.s >= self.minRatio):
        #             print "xg2 %d" % (a)
        #             return  a
        #         else: return 0

    def xd(self, a):
        if( (a*a)/self.s <= self.maxRatio ):
            if ( notAnInteger(self.s/a) ):
                return self.xd(a+1)
            else: return a
        else: return 0
        #        if ( notAnInteger(self.s/a) and ((a*a)/self.s <= self.maxRatio) ):
        #            print "xd1 & %d" % (a)
        #            return self.xd(a+1)
        #        elif ((a*a)/ self.s <= self.maxRatio) :
        #            print "xd2 # %d" % (a)
        #            return a
        #        else: return 0

GoldenRectangle(1880,1.5,1.7).dimensions()
