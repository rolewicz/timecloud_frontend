{% extends "base.tpl" %}

{% block head %}
{% block title %}TimeCloud - List of Sensors{% endblock %}
{% block stylesheet %}
{{ block.super }}
<!--default YUI Sam Skin -->
<link type="text/css" rel="stylesheet" href="/static/javascript/yui/build/datatable/assets/skins/sam/datatable.css">
<link type="text/css" rel="stylesheet" href="/static/css/sensorList.css" />

{% endblock %}
{% endblock %}

{% block content %}
<div id="content" class="content yui-skin-sam">
    <div class="infoBox">
        Select a Sensor in the table below to view its data.
    </div>
    <div id="searchBox" class="searchBox">
        <span class="searchBoxSpan">
            <label for="searchTextBox">Search for Sensor ID : </label>
            <input type="text" id="searchTextBox" value=""/>
        </span>
        <span class="searchBoxSpan">
            <input type="button" id="searchButton" value="Search" onclick="search();">
        </span>
    </div>
    <div id="dataBox" class="dataBox">
    </div>
</div>    
{% endblock %}

{% block javascript %}
{{ block.super }}

<!-- YUI Javascript Files for the display -->
<script src="/static/javascript/yui/build/datasource/datasource-min.js"></script>
<script src="/static/javascript/yui/build/container/container_core-min.js"></script>
<script src="/static/javascript/yui/build/json/json-min.js"></script>
<script src="/static/javascript/yui/build/connection/connection-min.js"></script>
<script src="/static/javascript/yui/build/datatable/datatable-min.js"></script>
<script src="/static/javascript/yui/build/menu/menu-min.js"></script>

<!-- Custom Javascript for the Sensor List Display -->
<script src="/static/javascript/sensorList.js" type="text/javascript"></script>
{% endblock %}
