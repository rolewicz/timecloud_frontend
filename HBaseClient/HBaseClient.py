'''
Created on Oct 15, 2010

@author: Ian Rolewicz
'''

class HBaseClient(object):
    '''
    Base Class defining a Client interface for querying an HBase instance.
    '''

    def __init__(self, host = 'localhost', port = 9090):
        '''
        Constructor
        '''
        self.host = host
        self.port = port
        
    def connect(self):
        '''
        Establishes a connection to the HBase Instance
        '''
    
    def disconnect(self):
        '''
        Closes the connection to the HBase Instance
        '''
        
    
    