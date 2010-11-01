'''
Created on Nov 1, 2010

@author: Ian Rolewicz

Contains a series of helping constants and parameters for the interface.
'''
                      
###                                      
### Context Processors
###
def globalMenu(self):
    """
    A context processor for the links in the global menu
    """
    
    return {"globalLinkList" : [{'name': 'Home', 'url':'/welcome'},
                      {'name': 'Tables', 'url':'/display'},
                      {'name': 'My Account', 'url':'/manage'},
                      {'name': 'About', 'url':'/about'},
                      {'name': 'Admin', 'url':'/admin'}]}
