<!-- Dependencies -->
<script src="/static/javascript/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script src="/static/javascript/yui/build/element/element-min.js"></script>
<script src="/static/javascript/yui/build/datasource/datasource-min.js"></script>
<script src="/static/javascript/yui/build/container/container_core-min.js"></script>
 
<!-- OPTIONAL: JSON Utility (for DataSource) -->
<script src="/static/javascript/yui/build/json/json-min.js"></script>
 
<!-- OPTIONAL: Connection Manager (enables XHR for DataSource) -->
<script src="/static/javascript/yui/build/connection/connection-min.js"></script>
 
<!-- OPTIONAL: Get Utility (enables dynamic script nodes for DataSource) -->
<script src="/static/javascript/yui/build/get/get-min.js"></script>
 
<!-- OPTIONAL: Drag Drop (enables resizeable or reorderable columns) -->
<script src="/static/javascript/yui/build/dragdrop/dragdrop-min.js"></script>
 
<!-- Source file for the YUI data table -->
<script src="/static/javascript/yui/build/datatable/datatable-min.js"></script>

<!-- Source File for the YUI menu -->
<script src="/static/javascript/yui/build/menu/menu-min.js"></script>

<!-- Custom script for the display -->
<script type="text/javascript">

// Utility functions for resizing the table to fit the height of the page

function resizeContent(){  

    var pageContentDiv = document.getElementById("pageContent");

    var htmlHeight = document.body.parentNode.scrollHeight;
    var windowHeight = window.innerHeight ?
        window.innerHeight : document.documentElement.clientHeight ? 
            document.documentElement.clientHeight : document.body.clientHeight;

    var headerHeight = document.getElementById("pageHeader").offsetHeight;
    var globalMenuHeight = document.getElementById("globalMenu").offsetHeight;
    var footerHeight = document.getElementById("emptyFooter").offsetHeight;
    var errorsHeight = document.getElementById("errors").offsetHeight;
    
    var headerBoxHeight = document.getElementById("headerBox").offsetHeight;
    var dataTableHeaderDiv = YAHOO.util.Dom.getElementsByClassName('yui-dt-hd', 'div')[0];
    var dataTableRowsDiv = YAHOO.util.Dom.getElementsByClassName('yui-dt-bd', 'div')[0];
    
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
    dataTableRowsDiv.style.height = (pageContentDivHeight - dataTableHeaderDiv.offsetHeight - headerBoxHeight) + "px";

}

////////////////////////
// Data table definition
////////////////////////

// JSON Values for rows
var jsonRows = {{jsonRows|safe}};

var dataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get(jsonRows));
dataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
 
var columnDefs = [
    { key: "Timestamp", field: "id"},
    {% for cn in columnNames %}
    { key: "{{cn}}", field: "['columns']['{{cn}}']['value']"}{% if not forloop.last %},{% endif %}
    {% endfor %}
];

// TODO: If no columns selected, then return all columns for visualize

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

var dataTable = new YAHOO.widget.ScrollingDataTable("dataBox", columnDefs, dataSource,{
    width: "100%", height: "100%" 
    });

{% if tableName %}

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

dataTable.subscribe("cellClickEvent", this.customOnColCellEvent);
dataTable.subscribe("theadCellClickEvent", this.customOnColHeadEvent);

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
}

function hideFilterBox() {
}

// Visualization
function visualize(p_sType, p_aArgs, p_oValue) {
    
    var visualizeData = {"colNames":[], "startTs":"", "endTs": "", "numRows":0, "records":{}};

    if(p_oValue.selType === "sel" && numSelCol === 0) {
        visualizeError = "You need to have one column selected in order to trigger this visualization";
        // Set the hidden input with the json
        document.errorsForm.displayErrors.value = JSON.stringify([visualizeError]);
        var url = "/display/{{tableName}}";
        {% if numRows %}
            {% if startRow %}
        url = url + "/{{startRow}}-{{numRows}}"
            {% else %}
        url = url + "/" + dataTable.getRecordSet().getRecords()[0].getData('id') + "-{{numRows}}"
            {% endif %}    
        {% endif %}
        document.errorsForm.action = url;
        document.errorsForm.submit();
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
        else if(p_oValue.chartType === "stackedGraph"){
            document.visualizeForm.action = "/visualize/stackedGraph/{{tableName}}";
        }
        else if(p_oValue.chartType === "smallMultiples"){
            document.visualizeForm.action = "/visualize/smallMultiples/{{tableName}}";
        }
        else if(p_oValue.chartType === "contextChart"){
            document.visualizeForm.action = "/visualize/contextChart/{{tableName}}";
        }
        else if(p_oValue.chartType === "lineStepChart"){
            document.visualizeForm.action = "/visualize/lineStepChart/{{tableName}}";
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
                             onclick: { fn: visualize, obj: { chartType:"multipleLineCharts", selType:"sel"}}
                         };
                         
var selSMultChartItem =  {   text: "Small Multiples",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"smallMultiples", selType:"sel"}}
                         };
                         
var allMultChartsItem =  {   text: "Multiple Line Charts",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"multipleLineCharts", selType:"all"}}
                         };
                         
var allSMultChartItem =  {   text: "Small Multiples",
                             classname: "submenuentry2",
                             onclick: { fn: visualize, obj: { chartType:"smallMultiples", selType:"all"}}
                         };

YAHOO.util.Event.onDOMReady(function () {
    
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