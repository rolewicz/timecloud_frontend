from django.shortcuts import render_to_response
from django.template import RequestContext
from django.utils import simplejson
from django.http import HttpResponse, Http404
from timecloud.sensorList.models import Sensor

#############
# Synchronous
#############
def sensorList(request):
    """
    Displays the list of sensor registred on the system
    """
    
    errors = []
    
    if 'sensorListErrors' in request.POST and request.POST['sensorListErrors']:
            errors.extend(simplejson.loads(request.POST['sensorListErrors']))

    # We get the list of Sensor objects from the sqlite database
    sensor_list = Sensor.objects.all().values();
    
    sl = []
    
    # From it we compute a json formattable data structure
    for s in sensor_list:
        sl.append(s)
    
    return render_to_response("sensorList.tpl", 
                              {"sensorList": simplejson.dumps({"result":sl}),
                               "errors": errors}, 
                      context_instance=RequestContext(request))

#############
# Asynchronous
#############
def updateSensorList(request):
    """
    Asynchronous method used to update the sensor table values by sending
    a json-formatted string containing the data to the client
    """
    
    response_dict = {"result":[],
                     "errors": []}
    
    # Parameter differentiating an async from a sync request
    xhr = request.POST.has_key('xhr')
    
    if request.method == 'POST' and xhr:
        # If the user specified a search term, we filter the results
        if request.POST.has_key('search'):
            searchTerm = request.POST['search']
            
            sensor_list = Sensor.objects.filter(name__contains=searchTerm).values()
            
        else :
            sensor_list = Sensor.objects.all().values();
        
            
        sl = []
        
        # From it we compute a json formattable data structure
        for s in sensor_list:
            sl.append(s)
            
        response_dict["result"] = sl
        
        return HttpResponse(simplejson.dumps(response_dict), mimetype='application/javascript');

    else :
        raise Http404
    