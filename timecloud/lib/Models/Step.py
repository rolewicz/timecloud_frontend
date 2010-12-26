'''
Created on Dec 19, 2010

@author: Ian Rolewicz
'''
import math

class Step():
    '''
    Utility classe for computing the step of a column.
    We use it also for keeping track of the first timestamp
    that holds a value for this column.
    '''

    def __init__(self):
        self.diffSum = 0
        self.numDiffs = -1
        self.latestTs = 0
        
    def getAvgStep(self, multiple = None):
        # If a multiple is specified, we return the step as the
        # mean of all steps rounded to the closest multiple
        if multiple:
            if self.numDiffs > 0:
                res = (1.0*self.diffSum/self.numDiffs)/(1.0*multiple)
                fract, integ = math.modf(res)
                if fract >= 0.5:
                    return int(integ+1) * multiple
                else :
                    return int(integ) * multiple
            else:
                return self.diffSum
        else:
            return self.diffSum/self.numDiffs if self.numDiffs > 0 else self.diffSum
    
    def getFirstTs(self):
        return self.firstTs
    
    def add(self, ts):
        if self.numDiffs > -1:
            self.diffSum += (ts - self.latestTs)
        self.latestTs = ts
        self.numDiffs += 1
    
        