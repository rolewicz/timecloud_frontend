from django.shortcuts import render_to_response
from django.template import RequestContext
from timecloud.lib.HBaseClient.ThriftClient.HBaseThriftClient import HBaseThriftClient
from django.utils import simplejson
from django.http import HttpResponse, Http404, HttpResponsePermanentRedirect

#############
# Synchronous
#############
def display(request, tableName=None, startRow = "", numRows = 100):
    """
    View for displaying the list of tables available or the content
    of the table to the user
    """
    
    errors = []
    
    if 'displayErrors' in request.POST and request.POST['displayErrors']:
            errors.extend(simplejson.loads(request.POST['displayErrors']))

    # If a table name is given, we display the content of the table.
    # If not, we display the list of tables available for the user.
    if tableName:
        
#        colFamNames = getColFamilyNames(tableName)
        result = getRows(tableName, [], startRow, numRows)
        
        return render_to_response("display.tpl", 
                                  {"tableName": tableName,
                                   "columnNames": result["colNames"],
                                   "colNames": simplejson.dumps(result["colNames"]),
                                   "startRow": startRow, 
                                   "numRows": numRows,
                                   "jsonRows": simplejson.dumps({"result":result["rows"]}),
                                   "errors": errors}, 
                              context_instance=RequestContext(request))
        
    else:
        return render_to_response("display.tpl",
                                  {"errors": errors},
                              context_instance=RequestContext(request))
            
##############
# Asynchronous
##############

def updateTable(request):
    """
    Asynchronous method used to update the data table values by sending
    a json-formatted string containing the data to the client
    """
    response_dict = {"result":{"rows":[],
                               "colNames":[]},
                     "errors": []}
    
    # Parameter differentiating an async from a sync request
    xhr = request.POST.has_key('xhr')
    
    if request.method == 'POST' and xhr:
        
        if request.POST.has_key('tableName'):
            tableName = request.POST['tableName']
            
            startRow = request.POST.get('startRow', "")
            numRows = request.POST.get('numRows', 100)
            
            result = getRows(tableName, [], startRow, numRows)
            
            # Set the value in the response dict
            response_dict["result"]["rows"] = result["rows"]
            response_dict["result"]["colNames"] = result["colNames"]
            
        else :
            response_dict["errors"].append("Async request failed: No table name specified.")
        
        return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript');

    else :
        raise Http404
    
#def updateTable(request):
#    """
#    Asynchronous method used to update the data table values by sending
#    a json-formatted string containing the data to the client
#    """
#    xhr = request.GET.has_key('xhr')
#    
#    if request.method == 'POST' and xhr:
#        
#        response_dict = {}
#        form = FilterForm(request.POST)
#        if form.is_valid():
#            cd = form.cleaned_data
#        
#            tableName = cd['tableName']
#            columns =  cd['columns']
#            startRow = cd['startRow']
#            numRows = cd ['numRows']
#            response_dict.update({'tableName': cd['tableName'],
#                                  'columns': cd['columns'],
#                                  'startRow': cd['startRow'],
#                                  'numRows': cd['numRows']})
#            response_dict.update({'success': True})
#            
#        else:
#            response_dict.update({'errors': form.errors})
#            
#        if xhr:
#            return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript')
#        return render_to_response('weblog/ajax_example.html', response_dict)
#    else:
#        form = FilterForm()
#    return render_to_response('display.tpl', {'filterForm': form})
#
#    if not request.POST:
#        return render_to_response("display.tpl",
#                              context_instance=RequestContext(request))
#        
#    xhr = request.GET.has_key('xhr')
#    response_dict = {}
#    tableName = request.POST.get('tableName', False)
#    columns = request.POST.get('columns', [])
#    startRow = request.POST.get('startRow', "")
#    numRows = request.POST.get('numRows', 100)
#    
#    #name = request.POST.get('name', False)
#    #total = request.POST.get('total', False)
#    response_dict.update({'tableName': tableName,
#                          'columns': columns,
#                          'startRow': startRow,
#                          'numRows': numRows})
#    if numRows:
#        try:
#            numRows = int(numRows)
#        except:
#            numRows = False
#    if tableName and numRows :
#        
#        response_dict.update({'success': True})
#    else:
#        response_dict.update({'errors': {}})
#        if not tableName:
#            response_dict['errors'].update({'tableName': 'This field is required'})
#        if not total and total is not False:
#            response_dict['errors'].update({'total': 'This field is required'})
#        elif int(total) != 10:
#            response_dict['errors'].update({'total': 'Incorrect total'})
#    if xhr:
#        return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript')


def getColFamilyNames(tableName):
    
    #TODO: Add error handling (print of error messages)
    
    client = HBaseThriftClient()
    client.connect()
    
    colDescriptors = client.getColumnDescriptors(tableName)

    client.disconnect()
    
    return colDescriptors.keys()
        
def getRows(tableName, columns, startRow, numRows):
    
    #TODO: Add error handling (print of error messages) + see if startRow exists
    client = HBaseThriftClient()
    client.connect()
    
    result = client.extendedScan(tableName, columns, startRow, numRows)

    client.disconnect()
    
    return result
