'''
Created on Nov 8, 2010

@author: Ian Rolewicz

A collection of forms for the display application.
'''
from django import forms

class FilterForm(forms.Form):
    columns = forms.CheckboxSelectMultiple()
    startRow = forms.CharField(required=False)
    numRows = forms.IntegerField(required=False)
    
