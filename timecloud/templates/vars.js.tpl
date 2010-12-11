    <!-- Server-Generated Variables -->
    <script type="text/javascript">
    {% comment %}
    Display and Visualization Variables
    {% endcomment %}
    {% if sensorName %}
        // Table Name
        var sensorName = "{{sensorName}}";
    {% endif %}
    {% if sensorList %}
        // List of available sensors
        var sensorListData = {{ sensorList|safe }}
    {% endif %}
    {% if jsonRows %}
        // Data for rows. Only contains the latest data retrieved from the server
        var rowsData = {{ jsonRows|safe }};
    {% endif %}
    {% if columnNames %}
        // Column names
        var colNames = {{ columnNames|safe }};
    {% endif %}
    </script>