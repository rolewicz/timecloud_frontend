<!-- Dependencies -->
<script src="/static/javascript/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script src="/static/javascript/yui/build/element/element-min.js"></script>
<script src="/static/javascript/yui/build/datasource/datasource-min.js"></script>
 
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

<!-- Custom script for the display -->
<script>

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
    
    var headerBoxHeight = document.getElementById("headerBox").offsetHeight;
    var dataTableHeaderDiv = YAHOO.util.Dom.getElementsByClassName('yui-dt-hd', 'div')[0];
    var dataTableRowsDiv = YAHOO.util.Dom.getElementsByClassName('yui-dt-bd', 'div')[0];
    
    if ( htmlHeight > windowHeight ) { 
        pageContentDivHeight = windowHeight - headerHeight - globalMenuHeight - footerHeight;
    }  
    else { 
        pageContentDivHeight = htmlHeight - headerHeight - globalMenuHeight - footerHeight;
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


// JS functions executed on page load
window.onload=function(){
    resizeContent();
}

// JS functions executed on page resize
window.onresize=function(){
    resizeContent();
}

/*
var update_table = {
   init: function() {
      // Grab the elements we'll need.
      update_table.filterForm = document.getElementById('filterForm');
      update_table.dataTable = document.getElementById('');
      
      
      
      
      // This is so we can fade it in later.
      YAHOO.util.Dom.setStyle(ajax_example.results_div, 'opacity', 0);
      
      // Hijack the form.
      YAHOO.util.Event.addListener(ajax_example.form, 'submit', ajax_example.submit_func);
   },
   
   submit_func: function(e) {
      YAHOO.util.Event.preventDefault(e);
      
      // Remove any error messages being displayed.
      var form_fields = ajax_example.form.getElementsByTagName('dd');
      for(var i=0; i<form_fields.length; i++) {
     if(YAHOO.util.Dom.hasClass(form_fields[i], 'error')) {
           ajax_example.form.getElementsByTagName('dl')[0].removeChild(form_fields[i]);
     }
      }
      YAHOO.util.Connect.setForm(ajax_example.form);
      
      //Temporarily disable the form.
      for(var i=0; i<ajax_example.form.elements.length; i++) {
     ajax_example.form.elements[i].disabled = true;
      }
      var cObj = YAHOO.util.Connect.asyncRequest('POST', '/examples/ajax/1/?xhr', ajax_example.ajax_callback);
   },
   
   ajax_callback: {
      success: function(o) {
     // This turns the JSON string into a JavaScript object.
     var response_obj = eval('(' + o.responseText + ')');
     
     // Set up the animation on the results div.
     var result_fade_out = new YAHOO.util.Anim(ajax_example.results_div, {
                              opacity: { to: 0 }
                           }, 0.25, YAHOO.util.Easing.easeOut);

     if(response_obj.errors) { // The form had errors.
        result_fade_out.onComplete.subscribe(function() {
                            ajax_example.results_div.innerHTML = '';
                            ajax_example.display_errors(response_obj.errors);
                         });
     } else if(response_obj.success) { // The form went through successfully.
        var success_message = document.createElement('p');
        success_message.innerHTML = 'Form submitted successfully! Submitted input:';
        var input_list = document.createElement('ul');
        var name_item = document.createElement('li');
        name_item.innerHTML = 'Name: ' + response_obj.name;
        input_list.appendChild(name_item);
        var total_item = document.createElement('li');
        total_item.innerHTML = 'Total: ' + response_obj.total;
        input_list.appendChild(total_item);
        YAHOO.util.Dom.setStyle(ajax_example.results_div, 'display', 'block');
        var result_fade_in = new YAHOO.util.Anim(ajax_example.results_div, {
                            opacity: { to: 1 }
                             }, 0.25, YAHOO.util.Easing.easeIn);
        result_fade_out.onComplete.subscribe(function() {
                            ajax_example.results_div.innerHTML = '';
                            ajax_example.results_div.appendChild(success_message);
                            ajax_example.results_div.appendChild(input_list);
                            result_fade_in.animate();
                         });
     }
     result_fade_out.onComplete.subscribe(function() {
                         //Re -enable the form.
                         for(var i=0; i<ajax_example.form.elements.length; i++) {
                            ajax_example.form.elements[i].disabled = false;
                         }});
     result_fade_out.animate();
      },
      
      failure: function(o) { // In this example, we shouldn't ever go down this path.
     alert('An error has occurred');
      }
   },
   
   display_errors: function(error_obj) {
      for(var err in error_obj) {
     var field_container = document.getElementById(err + '_container');
     var error_dd = document.createElement('dd');
     YAHOO.util.Dom.addClass(error_dd, 'error');
     error_dd.innerHTML = '<strong>'  + error_obj[err] + '</strong>';
     YAHOO.util.Dom.setStyle(error_dd, 'opacity', 0);
     var error_fade_in = new YAHOO.util.Anim(error_dd, {
                            opacity: { to: 1 }
                         }, 0.25, YAHOO.util.Easing.easeIn);
     field_container.parentNode.insertBefore(error_dd, field_container);
     error_fade_in.animate();
      }
   }
};

 */
</script>