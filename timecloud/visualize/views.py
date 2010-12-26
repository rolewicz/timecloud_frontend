from django.shortcuts import render_to_response
from django.template import RequestContext
from django.http import Http404, HttpResponsePermanentRedirect

def visualize(request, sensorName = None, chartName = None, startRow = "", stopRow = "", precision = "fp"):
    """
    Entry Function for visualizing data through a chart
    """
    
    avail_charts = ["areaChart",
                    "lineChart",
                    "barChart",
                    "smallMultiples",
                    "multipleLinesChart"]
    
    if sensorName :
        # if the visualization was triggerd from the display, we retrieve the
        # JSON data from the parameters
        if 'visualizeParams' in request.POST and request.POST['visualizeParams']:
            visualizeData = request.POST['visualizeParams']
            
            # Normalization of the chart type taken from the url
            if chartName not in avail_charts :
                raise Http404
            
            return render_to_response("visualize.tpl", 
                                      {"sensorName": sensorName,
                                       "chartName": chartName,
                                       "startRow": startRow,
                                       "stopRow": stopRow,
                                       "precision": precision,
                                       "data": visualizeData
                                       },
                                       context_instance=RequestContext(request))   
             
        # if the visualization was retrieved with the url we redirect to the
        # display, since there is no way of getting the selected columns
        else:
            
            redirectToURL = "/display/"+sensorName
            if startRow :
                redirectToURL += "/"+precision+"-"+startRow+"-"+stopRow
                
            return HttpResponsePermanentRedirect(redirectToURL)
    else:
        raise Http404
    