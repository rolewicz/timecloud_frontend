import cPickle
from django.shortcuts import render_to_response
from django.template import RequestContext
from timecloud.lib.HBaseClient.ThriftClient.HBaseThriftClient import HBaseThriftClient
from django.utils import simplejson
from django.http import HttpResponse, Http404
from django.core.exceptions import MultipleObjectsReturned, ObjectDoesNotExist
from timecloud.sensorList.models import Sensor
from timecloud import utils

###################
# Utility Functions
###################
def trunc(f, n):
    '''Truncates/pads a float f to n decimal places without rounding'''
    slen = len('%.*f' % (n, f))
    return str(f)[:slen]

def computeValue(paramStr, time, precision):
    result = 0
    
    if precision == "lm":
        beginVal, slope = paramStr.split(':')
        beginVal = float(beginVal)
        slope = float(slope)
        result = beginVal + time*slope
    if precision == "cm":
        result = float(paramStr)
    
    # We truncate approximated values to 3 decimals
    return trunc(result,3)

def formatData(resultData, sensor, startTs, stopTs, precision):
    
    # Check if the first timestamp we get is meaningful
    if startTs:
        if int(startTs) < int(sensor.firstTs):
            startTs = sensor.firstTs
    else :
        startTs = sensor.firstTs
    
    if not stopTs:
        stopTs = str(int(startTs) + utils.DEFAULT_TIME_INT)
        
    # Get the column steps
    colSteps = cPickle.loads(str(sensor.steps))
    
    # Get the column names.
    colNames = resultData["colNames"]
    
    ## Initializing structures for making us creating a result data
    ## structure with approximated values
    
    # Dict containing the latest timestamps at which we encounter values 
    # for each column. We initialize it with the starting timestamp of the
    # data we want to retrieve, so that we don't generate values 
    # occurring before this timestamp 
    latestTimes = {}
    
    # Structure that we will populate to compute our final list
    # of values
    resultDict = {}
    
    # Init the latest timestamps
    for cn in colNames:
        latestTimes[cn] = int(startTs) - 1
    
    # Populate the data structure   
    for row in resultData["rows"] :
        for cn in row["columns"].keys():
            # Get the latest time for the given column
            latestTime = latestTimes[cn]
            
            # Initializes the timestamp as being the one of the row
            timestamp = int(row["id"])
            
            # If the timestamp is after the stopRow, we align directly with
            # the stop timestamp
            if timestamp > int(stopTs):
                timestamp = int(utils.alignTs(stopTs, sensor.firstTs, sensor.recInt))
                
            # As long as our timestamp is below the timestamp of the
            # preceding value in the table for this column, we
            # compute values and put them into our data structure
            while(timestamp > latestTime):
                ts = str(timestamp)
                if ts not in resultDict:
                    resultDict[ts] = {"id": ts, "columns": {}}
                resultDict[ts]["columns"][cn] = computeValue(row["columns"][cn], timestamp, cn[:2])
                timestamp -= colSteps[cn[3:]]
                
            latestTimes[cn] = int(row["id"])
            
    
    # We get the values of the data structure (since it is a dict),
    # and sort them into a list in ascending order of timestamps
    resultData = {"rows": sorted(resultDict.values(), key = lambda row: int(row["id"])),
                  "colNames": colNames}

    return resultData


#############
# Synchronous
#############
def display(request, sensorName=None, startRow = "", stopRow = "", precision = "lm"):
    """
    View for displaying the list of tables available or the content
    of the table to the user
    """
    
    errors = []
    
    if 'displayErrors' in request.POST and request.POST['displayErrors']:
            errors.extend(simplejson.loads(request.POST['displayErrors']))

    # If a table name is given, we display the content of the table.
    if sensorName:
        
        try:
            s = Sensor.objects.get(name=sensorName)
        except MultipleObjectsReturned:
            errors.append("Woops! The sensor name isn't a primary key ?")
        except ObjectDoesNotExist:
            s = None
        
        if s:    
            # Construct the column names list from the sensor steps attribute
            columns = []
            for colName in cPickle.loads(str(s.steps)).keys():
                columns.append(precision+":"+colName)
                
            if precision != "fp" :
                result = getModelRows(utils.TABLE_NAME, sensorName, columns, startRow, stopRow)
                result = formatData(result, s, startRow, stopRow, precision)
            else :
                result = getRows(utils.TABLE_NAME, sensorName, [precision], startRow, stopRow)
                
            return render_to_response("display.tpl", 
                                      {"sensorName": sensorName,
                                       "colNames": simplejson.dumps(result["colNames"]),
                                       "startRow": startRow, 
                                       "stopRow": stopRow,
                                       "precision": precision,
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
            stopRow = request.POST.get('stopRow', "")
            precision = request.POST.get('precision', "fp")
            
            # Get the queryset and convert it to a list
            # sl = list(Sensor.objects.order_by("name"))
        
            try:
                s = Sensor.objects.get(name=sensorName)
            except MultipleObjectsReturned:
                response_dict["errors"].append("Woops! The sensor name isn't a primary key ?")
            except ObjectDoesNotExist:
                response_dict["errors"].append("The given sensor doesn't exist.")
                s = None
            
            if s:    
                # Construct the column names list from the sensor steps attribute
                columns = []
                for colName in cPickle.loads(str(s.steps)).keys():
                    columns.append(precision+":"+colName)
                    
                if precision != "fp":
                    result = getModelRows(utils.TABLE_NAME, sensorName, columns, startRow, stopRow)
                    result = formatData(result, s, startRow, stopRow, precision)
                else:    
                    result = getRows(utils.TABLE_NAME, sensorName, [precision], startRow, stopRow)
                
                # Set the value in the response dict
                response_dict["result"]["rows"] = result["rows"]
                response_dict["result"]["colNames"] = result["colNames"]
            
        else :
            response_dict["errors"].append("Async request failed: No table name specified.")
        
        return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript');

    else :
        raise Http404
        
def getRows(tableName, sensorName, columns, startRow, stopRow):
    """
    Utility method for getting the rows from one timestamp to another. This
    method is mainly used for retrieving full precision values
    """
    
    # If we use a default startRow, we force the stopRow to
    # be the default time interval
    if startRow == "":
        stopRow = utils.DEFAULT_TIME_INT
        
    client = HBaseThriftClient()
    client.connect()
    
    result = client.extendedScan(tableName, sensorName+":", columns, startRow, stopRow)

    client.disconnect()
    
    return result

def getModelRows(tableName, sensorName, columns, startRow, stopRow):
    """
    Utility method for getting the rows from one timestamp to another. This
    method is mainly used for retrieving model-approximated values.
    """
    
    # If we use a default startRow, we force the stopRow to
    # be the default time interval    
    if startRow == "":
        stopRow = utils.DEFAULT_TIME_INT
        
    client = HBaseThriftClient()
    client.connect()
    
    result = client.modelScan(tableName, sensorName+":", columns, startRow, stopRow)

    client.disconnect()
    
    return result
