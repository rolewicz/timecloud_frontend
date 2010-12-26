'''
Created on Dec 17, 2010

@author: Ian Rolewicz
'''

import math

class ConstantModel():
    '''
    Class defining a linear regression model with
    methods applicable to it
    '''

    def __init__(self):
        self.values = []
        self.valSum = 0.0
        self.mean = 0.0
        self.maxDist = 0.0
    
    def getConstVal(self):
        """
        Get the begin value of the linear approximation
        """    
        return self.constVal
        
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
        return  str(self.mean)
       
    def add(self, y):
        """
        Add a y value and updates the model
        @return: A dict containing the newly computed
            approximated constant value and maximum distance
        """
        # Append the value
        self.values.append(y)
        
        # Compute the new mean
        self.valSum += y
        self.mean = self.valSum/len(self.values)
        
        # Compute the new maximal distance
        for v in self.values :
            dist = math.fabs(v-self.mean)
            if dist > self.maxDist :
                self.maxDist = dist
                
        return {"value": self.mean, "maxDist": self.maxDist}
        
    def reset(self):
        """
        Reset the attributes of the object
        """
        self.values = []
        self.valSum = 0.0
        self.mean = 0.0
        self.maxDist = 0.0
        