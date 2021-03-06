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

var dataSource = new YAHOO.util.DataSource(Dom.get(rowsData));
dataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
 
var columnDefs = [];

for(i = 0; i < colNames.length; i = i+1){  
    columnDefs.push({ key: colNames[i], field: "['columns']['"+ colNames[i] +"']", label: colNames[i].substr(3)+"<input type='checkbox' style='margin-left: 5px; vertical-align: middle;'/>"});
}

// Sort the column definitions alphabetically
columnDefs.sort(function(a, b){
    var nameA=a.key.toLowerCase()
    var nameB=b.key.toLowerCase()
    if (nameA < nameB){ //sort string ascending
        return -1
    }
    if (nameA > nameB){
        return 1
    }
    return 0
});

// Put the Timestamp in front
columnDefs.splice(0, 0, { key: "Timestamp", field: "id"});

dataSource.responseSchema = {
    resultsList : "result", // Result data is at the root
    fields : [{ key: "id"}],
    metaFields : {}
};

for(i = 0; i < colNames.length; i = i+1){
    dataSource.responseSchema.fields.push({ key: "['columns']['"+ colNames[i] + "']" });
}

/* Datatable constructor */
var dataTable = new YAHOO.widget.ScrollingDataTable("dataBox", columnDefs, dataSource,{
    width: "100%", height: "100%" 
    });

var numSelCol = 0;

// Column Selection Handling
function selectionHandling(column) {
    var selSubMenu = headerMenu.getSubmenus()[0].getSubmenus()[0];
    if (column.selected){
        column.selected = false;
        // unchecks the corresponding checkbox in the header
        column.getThEl().children[0].children[0].children[0].checked = false;
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
        column.selected = true;
        // checks the corresponding checkbox in the header
        column.getThEl().children[0].children[0].children[0].checked = true;
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
    
    // Constant time interval for the incremental fetch case
    // in milliseconds
    var FETCH_TIME_INTERVAL = 2000000;
    
    var startRow;
    var stopRow;
    
    // if we perform an incremental fetch
    if(type == "incFetch"){
        var records = dataTable.getRecordSet().getRecords();
        startRow = parseInt(records[records.length-1].getData().id) + 1;
        stopRow = startRow + FETCH_TIME_INTERVAL;
    }
    // if we perform a filtering action 
    else if (type == "filter"){
        startRow = Dom.get("startRowTextBox").value
        stopRow = Dom.get("stopRowTextBox").value
        
        // Zero-padding of the startRow and stopRow if the number of digits is
        // less than the one of the timestamp
        // TODO: find a more generic way of doing it. This one
        // assumes that timestamps are represented on 13 digits
        var l = startRow.length;
        if (l != 0){
            for(i = 0 ; i < 13-l ; i = i+1){
                startRow = "0" + startRow;
            }
        }
        Dom.get("startRowTextBox").value = startRow;
        
        var l = stopRow.length;
        if (l != 0){
            for(i = 0 ; i < 13-l ; i = i+1){
                stopRow = "0" + stopRow;
            }
        }
        Dom.get("stopRowTextBox").value = stopRow;
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
                        dataTable.insertColumn({ key: columnNames[i], field: "['columns']['"+ columnNames[i] +"']", label: colNames[i].substr(3)+"<input type='checkbox' style='margin-left: 5px; vertical-align: middle;'/>"});
                        dataTable.getDataSource().responseSchema.fields.push({ key: "['columns']['"+ columnNames[i] +"']" });
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
                    // If succeeded filtering the data, we reactivate the fetching
                    keepFetching = true;
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

    if(stopRow != "" && startRow != ""){
        // Perform the asynchronous request
        var transaction = YAHOO.util.Connect.asyncRequest('POST', '/updateTable/', callback, "sensorName="+ sensorName +"&startRow="+ startRow +"&stopRow="+ stopRow +"&precision="+ precision + "&xhr=1");
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

// JS functions executed on page load
window.onload=function(){
    resizeContent();
}

// JS functions executed on page resize
window.onresize=function(){
    resizeContent();
}

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
    
    var visualizeData = {"colNames":[], "startTs":"", "endTs": "", "minValue": Number.MAX_VALUE, "maxValue": Number.MIN_VALUE, "numRows":0, "records":{}};

    if(p_oValue.selType === "sel" && numSelCol === 0) {
        visualizeError = "You need to have one column selected in order to trigger this visualization";
        displayErrors([visualizeError]);
    }
    else {
        var columns = [];
        
        if(p_oValue.selType === "sel"){
            columns = dataTable.getSelectedColumns();
        }
        else if (p_oValue.selType === "all") {
           columns = dataTable.getColumnSet().getDefinitions();
            // Remove the "Timestamp" column
            columns.splice(0,1);
        }
    
        for (i = 0 ; i < columns.length ; i = i+1){
            visualizeData.colNames.push(columns[i].key);
            visualizeData['records'][columns[i].key] = [];
        }
        
        records = dataTable.getRecordSet().getRecords();
    
        visualizeData.startTs = parseInt(records[0].getData().id);
        visualizeData.endTs = parseInt(records[records.length-1].getData().id);
        visualizeData.numRows = records.length;
   
        for(i = 0; i < records.length ; i = i+1){
            timestamp = parseInt(records[i].getData().id);
            for(j = 0; j < visualizeData.colNames.length ; j = j+1 ) {
                value = parseFloat(records[i].getData("['columns']['" + visualizeData.colNames[j] + "']"));
                if (value) {
                    record = {'timestamp': timestamp, 'value': value};
                    visualizeData['records'][visualizeData.colNames[j]].push(record);
                    if(value > visualizeData.maxValue){
                        visualizeData.maxValue = value;
                    }
                    if(value < visualizeData.minValue){
                        visualizeData.minValue = value;
                    }
                }
            }
        }
        
        // Set the hidden input with the json
        document.visualizeForm.visualizeParams.value = JSON.stringify(visualizeData);
        
        if(p_oValue.chartType === "areaChart"){
            document.visualizeForm.action = "/visualize/areaChart/" + sensorName + "/" + precision + "-" + visualizeData.startTs + "-" + visualizeData.endTs;
        }
        else if(p_oValue.chartType === "lineChart"){
            document.visualizeForm.action = "/visualize/lineChart/" + sensorName + "/" + precision + "-" + visualizeData.startTs + "-" + visualizeData.endTs;
        }
        else if(p_oValue.chartType === "barChart"){
            document.visualizeForm.action = "/visualize/barChart/" + sensorName + "/" + precision + "-" + visualizeData.startTs + "-" + visualizeData.endTs;
        }
        else if(p_oValue.chartType === "smallMultiples"){
            document.visualizeForm.action = "/visualize/smallMultiples/" + sensorName + "/" + precision + "-" + visualizeData.startTs + "-" + visualizeData.endTs;
        }
        else if(p_oValue.chartType === "multipleLinesChart"){
            document.visualizeForm.action = "/visualize/multipleLinesChart/" + sensorName + "/" + precision + "-" + visualizeData.startTs + "-" + visualizeData.endTs;
        }
        
        document.visualizeForm.method = "POST";
        
        document.visualizeForm.submit();
    }
}

// Precision change
function changePrecision(p_sType, p_aArgs, p_oValue){
    
    if (p_oValue.prec != precision){
        // Get the start and stop timestamps out of the data table
        var records = dataTable.getRecordSet().getRecords();
        var startRow = records[0].getData().id
        var stopRow = records[records.length-1].getData().id
        
        // Redirect to the corresponding precision
        window.location = "/display/"+sensorName+"/"+p_oValue.prec+"-"+startRow+"-"+stopRow ;
    }
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

var constApprItem = {   text: "Constant Approximation",
                        classname: "submenuentry1",
                        onclick: { fn: changePrecision, obj: { prec:"cm"}}          
                    };

var linearApprItem = {  text: "Linear Approximation",
                        classname: "submenuentry1",
                        onclick: { fn: changePrecision, obj: { prec:"lm"}}         
                     };

var fullPrecItem = {    text: "Full Precision",
                        classname: "submenuentry1",
                        onclick: { fn: changePrecision, obj: { prec:"fp"}}          
                    };

Event.onDOMReady(function () {
    
    headerMenu = new YAHOO.widget.MenuBar("headerBox",{hidedelay: 750,
                                                       autosubmenudisplay: false});
    
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
            {   text: "Precision",
                submenu: { 
                    id: "precisionMenu",
                    itemdata: []
                } 
            },
            {   text: "Back to Tables Index",  
                url: "/sensorList",
                classname: "right-aligned" }
 
        ]);
    
    // Depending on the precision, change the entries in
    // the menu
    var precSubMenu = headerMenu.getSubmenus()[1];
    
    if (precision != "fp"){
        precSubMenu.addItem(fullPrecItem);
    }

    if (precision != "cm"){
        precSubMenu.addItem(constApprItem);
    }

    if (precision != "lm"){
        precSubMenu.addItem(linearApprItem);
    }
    
    headerMenu.render();
 
    headerMenu.show();
    
});