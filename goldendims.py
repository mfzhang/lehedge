from math import *

def notAnInteger(n):
    return fmod(n,1)!=0

class GoldenRectangle:

    def __init__(self, s ):
        # golden number
        self.r = (1+sqrt(5))/2
        self.s = float(s)
        self.minRatio = 1
        self.maxRatio = s

    def dimensions(self):
        oneSide = self.give_me_one_side()
        otherSide = int(self.s/oneSide)
        return (oneSide,otherSide)

    def give_me_one_side(self):
        x0 = int(sqrt(self.s * self.r))
        #print "x0=%d" % x0
        leftHit = self.left_search(x0)
        rightHit = self.right_search(x0+1)
        if ( leftHit ==0 ):
            if( rightHit == 0):
                return 0
            else:
                return rightHit
        elif (rightHit == 0):
            return leftHit
        else:
            leftOtherSide = self.s/leftHit
            rightOtherSide = self.s/rightHit
            if leftHit > leftOtherSide:
                leftRatio = leftHit/leftOtherSide
            else:
                leftRatio = leftOtherSide/leftHit
            if rightHit > rightOtherSide:
                rightRatio = rightHit/rightOtherSide
            else:
                rightRatio = rightOtherSide/rightHit
            leftDiff = abs(self.r-leftRatio)
            rightDiff = abs(self.r-rightRatio)
            #print "Delta to golden number: left = %2f, right = %2f" % (leftDiff,rightDiff)
            if( leftDiff < rightDiff) :
                return leftHit
            else: return rightHit


    def left_search(self, a):
        #print "a = %d" % (a)
        lowerBound = 0
        while a > lowerBound :
            if ((a*a)/self.s >= self.minRatio ):
                if( notAnInteger(self.s/a) ):
                    a = a - 1
                else: break
            else: return 0
        return a

    def right_search(self, a):
        #print "a = %d" % (a)
        upperBound = self.s
        while a < upperBound:
            if( (a*a)/self.s <= self.maxRatio ):
                if ( notAnInteger(self.s/a) ):
                    a = a + 1
                else: break
            else: return 0
        return a


