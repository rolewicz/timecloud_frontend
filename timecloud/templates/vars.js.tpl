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
    {% if colNames %}
        // Column names
        var colNames = {{ colNames|safe }};
    {% endif %}
    {% if precision %}
        // Precision used for the data
        var precision = "{{ precision }}";
    {% endif %}       
    </script>