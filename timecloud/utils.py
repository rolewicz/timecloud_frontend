'''
Created on Nov 1, 2010

@author: Ian Rolewicz

Contains a series of helping constants and parameters for the interface.
'''

import math

###
### Main Table Name
###
TABLE_NAME = "mainTable"

###
### Default time interval for data retrieval
###
DEFAULT_TIME_INT = 2000000

# Utility method for aligning a timestamp on the recording frequency of the sensor.
# This is used to simplify our model-based approximations
def alignTs(timestamp, firstTs, recInt):
    res = (float(timestamp)-float(firstTs))/recInt
    fract, integ = math.modf(res)
    if fract >= 0.5:
        return str(int(firstTs) + int(integ+1) * recInt)
    else :
        return str(int(firstTs) + int(integ) * recInt)
                 
###                                      
### Context Processors
###
def globalMenu(self):
    """
    A context processor for the links in the global menu
    """
    
    return {"globalLinkList" : [{'name': 'Home', 'url':'/welcome'},
                      {'name': 'Tables', 'url':'/sensorList'},
                      {'name': 'My Account', 'url':'/manage'},
                      {'name': 'About', 'url':'/about'}]}
