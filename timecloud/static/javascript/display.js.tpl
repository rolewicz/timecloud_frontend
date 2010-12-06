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
    var filterBoxHeight = Dom.get("filterBox").offsetHeight;
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
    dataTableRowsDiv.style.height = (pageContentDivHeight - dataTableHeaderDiv.offsetHeight - headerBoxHeight - infoBoxHeight - filterBoxHeight) + "px";

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
            }
            else {
                selSubMenu.addItem(areaChartItemInactive);
                selSubMenu.addItem(lineChartItemInactive);
                selSubMenu.addItem(barChartItemInactive);
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
function fetchData(type) {
    
    // Constant for the incremental fetch case
    var NROWS_TO_FETCH = 50;
    
    var numRows = 0;
    var startRow;
    
    // if we perform an incremental fetch
    if(type == "incFetch"){
        var records = dataTable.getRecordSet().getRecords();
        startRow = parseInt(records[records.length-1].getData().id) + 1;
        numRows = NROWS_TO_FETCH;
    }
    // if we perform a filtering action 
    else if (type == "filter"){
        startRow = Dom.get("startRowTextBox").value
        numRows = Dom.get("numRowsTextBox").value
        
        // Zero-padding of the startRow if the number of digits is
        // less than the one of the timestamp
        // TODO: find a more generic way of doing it. This one
        // assumes that timestamps are represented on 13 digits
        var l = startRow.length;
        for(i = 0 ; i < 13-l ; i = i+1){
            startRow = "0" + startRow;
        }
        
        Dom.get("startRowTextBox").value = startRow;
    }
    
    var responseSuccess = function(o) {
        // Get the JSON data from the server and parse it
        var data = JSON.parse(o.responseText);
        
        if (data.errors.length != 0){
            displayDisplayErrors(data.errors);
        }
        else{
            // If no rows are retrieved, we update the table anyway for
            // filtering actions.
            if (data.result.rows.length != 0 || type == "filter"){
                
                // Add the new columns to the table
                var columnNames = data.result.colNames;
                for(i = 0; i < columnNames.length ; i = i + 1){
                    if(dataTable.getColumn(columnNames[i]) == null){
                        dataTable.insertColumn({ key: columnNames[i], field: "['columns']['"+ columnNames[i] +"']['value']"});
                        dataTable.getDataSource().responseSchema.fields.push({ key: "['columns']['"+ columnNames[i] +"']['value']" });
                    }
                }
                
                // Populate the table depending on whether we are filtering or fetching
                rowsData['result'] = data.result.rows
                if(type == "incFetch"){
                    dataTable.getDataSource().sendRequest(null,
                                {success: dataTable.onDataReturnAppendRows},
                                dataTable);
                }
                else if(type == "filter"){
                    dataTable.getDataSource().sendRequest(null,
                                {success: dataTable.onDataReturnInitializeTable},
                                dataTable);
                }
                
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

    if(numRows != "" && startRow != ""){
        // Perform the asynchronous request
        var transaction = YAHOO.util.Connect.asyncRequest('POST', '/updateTable/', callback, "tableName={{tableName}}&startRow="+startRow+"&numRows="+ numRows +"&xhr=1");
    }
    

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
            fetchData("incFetch");
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
// Filter Box
////////////////////////

// Filter Box
function showFilterBox() {
    var fBox = Dom.get("filterBox");
    fBox.style.visibility = "visible";
    fBox.style.height = "35px";
    
    // Set paddings and floats of child nodes
    var filterSpans = Dom.getElementsByClassName('filterBoxSpan', 'span');
    for(i = 0; i < filterSpans.length; i = i + 1){
        filterSpans[i].style.cssFloat = "left";
        filterSpans[i].style.paddingTop = "5px";
        filterSpans[i].style.paddingLeft = "20px";
    }
    var filterCloseButton = Dom.get("filterCloseButton");
    filterCloseButton.style.cssFloat = "right";
    filterCloseButton.style.padding = "10px";
    
    resizeContent();
}

function hideFilterBox() {
    var fBox = Dom.get("filterBox");
    fBox.style.visibility = "hidden";
    fBox.style.height = "0px";
    
    // Set paddings and floats of child nodes
    var filterSpans = Dom.getElementsByClassName('filterBoxSpan', 'span');
    for(i = 0; i < filterSpans.length; i = i + 1){
        filterSpans[i].style.cssFloat = "";
        filterSpans[i].style.paddingTop = "0px";
        filterSpans[i].style.paddingLeft = "0px";
    }
    var filterCloseButton = Dom.get("filterCloseButton");
    filterCloseButton.style.cssFloat = "";
    filterCloseButton.style.padding = "0px";
    
    resizeContent();
}

function filterData() {
    fetchData("filter");
}

////////////////////////
// Header Box
////////////////////////


// Actions for the menu

var headerMenu;

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
    
    headerMenu = new YAHOO.widget.MenuBar("headerBox",{hidedelay: 750});
    
    headerMenu.addItems([
            {   text: "Filter", 
                onclick: {fn: showFilterBox}
            },
            {   text: "Visualize", 
                submenu: { 
                    id: "visualizeMenu",
                    itemdata: [
                        {   text: "Selected Columns With ...",
                            classname: "submenuentry1",
                            submenu:{
                                id:"selColVisualize",
                                autosubmenudisplay: true ,
                                keepopen: true,
                                itemdata: [
                                    areaChartItemInactive,
                                    lineChartItemInactive,
                                    barChartItemInactive,
                                ]
                            }
                        },
                        {   text: "All Columns With ...",
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