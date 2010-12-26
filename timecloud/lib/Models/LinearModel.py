'''
Created on Dec 17, 2010

@author: Ian Rolewicz
'''

import math

class LinearModel():
    '''
    Class defining a linear regression model with
    methods applicable to it
    '''


    def __init__(self):
        self.values = []
        self.sumX = 0.0
        self.sumY = 0.0
        self.beginVal = 0.0
        self.slope = 0.0
        self.maxDist = 0.0
    
    
    def getBeginVal(self):
        """
        Get the begin value of the linear approximation
        """    
        return self.beginVal
        
    def getSlope(self):
        """
        Get the slope of the linear approximation
        """
        return self.slope

    def getMaxDist(self):
        """
        Get the maximum distance between one of the y's
        and the linear approximation
        """
        return self.maxDist
    
    def getFormattedValues(self):
        """
        Get the values as a formatted string
        """
        return  str(self.beginVal)+":"+str(self.slope)
            
    def add(self, x, y):
        """
        Add an x and y values and updates the model
        @return: A dict containing the newly computed
            begin value, slope and maximum distance
        """
        
        # Append to the end of the values list
        self.values.append((x,y))
        
        # Updates the sum of x's and y's
        self.sumX += x
        self.sumY += y
        
        xMean = self.sumX/len(self.values)
        yMean = self.sumY/len(self.values)
        
        # Compute the slope and begin value
        xSquareMean = 0.0
        #ySquareMean = 0.0
        xyMean = 0.0
        
        if len(self.values) < 2:
            return {"beginValue": yMean, "slope": 0.0 , "maxDist": 0.0}
        
        for xy in self.values :
            x, y = xy
            xSquareMean += (x - xMean) * (x - xMean);
            #ySquareMean += (y[i] - ybar) * (y[i] - ybar);
            xyMean += (x - xMean) * (y - yMean);
            
        self.slope = xyMean / xSquareMean;
        self.beginVal = yMean - self.slope * xMean;
        
        # Compute the new maximal distance
        for xy in self.values :
            x, y = xy
            dist = math.fabs(self.beginVal + self.slope*x - y)
            if dist > self.maxDist:
                self.maxDist = dist
            
        return {"beginValue": self.beginVal, "slope": self.slope , "maxDist": self.maxDist}
    
    def reset(self):
        """
        Reset the attributes of the object
        """
        self.values = []
        self.sumX = 0.0
        self.sumY = 0.0
        self.beginVal = 0.0
        self.slope = 0.0
        self.maxDist = 0.0
        