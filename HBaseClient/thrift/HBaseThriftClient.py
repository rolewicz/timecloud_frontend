'''
Created on Oct 21, 2010

@author: ian
'''

from HBaseClient import HBaseClient
from ttypes import *
from transport.TSocket import TSocket
from transport.TTransport import TBufferedTransport, TTransportException
from protocol import TBinaryProtocol
from hbase import Hbase

class HBaseThriftClient(HBaseClient):
    '''
    Client for HBase using the Thrift Interface
    '''


    def __init__(self, host='localhost', port=9090):
        '''
        Constructor
        '''
        HBaseClient.__init__(host, port)
        self.transport = TBufferedTransport(TSocket(self.host, self.port))
        self.protocol = TBinaryProtocol.TBinaryProtocol(self.transport)
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

#    def get(self, tableName, row, column):
#    def getVer(self, tableName, row, column, numVersions):
#    def getVerTs(self, tableName, row, column, timestamp, numVersions):
#    def getRow(self, tableName, row):
#    def getRowWithColumns(self, tableName, row, columns):
#    def getRowTs(self, tableName, row, timestamp):
#    def getRowWithColumnsTs(self, tableName, row, columns, timestamp):
#    def getTableNames(self, ):
#    def getColumnDescriptors(self, tableName):
#    def getTableRegions(self, tableName):
        
####################################
# POST/CREATE
####################################

#    def createTableWithNames(self, tableName, columnFamiliesNames):
#    def createTableWithDesc(self, tableName, columnFamiliesDesc):
        
####################################
# SCAN/Multi-GET
####################################

#    def scan(self, tableName, columns, startRow, nbRows):
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

#    def put(self, tableName, row, column, value):
#    def mutateRow(self, tableName, row, mutations):
#    def mutateRowTs(self, tableName, row, mutations, timestamp):
#    def mutateRows(self, tableName, rowBatches):
#    def mutateRowsTs(self, tableName, rowBatches, timestamp):
#    def atomicIncrement(self, tableName, row, column, value):
        
####################################
# DELETE
####################################

#    def deleteTable(self, tableName):
#    def deleteAll(self, tableName, row, column):
#    def deleteAllTs(self, tableName, row, column, timestamp):
#    def deleteAllRow(self, tableName, row):
#    def deleteAllRowTs(self, tableName, row, timestamp):

####################################
# Various
####################################

#    def enableTable(self, tableName):
#    def disableTable(self, tableName):
#    def isTableEnabled(self, tableName):
#    def compact(self, tableNameOrRegionName):
#    def majorCompact(self, tableNameOrRegionName):
        
