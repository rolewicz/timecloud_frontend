<div id="errors" class="errors">
    <div class="errorsBox" id="errorsBox" {% if errors %}style="padding-top: 20px;"{% endif %}>
    <ul id="errorList">
        {% for e in errors %}
        <li> {{e}} <img src="/static/images/close.png" alt="close" class="closeButton" onclick="function() {closeFunction(this);};"/></li>
        {% endfor %}
    </ul>
    </div>
</div>
<form name="errorsForm" id="errorsForm" action="" method="POST">
    <input type="hidden" name="displayErrors" value="">
</form>
