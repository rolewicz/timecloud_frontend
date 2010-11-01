from django.shortcuts import render_to_response
from django.template import RequestContext

def welcome(request):

    return render_to_response("startpage.tpl", 
                              context_instance=RequestContext(request))
