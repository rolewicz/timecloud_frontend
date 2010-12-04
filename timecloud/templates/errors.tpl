<div id="errors" class="errors">
{% if errors %}
    <div class="errorsBox">
    <ul>
        {% for e in errors %}
        <li> {{e}} </li>
        {% endfor %}
    </ul>
    </div>
{% endif %}
</div>
<form name="errorsForm" id="errorsForm" action="" method="POST">
    <input type="hidden" name="displayErrors" value="">
</form>
