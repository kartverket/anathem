(function (context, containerParam, collect) {

  var html = '<li class="dropdown">';
      html += '<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false">Se andre karttjenester <span class="caret"></span></a>';
        html += '<ul class="dropdown-menu" role="menu">';
        html += '<li><a href="http://norgeskart.no/" target="_blank">Norgeskart</a></li>';
        html += '<li role="presentation" class="divider"></li>';
        html += '<li><a href="http://norgeskart.no/ssr" target="_blank">Stedsnavn</a></li>';
        html += '<li><a href="http://norgeskart.no/tilgjengelighet" target="_blank">Tilgjengelighet</a></li>';
        html += '<li><a href="http://norgeskart.no/nrl" target="_blank">NRL</a></li>';
        html += '<li><a href="http://norgeskart.no/fastmerker" target="_blank">Fastmerker</a></li>';
      html += '</ul>';
      html += '</li>';

  collect.innerHTML = html;

}(controlContext, container, collect));
