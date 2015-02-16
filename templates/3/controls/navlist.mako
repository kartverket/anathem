## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};
NK.controls.NavList = function (options) {
  options = options || {};
  var wrapper, btn;

  wrapper = document.createElement('div');
  wrapper.className = 'navbar navbar-default';

  btn = document.createElement('div');
  btn.className = 'btn-group';

  wrapper.appendChild(btn);

  var html = '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">';
  html += 'Se andre karttjenester <span class="caret"></span>';
  html += '</button>';
  html += '<ul class="dropdown-menu" role="menu">';
  html += '<li><a href="http://norgeskart.no/ssr">Stedsnavn</a></li>';
  html += '<li><a href="http://norgeskart.no/nrl">NRL</a></li>';
  html += '<li><a href="http://norgeskart.no/fastmerker">Fastmerker</a></li>';
  html += '<li><a href="http://norgeskart.no/tilgjengelighet">Tilgjengelighet</a></li>';
  html += '<li class="divider"></li>';
  html += '<li><a href="http://kartverket.no">kartverket</a></li>';
  html += '</ul>';

  btn.innerHTML = html;
  $(btn).click(this, this.toggle);

  ol.control.Control.call(this, {
    element: wrapper,
    target : options.target
  });
};
ol.inherits(NK.controls.NavList, ol.control.Control);

NK.controls.NavList.prototype.toggle = function (event) {
  var self = event.data;
  $(self.div).toggleClass('active');
};


NK.functions.addControlToContext(new NK.controls.NavList({target: container}), context);

