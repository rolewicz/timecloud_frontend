<div id="globalMenu" class="globalMenu">
    <ul>
    {% for link in globalLinkList %}
        <li class='' onmouseover="this.className = 'mouseover'" onmouseout="this.className=''" >
            <a href="{{link.url}}">{{link.name}}</a>
        </li>
    {% endfor %}
    </ul>
</div>