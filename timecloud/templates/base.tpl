<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html lang="en">
<head>
    <title>{% block title %}{% endblock %}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
    {% block stylesheet %}
    <link rel="stylesheet" type="text/css" href="/static/css/main.css" />
    {% endblock %}
</head>
<body>
    <div id="contentWrapper" class="contentWrapper">
        {% block header %}
        {% include "header.tpl" %}
        {% endblock %}
        {% block globalmenu %}
        {% include "globalmenu.tpl"%}
        {% endblock%}
        {% block sidemenu %}
        {% endblock %}
        {% block errors %}
        {% include "errors.tpl" %}
        {% endblock %}
        <div id="pageContent" class="pageContent">
        {% block content %}
        {% endblock %}
        </div>
        <div id="emptyFooter" class="emptyFooter">
        </div>
    </div>
    {% block footer %}
    {% include "footer.tpl" %}
    {% endblock %}
    {% block javascript %}
    {% include "base.js.tpl" %}
    {% endblock %}
</body>
</html>