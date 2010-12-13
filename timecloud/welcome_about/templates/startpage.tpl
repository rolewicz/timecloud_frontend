{% extends "base.tpl" %}

{% block title %}
TimeCloud - Welcome
{% endblock %}

{% block content %}
<h2> Welcome ! </h2>
<div class="welcomeDesc">
    The TimeCloud system is a distributed system designed to manage time-series 
    data. It is developped by the LSIR &lt;<a href="http://lsir.epfl.ch/">http://lsir.epfl.ch/</a>&gt;.
</div>
<h2> Get Started</h2>
<div class="welcomeLatestNews">
    Select or look for an available sensor under the "Tables" menu entry. 
    You can then view its data, filter it to get the entries that are of 
    interest and visualize it in various charts for selected columns.
</div>
{% endblock %}