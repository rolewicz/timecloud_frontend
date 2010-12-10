{% extends "base.tpl" %}

{% block head %}
{% block title %}
{% if chartName = "areaChart" %}
TimeCloud - Area Chart
{% endif %}
{% if chartName = "lineChart" %}
TimeCloud - Line Chart
{% endif %}
{% if chartName = "barChart" %}
TimeCloud - Bar Chart
{% endif %}
{% if chartName = "smallMultiples" %}
TimeCloud - Small Multiples Chart
{% endif %}
{% if chartName = "multipleLinesChart" %}
TimeCloud - Multiple Lines Chart
{% endif %}
{% endblock %}
{% block stylesheet %}
{{ block.super }}
<link rel="stylesheet" type="text/css" href="/static/css/visualize.css" />

{% endblock %}
{% endblock %}

{% block content %}

<div class="backLinkWrapper">
    <a href="/display/{{tableName}}/{{startRow}}-{{numRows}}"> &lt;&lt; Back to table </a>
</div>

<!-- Protovis Library File -->
<script type="text/javascript" src="/static/javascript/protovis/protovis-r3.2.js"></script>

{% block visualizeData %}
{% include "visualizedata.js.tpl" %}
{% endblock %}

<div id="fig" class="fig">
    <script type="text/javascript+protovis">
    {% comment %}
    Need to include the javascript files this way, since
    Protovis doesn't work with external source files
    {% endcomment %}
    {% if chartName = "areaChart" %}
    {% include "areachart.js.tpl" %}
    {% endif %}
    {% if chartName = "lineChart" %}
    {% include "linechart.js.tpl" %}
    {% endif %}
    {% if chartName = "barChart" %}
    {% include "barchart.js.tpl" %}
    {% endif %}
    {% if chartName = "smallMultiples" %}
    {% include "smallmultiples.js.tpl" %}
    {% endif %}
    {% if chartName = "multipleLinesChart" %}
    {% include "multiplelineschart.js.tpl" %}
    {% endif %}
    </script>
</div>
{% endblock%}
