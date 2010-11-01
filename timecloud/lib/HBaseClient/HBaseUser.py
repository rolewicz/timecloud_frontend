'''
Created on Oct 15, 2010

@author: Ian Rolewicz

Main Module, for now used to test the HBaseClient
'''
from ThriftClient.HBaseThriftClient import HBaseThriftClient
from timecloud.lib.thrift.hbase.ttypes import ColumnDescriptor

if __name__ == '__main__':
    
    hclient = HBaseThriftClient('localhost', 9090);
    hclient.connect();
    
    column_families = ['fam1', 'fam2', 'fam3']
    table_name = 'foo1'
    
    hclient.createTable(table_name, column_families)
    
    table_name2 = 'foo2'
    col_fam1 = ColumnDescriptor('fam1')
    col_fam2 = ColumnDescriptor('fam2')
    
    hclient.createTableWithDesc(table_name2, [col_fam1, col_fam2])
    
    hclient.put('foo2', 'row1', 'fam1', 'somevalue')
    
    result = hclient.get('foo2', 'row1', 'fam1')
    print result
    
    hclient.disableTable('foo1')
    hclient.disableTable('foo2')
    hclient.deleteTable('foo1')
    hclient.deleteTable('foo2')
#    l = []
#    l = hclient.getTableNames()
#    
#    print l
    
    hclient.disconnect()
    