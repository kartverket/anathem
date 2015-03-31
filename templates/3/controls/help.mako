## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};
NK.controls.Help = function(options) {
  options = options || {};
  var wrapper, btn;
  var cName = 'help-button nkButton';
  
  this.title = 'Help';

  wrapper = document.createElement('div');
  btn    = document.createElement('button');
  wrapper.appendChild(btn);

  $(btn).click(this, this.toggle);
  
  btn.title = this.title;
  btn.className = btn.className === "" ? cName : btn.className + " " + cName;
  btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" viewBox="0 0 280.228821 280.228821" version="1.1"><g id="surface1"><path style="fill:none;stroke-width:9.6;stroke-linecap:butt;stroke-linejoin:round;stroke:rgb(100%,100%,100%);stroke-opacity:1;stroke-miterlimit:4;" d="M 275.429688 140.113281 C 275.429688 214.808594 214.808594 275.429688 140.113281 275.429688 C 65.421875 275.429688 4.800781 214.808594 4.800781 140.113281 C 4.800781 65.421875 65.421875 4.800781 140.113281 4.800781 C 214.808594 4.800781 275.429688 65.421875 275.429688 140.113281 Z M 275.429688 140.113281 "/><path style=" stroke:none;fill-rule:nonzero;fill:rgb(100%,100%,100%);fill-opacity:1;" d="M 113.675781 59.667969 C 113.675781 52.898438 116.25 47.125 121.398438 42.347656 C 126.542969 37.570312 132.710938 35.179688 139.894531 35.179688 C 147.1875 35.179688 153.40625 37.570312 158.554688 42.347656 C 163.699219 47.125 166.273438 52.898438 166.273438 59.667969 C 166.273438 66.339844 163.699219 72.113281 158.554688 76.988281 C 153.40625 81.769531 147.1875 84.15625 139.894531 84.15625 C 132.710938 84.15625 126.542969 81.769531 121.398438 76.988281 C 116.25 72.113281 113.675781 66.339844 113.675781 59.667969 Z M 164.023438 105.511719 L 164.023438 246.464844 L 116.25 246.464844 L 116.25 105.511719 L 164.023438 105.511719 "/></g></svg>';

  this.cnt = document.createElement("div");
  this.cnt.className="cnt";

  var mac = (navigator.platform && navigator.platform.indexOf('Mac') !== -1) || (navigator.userAgent && navigator.userAgent.indexOf('iPhone') !== -1);
  var ctrlKey = mac ? '⌘ ' : 'Ctrl + ';
  var html = '<div id="shortcuts" class="help-menu">';
  html += '<h1 class="h">' + 'Keyboard shortcuts' + '</h1>';
  html += '<div class="shortcuts-panel"><p>' + 'You can navigate using the following keyboard shortcuts' + ':</p>';
  html += '<p>' + 'Press TAB to change selected control. Press ENTER to activate the selected control.' + '</p>';

  html += '<table><thead><tr><th scope="col">' + 'Keyboard shortcut' + '</th><th scope="col">' + 'Function' + '</th></tr></thead><tbody>';
  html += '<tr><td>F11</td><td>'+'Full screen'+'</td></tr>';
  html += '<tr><td>' + ctrlKey + 'P</td><td>'+ 'Print'+'</td></tr>';
  html += '<tr><td>+ og -</td><td>'+ 'Zoom'+'</td></tr>';
  html += '<tr><td>'+ 'Arrow keys'+'</td><td>'+ 'Pan'+'</td></tr>';
  html += '<tr><td>Home, End, PageUp, PageDown</td><td>'+  'Fast panning'+'</td></tr>';
  html += '</tbody></table>';
  html += '</div>';

  html += '<h1 class="h">Ofte stilte sp\u00f8rsm\u00e5l om norgeskart.no</h1>';
  html += '<div id="faqBox" class="faq-panel">'
  html += '</div>';

  html += '</div>';
  this.cnt.innerHTML = html;

  this.widget = NK.util.createWidget(this.cnt, 1);

  options.target.appendChild( this.widget );
  this.div = options.target;

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });
  $.ajax({
    url: 'http://skrivte57.statkart.no/miecar/js/faq.txt',
    success: function (response, status, request) {
      var faq = request.responseText.replace(/[\"\r\n]/g, '');
      $("#faqBox").html(faq);

      $(".faq-panel").accordion({
        collapsible: true,
        heightStyle: "content"
      });
      $(".help-menu").accordion({
        collapsible: true,
        heightStyle: "content",
        active: false
      });
    },
    type: 'GET'
  });
};
ol.inherits(NK.controls.Help, ol.control.Control);

NK.controls.Help.prototype.toggle = function (event) {
        var self = event.data;
        $(self.div).toggleClass('active');
};


NK.functions.addControlToContext(new NK.controls.Help({target: container}), context);

