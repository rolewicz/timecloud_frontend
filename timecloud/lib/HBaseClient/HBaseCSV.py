'''
Created on Nov 2, 2010

@author: Ian Rolewicz

Script reading test values from CSV file, populating
an HBase instance through its Thrift interface and
initializing sensor info in the local database.
'''

import csv, copy, cPickle, os
from ThriftClient.HBaseThriftClient import HBaseThriftClient
from timecloud.lib.Models.LinearModel import LinearModel
from timecloud.lib.Models.ConstantModel import ConstantModel
from timecloud.lib.Models.Step import Step
from timecloud.utils import alignTs

# Hack for making the local database accessible from outside the
# sensorList app
os.environ["DJANGO_SETTINGS_MODULE"] = "timecloud.settings"
from timecloud.sensorList.models import Sensor


class variables:
    # Column family names
    col_fam_names = ["fp", "lm", "cm"] # Full precision, linear model, constant model
    
    # Attribute names for the records in the csv
    col_names = ["wind_direction", "wind_speed" , "solar_rad", 
                 "snow_water_content_1", "snow_water_content_2", 
                 "snow_water_content_3", "snow_temp_1", "snow_temp_2",
                 "snow_temp_3", "air_humid", "air_temp", "air_temp_ir", 
                 "snow_surface_temp_ir", "timed"]
    
    # Attribute name of the column whose values will serve as a primary key
    index_col_name = "timed"
    
    # The data in the csv file is assumed to be sorted by timestamp in 
    # ascending order. This is needed for computing the model-based data,
    # the columns steps and the first timestamp
    csv_filepath = "/home/ian/Documents/School/semester_project/data2.csv"
    table_name = "mainTable"
    # For now, just faking the fact that we have two distinct sensors only
    # by replicating the same one
    sensor_names = ["sensor1", "sensor2"]

    # Values put in place of an empty cell in the csv file.
    empty_values = ["null"]

    # The recording time interval in milliseconds. This one is hardcoded for
    # now, assuming there is a fixed time between two entries in the table.
    # The sample data we have has the following time interval, but some entries
    # seem to happen slightly before or after this alignment (something like
    # 3 or 4 entries out of 1000), so we will realign them for our model approximated
    # values
    recInt = 30000
    # Error Threshold for approximated values
    err_th = 0.1
    
if __name__ == '__main__':
    
    client = HBaseThriftClient()
    client.connect()

    # Creates the table from the list of column attributes
    if variables.table_name in client.getTableNames():
        print "Table with the name " + variables.table_name + " already exists."
    
    else :
        # Create the table
        client.createTable(variables.table_name, variables.col_fam_names)
        
        # Initializes the structures used for populating the database
        linear_models = {}
        constant_models = {}
        latest_values = {}
        lv_inner_struct = {"timestamp": "", "value": ""}
        
        # Structure for computing the steps for each column
        # We compute those as the mean of all steps occuring in the column
        steps = {}
        
        # Record the first timestamp of the dataset, needed for computing
        # the approximated values
        firstTs = ""
        
        # For all column names that are not the index
        for cn in variables.col_names[:-1] :
            linear_models["lm:"+cn] = LinearModel()
            constant_models["cm:"+cn] = ConstantModel()
            steps[cn] = Step()
            latest_values["lm:"+cn] = copy.copy(lv_inner_struct)
            latest_values["cm:"+cn] = copy.copy(lv_inner_struct)
        
        values_to_commit = {}
        
        csvfile = open(variables.csv_filepath, "rb")
        reader = csv.DictReader(csvfile, fieldnames=variables.col_names, delimiter=',')
        
        # Bool for getting the first timestamp
        firstPass = True
        
        for row in reader:
            # Get the timestamp
            index = row.pop(variables.index_col_name)
                
            # Save the oldest timestamp in the dataset
            if firstPass:
                firstTs = index
                firstPass = False
                
            # For each of the columns that are not the index
            for cn in variables.col_names[:-1]:
                # if the value is not a null value
                if row[cn] not in variables.empty_values:
                    # Add the full precision value to the values to commit
                    if index not in values_to_commit:
                        values_to_commit[index] = {}
                    values_to_commit[index]["fp:"+cn] = row[cn]
                    
                    ## Update the value for the linear model
                    # Get the model corresponding to this value
                    lm = linear_models["lm:"+cn]
                    
                    # Save the latest value of the model in a variable
                    # latest_model_value = lm.getFormattedValue()
                    
                    # Add the value to the model and retrieve the new values
                    new_values = lm.add(float(index), float(row[cn]))
                    
                    # If the maxdist is bigger than the error
                    if new_values["maxDist"] > variables.err_th:
                        # Get the latest value for this column
                        latest_value = latest_values["lm:"+cn]
                        # Put it to the values to commit if its timestamp is not ""
                        lv_ts = latest_value["timestamp"]
                        if lv_ts:
                            # Round the timestamp so it matches the recording
                            # frequency. We do this for correcting unalignments
                            # in the data.
                            lv_ts = alignTs(lv_ts, firstTs, variables.recInt)
                            if lv_ts not in values_to_commit:
                                values_to_commit[lv_ts] = {}
                            values_to_commit[lv_ts]["lm:"+cn] = latest_value["value"]
                        # Reset the model object
                        lm.reset()
                        # Add the values to the model object and retrieve the new values
                        lm.add(float(index), float(row[cn]))
                        
                    # Update the latest value for the given column with the new values
                    latest_values["lm:"+cn]["timestamp"] = index
                    latest_values["lm:"+cn]["value"] = lm.getFormattedValues()
                    
                    ## Update the value for the constant model
                    # Get the model corresponding to this value
                    cm = constant_models["cm:"+cn]
                    
                    # Save the latest value of the model in a variable
                    # latest_model_value = cm.getFormattedValue()
                    
                    # Add the value to the model and retrieve the new values
                    new_values = cm.add(float(row[cn]))
                    
                    # If the maxdist is bigger than the error
                    if new_values["maxDist"] > variables.err_th:
                        # Get the latest value for this column
                        latest_value = latest_values["cm:"+cn]
                        # Put it to the values to commit if its timestamp is not ""
                        lv_ts = latest_value["timestamp"]
                        if lv_ts:
                            # Round the timestamp so it matches the recording
                            # frequency. We do this for correcting unalignments
                            # in the data.
                            lv_ts = alignTs(lv_ts, firstTs, variables.recInt)
                            if lv_ts not in values_to_commit:
                                values_to_commit[lv_ts] = {}
                            values_to_commit[lv_ts]["cm:"+cn] = latest_value["value"]
                        # Reset the model object
                        cm.reset()
                        # Add the values to the model object and retrieve the new values
                        cm.add(float(row[cn]))
                        
                    # Update the latest value for the given column with the new values
                    latest_values["cm:"+cn]["timestamp"] = index
                    latest_values["cm:"+cn]["value"] = cm.getFormattedValues()        
                    
                    # Add the index to the column step object
                    steps[cn].add(int(index))
                        
            # For each sensor        
            for sn in variables.sensor_names:
                # Take all the values to commit and call putRow for each timestamp
                for k in values_to_commit.keys():
                    client.putRow(variables.table_name, sn+":"+k, values_to_commit[k], variables.empty_values)
            
            # Clear the values to commit
            values_to_commit = {}
             
        step_dict = {}    
        # Flush all the latest values to the values to commit
        # and save the average steps into a dictionnary. We force
        # the mean steps to be multiples of the recording time
        # interval of the sensor, in order to simplify our
        # model-based approximations
        for cn in variables.col_names[:-1] :
            lm_lv_ts = alignTs(latest_values["lm:"+cn]["timestamp"], firstTs, variables.recInt)
            lm_lv_v  = latest_values["lm:"+cn]["value"]

            
            if lm_lv_ts not in values_to_commit:
                    values_to_commit[lm_lv_ts] = {}
            values_to_commit[lm_lv_ts]["lm:"+cn] = lm_lv_v
            
            cm_lv_ts = alignTs(latest_values["cm:"+cn]["timestamp"], firstTs, variables.recInt)
            cm_lv_v  = latest_values["cm:"+cn]["value"]

            if cm_lv_ts not in values_to_commit:
                    values_to_commit[cm_lv_ts] = {}
            values_to_commit[cm_lv_ts]["cm:"+cn] = cm_lv_v
            
            step_dict[cn] = steps[cn].getAvgStep(variables.recInt)
            
        # Serializes the step dictionnary in order to store it easily
        # in the local database
        sensor_steps = cPickle.dumps(step_dict)
        
        # For each sensor
        for sn in variables.sensor_names:
            # Take all the values to commit and call putRow for each timestamp
            for k in values_to_commit.keys():
                client.putRow(variables.table_name, sn+":"+k, values_to_commit[k], variables.empty_values)
        
            # Updates the local database with step information
            # for each column for each sensor. The data about the columns was
            # previously serialized to text, so it can be easily stored in the 
            # database
            sensorEntry = Sensor.objects.get(name=sn)
            sensorEntry.steps = sensor_steps
            sensorEntry.firstTs = firstTs
            sensorEntry.recInt = variables.recInt
            sensorEntry.save()
            
    client.disconnect()
