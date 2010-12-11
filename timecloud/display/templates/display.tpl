{% extends "base.tpl" %}
{% load basefilters %}

{% block head %}
{% block title %}TimeCloud - Tables Display{% endblock %}
{% block stylesheet %}
{{ block.super }}
<!--default YUI Sam Skin -->
<link type="text/css" rel="stylesheet" href="/static/javascript/yui/build/datatable/assets/skins/sam/datatable.css">
<link type="text/css" rel="stylesheet" href="/static/css/display.css" />

{% endblock %}
{% endblock %}

{% block content %}
<div id="content" class="content yui-skin-sam">
    {% if sensorName %}
    <div id="infoBox" class="infoBox">
        <div id="infoTable" class="infoTable">
            Sensor Name: '{{sensorName}}'
        </div>
        <div id="fetchChkBoxWrapper" class="fetchChkBoxWrapper">
            <input type=checkbox checked id="fetchChkBox"/> <label for="fetchChkBox">Enable Incremental Data Fetch</label>
        </div>
    </div>
    <div id="headerBox" class="headerBox">
    </div>
    <div id="filterBox" class="filterBox">
        <span class="filterBoxSpan">
            <label for="startRowTextBox">From Timestamp :</label>
            <input type="text" id="startRowTextBox" value=""/>
        </span>
        <span class="filterBoxSpan">
            <label for="numRowsTextBox">Number of Rows :</label>
            <input type="text" id="numRowsTextBox" value="" size="6" />
        </span>
        <span class="filterBoxSpan">
            <input type="button" id="filterButton" value="Filter" onclick="filterData();">
        </span>
        <img id="filterCloseButton" class="filterCloseButton" src="/static/images/close_white.png" alt="close" onclick="hideFilterBox();">
    </div>
    <div id="dataBox" class="dataBox">
    </div>
    <form name="visualizeForm" id="visualizeForm" action="" method="">
        <input type="hidden" name="visualizeParams" value="">
    </form>
    {% else %}
        <table id="sensorTable">
            <thead>
                <tr>
                    {% for th in tables_headers %}
                    <td>{{th}}</td>
                    {% endfor %}
                </tr>
            </thead>
            <tbody>
                {% for table in tables %}
                <tr>
                    <td>{{index}}</td>
                    {% for colName in columnNames %}
                        {% if colName in row|keys %}
                        <td>{{row|cellValue:colName}}</td>
                        {% else %}
                        <td></td>    
                        {% endif %}
                    {% endfor %}
                </tr>
                {% endfor %}
            </tbody>
        </table>
    {% endif %}
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

<!-- Custom Javascript for the Display -->
<script src="/static/javascript/display.js" type="text/javascript"></script>
{% endblock %}
