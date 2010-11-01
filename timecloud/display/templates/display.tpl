{% extends "base.tpl" %}
{% load basefilters %}

{% block head %}
{% block title %}TimeCloud - Tables Display{% endblock %}
{% block stylesheet %}
{{ block.super }}
<link rel="stylesheet" type="text/css" href="/static/css/display.css" />
<!--default YUI Sam Skin -->
<link type="text/css" rel="stylesheet" href="/static/javascript/yui/build/datatable/assets/skins/sam/datatable.css">
{% endblock %}
{% endblock %}

{% block content %}
<div id="content" class="content yui-skin-sam">
    <div id="headerBox" class="headerBox">
        <ul>
        {% for link in headerBoxButton %}
        <li class='' onmouseover="this.className = 'mouseover'" onmouseout="this.className=''" >
            <a href="{{link.url}}">{{link.name}}</a>
        </li>
        {% endfor %}
        </ul>
    </div>
    {% if tableName %}
    <div id="dataBox" class="dataBox">
        {% comment %}
        <table id="dataTable">
            <thead>
                <tr>
                    <td>Timestamp</td>
                    {% for colName in columnNames %}
                    <td>{{colName}}</td>
                    {% endfor %}
                </tr>
            </thead>
            <tbody>
                {% for index, row in rows.items %}
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
        {% endcomment %}
    </div>
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
