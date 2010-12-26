from django.db import models

class Sensor(models.Model):
    """
    Simple model for a registred sensor.
    The fields for owner and access should be
    changed once advanced data access management
    and advanced user access managment is implemented.
    """
    name = models.CharField(max_length=30, primary_key=True)
    owner = models.CharField(max_length=30)
    access = models.CharField(max_length=10)
    recInt = models.IntegerField(default=0)
    steps = models.TextField(default="")
    firstTs = models.CharField(max_length=20, default="")
    
    def __unicode__(self):
        return self.name
