'''
Created on Oct 21, 2010

@author: Ian Rolewicz

Client for HBase using the Thrift interface

'''

import copy
from timecloud.lib.HBaseClient.HBaseClient import HBaseClient
from timecloud.lib.thrift.hbase.ttypes import IllegalArgument, Mutation, ColumnDescriptor
from timecloud.lib.thrift.Thrift import TApplicationException
from timecloud.lib.thrift.transport.TSocket import TSocket
from timecloud.lib.thrift.transport.TTransport import TBufferedTransport, TTransportException
from timecloud.lib.thrift.protocol.TBinaryProtocol import TBinaryProtocol
from timecloud.lib.thrift.hbase import Hbase

class HBaseThriftClient(HBaseClient):
    '''
    Client for HBase using the Thrift Interface
    '''


    def __init__(self, host='127.0.0.1', port=9090):
        '''
        Constructor
        '''
        HBaseClient.__init__(self, host, port)
        self.transport = TBufferedTransport(TSocket(self.host, self.port))
        self.protocol = TBinaryProtocol(self.transport)
        self.client = Hbase.Client(self.protocol)

    def connect(self):
        """
        Connects to the HBase instance
        """
        try:
            self.transport.open()
        except TTransportException, e:
            print e.message
            
    def disconnect(self):
        """
        Closes the connection to the HBase instance
        """
        self.transport.close()

####################################
# GET
####################################

    def get(self, tableName, row, column):
        """
        Gets the value of the cell at the specified row and column in
        the given table at the latest timestamp
        @param tableName: Name of the table
        @param row: row index
        @param column: column name
        @return a list containing a single TCell objects containing 
            the value and the timestamp of the Cell. The list is
            empty if no match is found.
        """
        try:
            return self.client.get(tableName, row, column)
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
#    def getVer(self, tableName, row, column, numVersions):
#    def getVerTs(self, tableName, row, column, timestamp, numVersions):

    def getRow(self, tableName, row, columns=None, timestamp=None):
        """
        Gets the specified row in the given table.
        
        @param tableName: name of the table
        @param row: row index
        @param columns: if specified, the returned row will only contained 
            cells from this list of columns
        @param timestamp: if specified, only the last cells before the 
            specified timestamp are returned
            
        @return: a list containing a single TRowResult containing the 
            row index and a map from columns to TCells. The list is
            empty if there is no match
        """
        try:
            if timestamp:
                return self.client.getRowWithColumnsTs(tableName, row, columns, timestamp)
            else:
                return self.client.getRowWithColumns(tableName, row, columns)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
#    def getRow(self, tableName, row):
#    def getRowWithColumns(self, tableName, row, columns):
#    def getRowTs(self, tableName, row, timestamp):
#    def getRowWithColumnsTs(self, tableName, row, columns, timestamp):

    def getTableNames(self, ):
        """
        List all the userspace tables.
        
        @return - returns a list of names
        """
        try:
            return self.client.getTableNames()
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
    def getColumnDescriptors(self, tableName):
        """
        List all the column families associated with a table.
        
        @param tableName: table name
        @return a dict of ColumnDescriptor indexed by the column family name
        """
        try:
            return self.client.getColumnDescriptors(tableName)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
    def getTableRegions(self, tableName):
        """
        List the regions associated with a table.
        @param tableName table name
        @return a list of TRegionInfo
        """
        try:
            return self.client.getTableRegions(tableName)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
                    
####################################
# POST/CREATE
####################################

    def createTable(self, tableName, columnFamiliesNames):
        """
        Create a table given column family names
        
        @param tableName: name of the table
        @param columnFamiliesNames: list of column family names
        """
        try:
            columnFamilies = []
            for colName in columnFamiliesNames:
                columnFamilies.append(ColumnDescriptor(colName))
            self.client.createTable(tableName, columnFamilies)
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
        
    def createTableWithDesc(self, tableName, columnFamiliesDesc):
        """
        Create a table given column family descriptors
        
        @param tableName: name of the table
        @param columnFamiliesNames: list of ColumnDescriptor
        """
        try:
            self.client.createTable(tableName, columnFamiliesDesc)
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
    
####################################
# SCAN/Multi-GET
####################################

    def scan(self, tableName, columns, startRow, nbRows, stopRow = None):
        """
        Scans nbRows rows in the given table for the given
        columns starting from the startRow.

        
        @param tableName: name of the table
        @param columns: list of column names of columns we want to scan.
                    If column name is a column family, all columns of the 
                    specified column family are returned.
        @param startRow: row index at which the scan starts. If an empty
                    string is passed (""), the scan starts at the first
                    row.
        @param stopRow: If specified, row index at which the scan stops.
        @param nbRows: number of rows to scan. If the rows to scan fall
                    after the stopRow, an empty list is returned.
        @return a dict indexed by row indexes, which values are dict containing
            TCells indexed by column names.
        """
        try:
            result = {}
            if stopRow:
                id = self.client.scannerOpenWithStop(tableName, startRow, stopRow, columns)
            else:
                id = self.client.scannerOpen(tableName, startRow, columns)
            for x in range(nbRows):
                rowResult = self.client.scannerGet(id)
                if rowResult:
                    result[rowResult[0].row] = rowResult[0].columns
            self.client.scannerClose(id)
            return result
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
          
          
    def extendedScan(self, tableName, prefix, columns, startRow, stopRow):
        """
        Scan rows in the given table for the given
        columns starting from the startRow and ending at the
        stopRow.
        This method is used for getting a data structure suitable
        for Javascript manipulation.

        @param tableName: name of the table
        @param prefix: prefix appended in front of the startRow, and
                    which will be removed from all the row keys in the resulting
                    dictionnary
        @param columns: list of column names of columns we want to scan.
                    If column name is a column family, all columns of the 
                    specified column family are returned.
        @param startRow: row index at which the scan starts. If an empty
                    string is passed (""), the scan starts at the first
                    row.
        @param stopRow:  Row index at which the scan stops.
                    If an empty string is passed for the startRow, the stopRow
                    should contain the time interval after which the
                    scan should stop.
        @return a dict containing two lists, one containing the rows as dict
                    containing the rowid and and a columns dict, containing 
                    cell values indexed by column names, the other containing
                    the names of the columns (column family along with 
                    column name).
        """
        try:
            result = []
            colNames = set()
            
            # Open the scanner   
            id = self.client.scannerOpen(tableName, prefix+""+startRow, columns)
                
            # Get the first row
            rowResult = self.client.scannerGet(id)
            
            # If no rows are returned, or if we get
            # row with another prefix, we skip the retrieval
            if rowResult and rowResult[0].row.startswith(prefix):
                timestamp = rowResult[0].row.replace(prefix, "")
                # If the given startRow was an empty string, then
                # we assume that the stopRow was the time interval
                # after which the scan stops, starting at the first
                # row in the table
                if startRow == "":
                    stopRow = int(timestamp) + int(stopRow)
            else:
                #Avoid going further
                stopRow = 0
                timestamp = "%d" %(stopRow + 1)
            
            # Make sure that stopRow is an integer
            stopRow = int(stopRow)
            
            # If stopRow is not None we only keep track of the number of rows
            while (int(timestamp) <= stopRow):
                if rowResult:
                    colNames.update(rowResult[0].columns.keys())
                    rowDict = {}
                    for col, cell in rowResult[0].columns.items():
                        rowDict[col] = cell.value
                    result.append({"id": timestamp, "columns": rowDict})
                
                rowResult = self.client.scannerGet(id)
                
                # If no rows are returned, or if we get
                # row with another prefix, we interrupt the retrieval
                if rowResult and rowResult[0].row.startswith(prefix):
                        timestamp = rowResult[0].row.replace(prefix, "")
                else:
                    #Avoid going further
                    timestamp = "%d" %(stopRow + 1)
                    
            self.client.scannerClose(id)
            colNames = list(colNames)
            return {"rows":result, "colNames": colNames}
        
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
    def modelScan(self, tableName, prefix, columns, startRow, stopRow):
        """
        Scan rows in the given table for the given
        columns starting from the startRow and ending at the stopRow.
        This method is used for getting a data structure from model-
        based data suitable for Javascript manipulation.

        @param tableName: name of the table
        @param prefix: prefix appended in front of the startRow, and
                    which will be removed from all the row keys in the resulting
                    dictionnary
        @param columns: list of column names of columns we want to scan.
        @param startRow: row index at which the scan starts. If an empty
                    string is passed (""), the scan starts at the first
                    row.
        @param stopRow: Row index at which the scan stops.
                    If an empty string is passed for the startRow, the stopRow
                    should contain the time interval after which the
                    scan should stop, starting from the first row of the
                    table.
        @return a dict containing two lists, one containing the rows as dict
                    containing the rowid and and a columns dict, containing 
                    cell values indexed by column names, the other containing
                    the names of the columns (column family along with 
                    column name).
        """
        try:
            result = []
    
            # Open the scanner
            id = self.client.scannerOpen(tableName, prefix+""+startRow, columns)
                
            # Get the first row
            rowResult = self.client.scannerGet(id)
            
            # If no rows are returned, or if we get
            # row with another prefix, we skip the retrieval
            if rowResult and rowResult[0].row.startswith(prefix):
                timestamp = rowResult[0].row.replace(prefix, "")
                # If the given startRow was an empty string, then
                # we assume that the stopRow was the time interval
                # after which the scan stops, starting at the first
                # row in the table
                if startRow == "":
                    stopRow = int(timestamp) + int(stopRow)
            else:
                #Avoid going further
                stopRow = 0
                timestamp = str(stopRow)
            
            # Make sure that stopRow is an integer
            stopRow = int(stopRow)
            
            # If stopRow is not None we only keep track of the number of rows
            # We stop right before the last row, so that we can proceed with
            # the individual scannerGet for filling the bottom of the table
            while (int(timestamp) < stopRow):
                if rowResult:
                    rowDict = {}
                    for col, cell in rowResult[0].columns.items():
                        rowDict[col] = cell.value
                    result.append({"id": timestamp, "columns": rowDict})
                    
                rowResult = self.client.scannerGet(id)
                
                # If no rows are returned, or if we get
                # row with another prefix, we interrupt the retrieval
                if rowResult and rowResult[0].row.startswith(prefix):
                        timestamp = rowResult[0].row.replace(prefix, "")
                else:
                    #Avoid going further
                    timestamp = str(stopRow)
            
            ## Proceed with the last row and with the following rows
            # Copy the set of columns
            colCandidates = copy.copy(columns)
            
            # Loop as long as we didn't get values for all the columns
            while len(colCandidates) > 0:
                if rowResult and rowResult[0].row.startswith(prefix):
                    # If a row is returned and it belongs to the same
                    # sensor, we update the result list and remove
                    # each columns from the set for which we get a value
                    # We then close the current scanner and reopen another
                    # one using the remaining columns and get a single row.
                    # We proceed this way until we get values for all columns
                    # or until there is no row left.
                    timestamp = rowResult[0].row.replace(prefix, "")
                    rowDict = {}
                    for col, cell in rowResult[0].columns.items():
                        rowDict[col] = cell.value
                        colCandidates.remove(col)
                    result.append({"id": timestamp, "columns": rowDict})
                    self.client.scannerClose(id)
                    nextTs = str(int(timestamp) + 1)
                    id = self.client.scannerOpen(tableName, prefix+""+nextTs, list(colCandidates))
                    rowResult = self.client.scannerGet(id)
                else :
                    # If no row is returned, we avoid going further
                    colCandidates = []
                    
            self.client.scannerClose(id)
            return {"rows":result, "colNames": columns}
        
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
                     
#    def scannerOpen(self, tableName, startRow, columns):
#    def scannerOpenWithStop(self, tableName, startRow, stopRow, columns):
#    def scannerOpenWithPrefix(self, tableName, startAndPrefix, columns):
#    def scannerOpenTs(self, tableName, startRow, columns, timestamp):
#    def scannerOpenWithStopTs(self, tableName, startRow, stopRow, columns, timestamp):
#    def scannerGet(self, id):
#    def scannerGetList(self, id, nbRows):
#    def scannerClose(self, id):

####################################
# PUT/ Update
####################################

    def put(self, tableName, row, column, value):
        """
        Updates the cell value at given row and column of a given table
        
        @param tableName: name of the table
        @param row: row index
        @param column: column name
        @param value: the value to put
        """
        try:
            self.client.mutateRow(tableName, row, [Mutation(False, column, value)])
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
 
    def putRow(self, tableName, row, entries, skipValues = []):
        """
        Updates the multiple row values at given row of a given table
        
        @param tableName: name of the table
        @param row: row index
        @param entries: dictionnary of values indexed by column attribute
        @param skipValues: list of values that will be replaced by an empty.
            This could be useful when importing rows from a source that
            specifies empty cells by a specific String value.
        """
        
        mutations = []
        
        for k,v in entries.iteritems():
            if v not in skipValues:
                mutations.append(Mutation(False, k, v))
            
        try:
            self.client.mutateRow(tableName, row, mutations)
        except IllegalArgument, ia:
            print ia.message
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
#    def mutateRow(self, tableName, row, mutations):
#    def mutateRowTs(self, tableName, row, mutations, timestamp):
#    def mutateRows(self, tableName, rowBatches):
#    def mutateRowsTs(self, tableName, rowBatches, timestamp):
#    def atomicIncrement(self, tableName, row, column, value):
        
####################################
# DELETE
####################################

    def deleteTable(self, tableName):
        """
        Deletes a table
        
        @param tableName name of table to delete
        """
        try:
            if(not self.client.isTableEnabled(tableName)) :
                self.client.deleteTable(tableName)
            else :
                print "The table needs to be disabled first"
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
#    def deleteAll(self, tableName, row, column):
#    def deleteAllTs(self, tableName, row, column, timestamp):
#    def deleteAllRow(self, tableName, row):
#    def deleteAllRowTs(self, tableName, row, timestamp):

####################################
# Various
####################################

    def enableTable(self, tableName):
        """
        Enables a table (takes it on-line).
        
        @param tableName name of the table
        """
        try:
            self.client.enableTable(tableName)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
    def disableTable(self, tableName):
        """
        Disables a table (takes it off-line).
        
        @param tableName name of the table
        """
        try:
            self.client.disableTable(tableName)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
    def isTableEnabled(self, tableName):
        """
        Checks whether a table is on-line or not.
        
        @param tableName name of table to check
        @return True if table is on-line
        """
        try:
            return self.client.isTableEnabled(tableName)
        except IOError, ioe:
            print ioe.message
        except TApplicationException, tae:
            print tae.message
            
#    def compact(self, tableNameOrRegionName):
#    def majorCompact(self, tableNameOrRegionName):
        
