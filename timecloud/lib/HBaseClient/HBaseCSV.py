'''
Created on Nov 2, 2010

@author: Ian Rolewicz

Small script reading test values from CSV file and populating
an HBase instance through its Thrift interface.
'''

import csv
from ThriftClient.HBaseThriftClient import HBaseThriftClient

class variables:
    # Attribute names for the records in the csv
    col_names = ["wind_direction", "wind_speed" , "solar_rad", 
                 "snow_water_content_1", "snow_water_content_2", 
                 "snow_water_content_3", "snow_temp_1", "snow_temp_2",
                 "snow_temp_3", "air_humid", "air_temp", "air_temp_ir", 
                 "snow_surface_temp_ir", "timed"]
    # Attribute name of the column whose values will serve as a primary key
    index_col_name = "timed"
    csv_filepath = "/home/ian/Documents/School/semester_project/data.csv"
    table_name = "sensorTable1"
    # Values put in place of an empty cell in the csv file.
    empty_values = ["null"]

if __name__ == '__main__':
    
    client = HBaseThriftClient()
    client.connect()

    # Creates the table from the list of column attributes
    if variables.table_name in client.getTableNames():
        print "Table with the name " + variables.table_name + " already exists."
    
    else :
        client.createTable(variables.table_name, variables.col_names[:-1])
        
        csvfile = open(variables.csv_filepath, "rb")
        reader = csv.DictReader(csvfile, fieldnames=variables.col_names, delimiter=',')
        
        for row in reader:
            client.putRow(variables.table_name, row.pop(variables.index_col_name), row, variables.empty_values)

    client.disconnect()
