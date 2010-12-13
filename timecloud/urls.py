from django.conf.urls.defaults import *
from timecloud.welcome_about.views import welcome, about
from timecloud.display.views import display, updateTable
from timecloud.visualize.views import visualize
from timecloud.sensorList.views import sensorList, updateSensorList
import settings

# Uncomment the next two lines to enable the admin:
#from django.contrib import admin
#admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^timecloud/', include('timecloud.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
   # (r'^admin/', include(admin.site.urls)),
    (r'^welcome/$', welcome),
    (r'^about/$', about),
    (r'^manage/$', welcome),
    (r'^sensorList/$', sensorList),
    (r'^updateSensorList/$', updateSensorList),
    (r'^display/(?P<sensorName>\w+)/(?P<startRow>\w+)-(?P<numRows>\d+)$', display),
    (r'^display/(?P<sensorName>\w+)$', display),
    (r'^updateTable/', updateTable),
    (r'^visualize/(?P<chartName>\w+)/(?P<sensorName>\w+)/(?P<startRow>\w+)-(?P<numRows>\d+)$', visualize),
    (r'^visualize/(?P<chartName>\w+)/(?P<sensorName>\w+)$', visualize),
    (r'^$', welcome),
)

# TODO: remove once in production, only for development
if settings.DEBUG:
    urlpatterns += patterns('',
        (r'^static/(?P<path>.*)$', 'django.views.static.serve', 
            {'document_root': '/home/ian/Documents/School/semester_project/timecloud_frontend/timecloud/static'}),
    )
