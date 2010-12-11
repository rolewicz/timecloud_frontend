from django.shortcuts import render_to_response
from django.template import RequestContext
from timecloud.lib.HBaseClient.ThriftClient.HBaseThriftClient import HBaseThriftClient
from django.utils import simplejson
from django.http import HttpResponse, Http404
from django.core.exceptions import MultipleObjectsReturned, ObjectDoesNotExist
from timecloud.sensorList.models import Sensor
from timecloud import utils

#############
# Synchronous
#############
def display(request, sensorName=None, startRow = "", numRows = 100):
    """
    View for displaying the list of tables available or the content
    of the table to the user
    """
    
    errors = []
    
    if 'displayErrors' in request.POST and request.POST['displayErrors']:
            errors.extend(simplejson.loads(request.POST['displayErrors']))

    # If a table name is given, we display the content of the table.
    if sensorName:
        
        # Get the queryset and convert it to a list
        sl = list(Sensor.objects.order_by("name"))
    
        try:
            s = Sensor.objects.get(name=sensorName)
        except MultipleObjectsReturned:
            errors.append("Woops! The sensor name isn't a primary key ?")
        except ObjectDoesNotExist:
            s = None
        
        if s:    
            try:
                # Retrieve the next sensorId and sets it as a stop row
                stopRow = sl[sl.index(s)+1].name
            except:
                stopRow = None
                
            result = getRows(utils.TABLE_NAME, sensorName, [], startRow, numRows, stopRow)
            
            return render_to_response("display.tpl", 
                                      {"sensorName": sensorName,
                                       "columnNames": result["colNames"],
                                       "colNames": simplejson.dumps(result["colNames"]),
                                       "startRow": startRow, 
                                       "numRows": numRows,
                                       "jsonRows": simplejson.dumps({"result":result["rows"]}),
                                       "errors": errors}, 
                                  context_instance=RequestContext(request))
        else:
            raise Http404
    else:
        raise Http404
            
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
        
        if request.POST.has_key('sensorName'):
            sensorName = request.POST['sensorName']
            
            startRow = request.POST.get('startRow', "")
            numRows = request.POST.get('numRows', 100)
                    # Get the queryset and convert it to a list
            sl = list(Sensor.objects.order_by("name"))
        
            try:
                s = Sensor.objects.get(name=sensorName)
            except MultipleObjectsReturned:
                response_dict["errors"].append("Woops! The sensor name isn't a primary key ?")
            except ObjectDoesNotExist:
                response_dict["errors"].append("The given sensor doesn't exist.")
                s = None
            
            if s:    
                try:
                    # Retrieve the next sensorId and sets it as a stop row
                    stopRow = sl[sl.index(s)+1].name
                except:
                    stopRow = None
                    
                result = getRows(utils.TABLE_NAME, sensorName, [], startRow, numRows, stopRow)
                
                # Set the value in the response dict
                response_dict["result"]["rows"] = result["rows"]
                response_dict["result"]["colNames"] = result["colNames"]
            
        else :
            response_dict["errors"].append("Async request failed: No table name specified.")
        
        return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript');

    else :
        raise Http404

def getColFamilyNames(tableName):
    
    #TODO: Add error handling (print of error messages)
    
    client = HBaseThriftClient()
    client.connect()
    
    colDescriptors = client.getColumnDescriptors(tableName)

    client.disconnect()
    
    return colDescriptors.keys()
        
def getRows(tableName, sensorName, columns, startRow, numRows, stopRow = None):
    
    client = HBaseThriftClient()
    client.connect()
    
    result = client.extendedScan(tableName, sensorName+":", columns, startRow, numRows, stopRow)

    client.disconnect()
    
    return result
