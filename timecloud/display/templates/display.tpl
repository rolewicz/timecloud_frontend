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
    {% if tableName %}
    <div id="headerBox" class="headerBox">
    </div>
    <div id="dataBox" class="dataBox">
    </div>
    <form name="visualizeForm" id="visualizeForm" action="" method="">
        <input type="hidden" name="visualizeParams" value="">
    </form>
    {% else %}
        <table id="tablesTable">
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
{% include "display.js.tpl" %}
{% endblock %}
