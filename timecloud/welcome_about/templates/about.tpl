{% extends "base.tpl" %}

{% block title %}
TimeCloud - About
{% endblock %}

{% block stylesheet %}
{{ block.super }}
<link rel="stylesheet" type="text/css" href="/static/css/welcome_about.css" />
{% endblock %}

{% block content %}
<div class="aboutContent">
    <p>
    The TimeCloud Frontend Interface was developped by Ian Rolewicz as a Master Semester Project in Computer Science at the <a href="http://www.epfl.ch/">EPFL</a>.
    </p>
    <p>
    The TimeCloud Frontend Interface is designed in <a href="http://www.python.org/">Python</a> and uses the following tools:
    <ul>
        <li>Django &lt;<a href="http://www.djangoproject.com/">http://www.djangoproject.com/</a>&gt;:
            A framework for writing Web Applications in Python.</li>
        <li>YUI 2 &lt;<a href="http://developer.yahoo.com/yui/">http://developer.yahoo.com/yui/</a>&gt;:
            Set of utilities and controls for Javascript.</li>
        <li>Protovis &lt;<a href="http://vis.stanford.edu/protovis/">http://vis.stanford.edu/protovis/</a>&gt;:
            Visualization library using Javascript and SVG.</li>
    </ul>
    </p> 
</div>
{% endblock %}