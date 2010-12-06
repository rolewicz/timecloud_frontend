<!-- YUI Javascript Files for the display -->
<script src="/static/javascript/yui/build/datasource/datasource-min.js"></script>
<script src="/static/javascript/yui/build/container/container_core-min.js"></script>
<script src="/static/javascript/yui/build/json/json-min.js"></script>
<script src="/static/javascript/yui/build/connection/connection-min.js"></script>
<script src="/static/javascript/yui/build/datatable/datatable-min.js"></script>
<script src="/static/javascript/yui/build/menu/menu-min.js"></script>

<!-- Custom script for the display -->
<script type="text/javascript">
    
// Utility functions for resizing the table to fit the height of the page

function resizeContent(){  

    var pageContentDiv = Dom.get("pageContent");

    var htmlHeight = document.body.parentNode.scrollHeight;
    var windowHeight = window.innerHeight ?
        window.innerHeight : document.documentElement.clientHeight ? 
            document.documentElement.clientHeight : document.body.clientHeight;

    var headerHeight = Dom.get("pageHeader").offsetHeight;
    var globalMenuHeight = Dom.get("globalMenu").offsetHeight;
    var footerHeight = Dom.get("emptyFooter").offsetHeight;
    var errorsHeight = Dom.get("errors").offsetHeight;
    
    var infoBoxHeight = Dom.get("infoBox").offsetHeight;
    var headerBoxHeight = Dom.get("headerBox").offsetHeight;
    var dataTableHeaderDiv = Dom.getElementsByClassName('yui-dt-hd', 'div')[0];
    var dataTableRowsDiv = Dom.getElementsByClassName('yui-dt-bd', 'div')[0];
    
    if ( htmlHeight > windowHeight ) { 
        pageContentDivHeight = windowHeight - headerHeight - globalMenuHeight - footerHeight - errorsHeight;
    }  
    else { 
        pageContentDivHeight = htmlHeight - headerHeight - globalMenuHeight - footerHeight - errorsHeight;
    }  
    
    // We add 40px to the page content height in order to hide the footer below the bottom
    // of the window. Very ugly, but not evident to figure out a better way of doing it.
    pageContentDivHeight = pageContentDivHeight + 40;
    pageContentDiv.style.height = pageContentDivHeight + "px";
    
    // We need to resize the table rows container in order to prevent it
    // from overlapping with the footer
    dataTableRowsDiv.style.height = (pageContentDivHeight - dataTableHeaderDiv.offsetHeight - headerBoxHeight - infoBoxHeight) + "px";

}

// Utility function for displaying errors on top of the display page
// Takes an array containing error messages as an argument
function displayDisplayErrors(errors){

    displayErrors(errors, closeDisplayErrorEntry);
    resizeContent();
}

// Utility function for closing an error message on top of the display page
function closeDisplayErrorEntry(target) {
    closeErrorEntry(target);
    resizeContent();
}

////////////////////////
// Data table definition
////////////////////////

{% if tableName %}

// Data for rows. Only contains the latest data retrieved from the server
var rowsData = {{jsonRows|safe}};

var dataSource = new YAHOO.util.DataSource(Dom.get(rowsData));
dataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
 
var columnDefs = [
    { key: "Timestamp", field: "id"},
    {% for cn in columnNames %}
    { key: "{{cn}}", field: "['columns']['{{cn}}']['value']"}{% if not forloop.last %},{% endif %}
    {% endfor %}
];

dataSource.responseSchema = {
    resultsList : "result", // Result data is at the root
    fields : [
        { key: "id"},
        {% for cn in columnNames %}
        { key: "['columns']['{{cn}}']['value']" }{% if not forloop.last %},{% endif %}
        {% endfor %}
    ],
    metaFields : {}
};

/* Datatable constructor */
var dataTable = new YAHOO.widget.ScrollingDataTable("dataBox", columnDefs, dataSource,{
    width: "100%", height: "100%" 
    });

var numSelCol = 0;

// Column Selection Handling
function selectionHandling(column) {
    var selSubMenu = headerMenu.getSubmenus()[0].getSubmenus()[0];
    if (column.selected){
        dataTable.unselectColumn(column);
        numSelCol = numSelCol - 1;
        if(numSelCol == 1 || numSelCol == 0){
            for(i = 1; i <= selSubMenu.itemData.length ; i = i+1){
                selSubMenu.removeItem(0);
            }
            if(numSelCol == 1){
                selSubMenu.addItem(areaChartItem);
                selSubMenu.addItem(lineChartItem);
                selSubMenu.addItem(barChartItem);
                selSubMenu.addItem(lineStepChartItem);
            }
            else {
                selSubMenu.addItem(areaChartItemInactive);
                selSubMenu.addItem(lineChartItemInactive);
                selSubMenu.addItem(barChartItemInactive);
                selSubMenu.addItem(lineStepChartItemInactive);
            }   
            headerMenu.render();
        }
    }
    else {
        dataTable.selectColumn(column);
        numSelCol = numSelCol + 1;
        if(numSelCol == 1 || numSelCol == 2){
            for(i = 1; i <= selSubMenu.itemData.length ; i = i+1){
                selSubMenu.removeItem(0);
            }
            
            if(numSelCol == 1){
                selSubMenu.addItem(areaChartItem);
                selSubMenu.addItem(lineChartItem);
                selSubMenu.addItem(barChartItem);
                selSubMenu.addItem(lineStepChartItem);
            }
            else {
                selSubMenu.addItem(selMultChartsItem);
                selSubMenu.addItem(selSMultChartItem);
            }
            headerMenu.render();
        }
    }
}

function customOnColHeadEvent(oArgs) {
    var target = oArgs.target;
    
    if (target.textContent !== "Timestamp"){
        var column = dataTable.getColumn(target.textContent);
        selectionHandling(column);
    }
}

function customOnColCellEvent(oArgs){
    var target = oArgs.target;
    var column = dataTable.getColumn(target);
    
    if (column.key !== "Timestamp"){
        selectionHandling(column);
    }
}

dataTable.subscribe("cellClickEvent", customOnColCellEvent);
dataTable.subscribe("theadCellClickEvent", customOnColHeadEvent);

// Boolean for keeping on fetching (false when reached the end of the table
// on the server side, for example)
var keepFetching = true;

/* Function doing Ajax requests for retrieving, appending data
   to existing one and refreshing the table
 */
function fetchData() {

    var NROWS_TO_FETCH = 50;
    
    var responseSuccess = function(o) {
        // Get the JSON data from the server and parse it
        var data = JSON.parse(o.responseText);
        
        if (data.errors.length != 0){
            displayDisplayErrors(data.errors);
        }
        else{
            if (data.result.rows.length != 0){
                
                // Add the new columns to the table
                var columnNames = data.result.colNames;
                for(i = 0; i < columnNames.length ; i = i + 1){
                    if(dataTable.getColumn(columnNames[i]) == null){
                        dataTable.insertColumn({ key: columnNames[i], field: "['columns']['"+ columnNames[i] +"']['value']"});
                        dataTable.getDataSource().responseSchema.fields.push({ key: "['columns']['"+ columnNames[i] +"']['value']" });
                    }
                }
                
                // Append the rows to the end of the table
                rowsData['result'] = data.result.rows
                dataTable.getDataSource().sendRequest(null,
                            {success: dataTable.onDataReturnAppendRows},
                            dataTable);
                
            }
            else{
                // If nothing is back, we reached the end of the table
                keepFetching = false;
            }
        }
    };
     
    var responseFailure = function(o) {
        keepFetching = false;
        displayDisplayErrors(["Connection Manager Error: " + o.statusText]);
    };
     
    var callback = {
        success:responseSuccess,
        failure:responseFailure,
        argument:[]
    };

    // Perform the asynchronous request
    var records = dataTable.getRecordSet().getRecords();
    var nextStartRow = parseInt(records[records.length-1].getData().id) + 1
    var transaction = YAHOO.util.Connect.asyncRequest('POST', '/updateTable/', callback, "tableName={{tableName}}&startRow="+nextStartRow+"&numRows="+ NROWS_TO_FETCH +"&xhr=1");

}

// Event for incremental fetching
Event.on(dataTable.getBdContainerEl(),'scroll',function (ev) {

    // Get the value of the checkbox
    var fetchChecked = Dom.get("fetchChkBox").checked
    if(keepFetching && fetchChecked){
    
        //TODO: - if vertical scrolling only has changed
    
        var scrollTop = Event.getTarget(ev).scrollTop,
            tbodyHeight = Dom.getRegion(dataTable.getTbodyEl()).height,
            rowHeight = Dom.getRegion(dataTable.getLastTrEl()).height,
            bdContainerHeight = Dom.getRegion(dataTable.getBdContainerEl()).height;
    
        // if we reach the bottom of the scrolling and the size of the container
        // isn't too small
        if(bdContainerHeight >= 30 && scrollTop + bdContainerHeight >= tbodyHeight) {
            fetchData();
        }
    }
});
            
{% endif %}

// JS functions executed on page load
window.onload=function(){
    resizeContent();
}

// JS functions executed on page resize
window.onresize=function(){
    resizeContent();
}


{% if tableName %}

////////////////////////
// Header Box
////////////////////////

var headerMenu;

// Actions for the menu

// Filter Box
function showFilterBox() {
    displayDisplayErrors(["Still no filter box available."]);
    displayDisplayErrors(["Is this working ?.", "Fuck man! I don't know!"]);
}

function hideFilterBox() {
}

// Visualization
function visualize(p_sType, p_aArgs, p_oValue) {
    
    var visualizeData = {"colNames":[], "startTs":"", "endTs": "", "numRows":0, "records":{}};

    if(p_oValue.selType === "sel" && numSelCol === 0) {
        visualizeError = "You need to have one column selected in order to trigger this visualization";
        displayErrors([visualizeError]);
    }
    else {
        
        var columns = dataTable.getSelectedColumns();
    
        for (i = 0 ; i < columns.length ; i = i+1){
            visualizeData.colNames.push(columns[i].key);
            visualizeData['records'][columns[i].key] = [];
        }
        
        records = dataTable.getRecordSet().getRecords();
    
        visualizeData.startTs = {% if startRow %} parseInt("{{startRow}}") {% else %} parseInt(records[0].getData().id) {% endif %};
        visualizeData.endTs = parseInt(records[records.length-1].getData().id);
        visualizeData.numRows = {% if numRows %} {{numRows}} {% else %} records.length {% endif %};
   
        for(i = 0; i < records.length ; i = i+1){
            timestamp = parseInt(records[i].getData().id);
            for(j = 0; j < visualizeData.colNames.length ; j = j+1 ) {
                value = parseFloat(records[i].getData("['columns']['" + visualizeData.colNames[j] + "']['value']"));
                if (value) {
                    record = {'timestamp': timestamp, 'value': value};
                    visualizeData['records'][visualizeData.colNames[j]].push(record);
                }
            }
        }
        
        // Set the hidden input with the json
        document.visualizeForm.visualizeParams.value = JSON.stringify(visualizeData);
        
        if(p_oValue.chartType === "areaChart"){
            document.visualizeForm.action = "/visualize/areaChart/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        else if(p_oValue.chartType === "lineChart"){
            document.visualizeForm.action = "/visualize/lineChart/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        else if(p_oValue.chartType === "barChart"){
            document.visualizeForm.action = "/visualize/barChart/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        else if(p_oValue.chartType === "lineStepChart"){
            document.visualizeForm.action = "/visualize/lineStepChart/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        else if(p_oValue.chartType === "smallMultiples"){
            document.visualizeForm.action = "/visualize/smallMultiples/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        else if(p_oValue.chartType === "multiplesLinesChart"){
            document.visualizeForm.action = "/visualize/multipleLinesChart/{{tableName}}/" + visualizeData.startTs + "-" + visualizeData.numRows;
        }
        
        document.visualizeForm.method = "POST";
        
        document.visualizeForm.submit();
    }
}

// Others
function callShowFullPrecision(){

}

// Definition of exchangable menu items
var areaChartItemInactive = {   text: "Area Chart",
                                classname: "submenuentry2 inactive"
                            };
                    
var barChartItemInactive =  {   text: "Bar Chart",
                                classname: "submenuentry2 inactive"
                            };

var lineChartItemInactive =  {   text: "Line Chart",
                                 classname: "submenuentry2 inactive"
                             };
                                        
var lineStepChartItemInactive = {   text: "Line & Step Chart",
                                    classname: "submenuentry2 inactive"
                                };
                    
var areaChartItem = {   text: "Area Chart",
                        classname: "submenuentry2",
                        onclick: { fn: visualize, obj: { chartType:"areaChart", selType:"sel"} }
                    };

var lineChartItem =  {   text: "Line Chart",
                        classname: "submenuentry2",
                        onclick: { fn: visualize, obj: { chartType:"lineChart", selType:"sel"} }
                    };
                                       
var barChartItem =  {   text: "Bar Chart",
                        classname: "submenuentry2",
                        onclick: { fn: visualize, obj: { chartType:"barChart", selType:"sel"} }
                    };
                    
var lineStepChartItem = {    text: "Line & Step Chart",
                            classname: "submenuentry2",
                            onclick: { fn: visualize, obj: { chartType:"lineStepChart", selType:"sel"} }
                        };
                    
var selMultChartsItem =  {   text: "Multiple Line Charts",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"multipleLinesChart", selType:"sel"}}
                         };
                         
var selSMultChartItem =  {   text: "Small Multiples",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"smallMultiples", selType:"sel"}}
                         };
                         
var allMultChartsItem =  {   text: "Multiple Lines Chart",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"multipleLinesChart", selType:"all"}}
                         };
                         
var allSMultChartItem =  {   text: "Small Multiples",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"smallMultiples", selType:"all"}}
                         };

Event.onDOMReady(function () {
    
    headerMenu = new YAHOO.widget.MenuBar("headerBox",{  
                                                autosubmenudisplay: true ,  
                                                hidedelay: 750});
    
    headerMenu.addItems([
            {   text: "Filter", 
                onclick: {fn: showFilterBox}
            },
            {   text: "Visualize", 
                submenu: { 
                    id: "visualizeMenu",
                    itemdata: [
                        {   text: "Selected Columns With",
                            classname: "submenuentry1",
                            submenu:{
                                id:"selColVisualize",
                                keepopen: true,
                                itemdata: [
                                    areaChartItemInactive,
                                    lineChartItemInactive,
                                    barChartItemInactive,
                                    lineStepChartItemInactive
                                ]
                            }
                        },
                        {   text: "All Columns With",
                            classname: "submenuentry1",
                            submenu:{
                                id:"allColVisualize",
                                itemdata: [
                                    allMultChartsItem,
                                    allSMultChartItem
                                ]
                            }
                        }, 
                        
                        ]
                } 
            },    
            {   text: "Show Full Precision", 
                onclick: { fn: callShowFullPrecision }},
            {   text: "Back to Tables Index",  
                url: "/display",
                classname: "right-aligned" }
 
        ]);
 
    headerMenu.render();
 
    headerMenu.show();
    
});


{% endif %}

</script>