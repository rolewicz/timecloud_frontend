{% extends "base.tpl" %}

{% block head %}
{% block title %}
{% if chartName = "areaChart" %}
TimeCloud - Area Chart
{% endif %}
{% if chartName = "contextChart" %}
TimeCloud - Focus and Context Chart
{% endif %}
{% if chartName = "smallMultiples" %}
TimeCloud - Small Multiples Chart
{% endif %}
{% if chartName = "stackedGraph" %}
TimeCloud - Stacked Graph
{% endif %}
{% if chartName = "lineStepChart" %}
TimeCloud - Line & Step Chart
{% endif %}
{% endblock %}
{% block stylesheet %}
{{ block.super }}
<link rel="stylesheet" type="text/css" href="/static/css/visualize.css" />

{% endblock %}
{% endblock %}

{% block content %}

{% block visualizedata %}
<script type="text/javascript" src="/static/javascript/protovis/protovis-r3.2.js"></script>
{% include "visualizedata.js.tpl" %}
{% endblock %}
<div class="backLinkWrapper">
    <a href="/display/{{tableName}}/{{startRow}}-{{numRows}}"> &lt;&lt; Back to table </a>
</div>

<div id="fig" class="fig">
    <script type="text/javascript+protovis">
        {% if chartName = "areaChart" %}
        {% include "areachart.js.tpl" %}
        {% endif %}
        {% if chartName = "contextChart" %}
        {% include "contextchart.js.tpl" %}
        {% endif %}
        {% if chartName = "smallMultiples" %}
        {% include "smallmultiples.js.tpl" %}
        {% endif %}
        {% if chartName = "stackedGraph" %}
        {% include "stackedgraph.js.tpl" %}
        {% endif %}
        {% if chartName = "lineStepChart" %}
        {% include "linestepchart.js.tpl" %}
        {% endif %}
    </script>
</div>
{% endblock%}

{% block javascript %}
{{ block.super }}

{% include "visualize.js.tpl" %}
{% endblock %}