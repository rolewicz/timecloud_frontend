from django.conf.urls.defaults import *
from timecloud.display.views import display, visualize
from timecloud.welcome.views import welcome
import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Example:
    # (r'^timecloud/', include('timecloud.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^admin/', include(admin.site.urls)),
    (r'^welcome/$', welcome),
    (r'^display/(?P<tableName>\w+)/(?P<startRow>\w+)-(?P<numRows>\d+)$', display),
    (r'^display/(?P<tableName>\w+)$', display),
    (r'^display/$', display),
    (r'^visualize/(?P<chartName>\w+)/(?P<tableName>\w+)/(?P<startRow>\w+)-(?P<numRows>\d+)$', visualize),
    (r'^visualize/(?P<chartName>\w+)/(?P<tableName>\w+)$', visualize),
)

# TODO: remove once in production, only for development
if settings.DEBUG:
    urlpatterns += patterns('',
        (r'^static/(?P<path>.*)$', 'django.views.static.serve', 
            {'document_root': '/home/ian/Documents/School/semester_project/timecloud_frontend/timecloud/static'}),
    )
