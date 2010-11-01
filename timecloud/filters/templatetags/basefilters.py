'''
Created on Nov 5, 2010

@author: Ian Rolewicz

Module defining additional filters for the django template

'''

from django import template

register = template.Library()

############################
# Filters over dictionnaries
############################

@register.filter
def keys(dict):
    """
    Returns the list of keys of the given dictionnary
    """
    return dict.keys()

@register.filter
def items(dict):
    """
    Returns the list of key, value pairs for the given dictionnary
    """
    return dict.items()

@register.filter
def value(dict, key):
    """
    Returns the value corresponding to the given key in the given dictionnary
    """
    return dict[key]

@register.filter
def cellValue(row, col):
    """
    Returns the value corresponding to the given column at the given row
    """
    return row[col]["value"]

@register.filter
def cellTs(row, col):
    """
    Returns the timestamp of the cell corresponding to the given column at 
    the given row
    """
    return row[col]["timestamp"]
