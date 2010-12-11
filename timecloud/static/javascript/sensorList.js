////////////////////////
// Data table definition
////////////////////////

var dataSource = new YAHOO.util.DataSource(Dom.get(sensorListData));
dataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
 
var columnDefs = [{ key: "Sensor ID", field: "name"},
                  { key: "Owner", field: "owner"},
                  { key: "Accessibility", field: "access"}];

dataSource.responseSchema = {
    resultsList : "result", // Result data is at the root
    fields : [{ key: "name"},
              { key: "owner"},
              { key: "access"}],
    metaFields : {}
};

/* Datatable constructor */
var dataTable = new YAHOO.widget.DataTable("dataBox", columnDefs, dataSource,{
    width: "100%", height: "100%" 
    });

/* On Row click event */
function customOnRowEvent(oArgs){
    var target = oArgs.target;
    
    var sensorName = target.cells[0].textContent;
    
    // Redirects to the corresponding sensor data table
    window.location = "/display/"+sensorName;
}

//Subscribe to events for row selection 
dataTable.subscribe("rowMouseoverEvent", dataTable.onEventHighlightRow); 
dataTable.subscribe("rowMouseoutEvent", dataTable.onEventUnhighlightRow); 
dataTable.subscribe("rowClickEvent", customOnRowEvent); 

////////////////////////
// Search Box
////////////////////////
/* Function doing Ajax requests for retrieving, replacing existing data
 * by new one and refreshing the table
*/
function performSearch(searchTerm) {
     
     var responseSuccess = function(o) {
         // Get the JSON data from the server and parse it
         var data = JSON.parse(o.responseText);
         
         if (data.errors.length != 0){
             displayErrors(data.errors);
         }
         else{
             
             // Populate the table depending on whether we are filtering or fetching
             sensorListData['result'] = data.result

             dataTable.getDataSource().sendRequest(null,
                         {success: dataTable.onDataReturnInitializeTable},
                         dataTable);
                 
         }
     };
      
     var responseFailure = function(o) {
         displayErrors(["Connection Manager Error: " + o.statusText]);
     };
      
     var callback = {
         success:responseSuccess,
         failure:responseFailure,
         argument:[]
     };

     // Perform the asynchronous request
     var transaction = YAHOO.util.Connect.asyncRequest('POST', '/updateSensorList/', callback, "search="+ searchTerm +"&xhr=1");
 

}

function search() {
    
    var searchTerm = Dom.get("searchTextBox").value;
    performSearch(searchTerm);
}
