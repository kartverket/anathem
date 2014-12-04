## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

options.svgIcon = '${svgIcon}';
options.svgOrderIllustration = '${svgOrderIllustration}';
options.svgFreeIllustration = '${svgFreeIllustration}';
options.orderUrl = '${orderUrl}';
options.freeUrl = '${freeUrl}';

NK.controls = NK.controls || {};
NK.controls.MakeYourOwn = function(options) {
  options = options || {};
  var wrapper, btn;
  var cName = 'make-your-own-button nkButton';
  
  this.title = 'Make your own maps';

  wrapper = document.createElement('div');
  btn    = document.createElement('button');
  wrapper.appendChild(btn);

  $(btn).click(this, this.toggle);
  
  btn.title = this.title;
  btn.className = btn.className === "" ? cName : btn.className + " " + cName;
  btn.innerHTML = options.svgIcon;

  this.cnt = document.createElement("div");
  this.cnt.className="cnt";

  var html = '<div class="header">',
      nonFreeLink,
      nonFreeButton,
      nonFreeContent = '',
      freeButton,
      freeLink,
      freeContent = '';

  html += '<h1 class="h">' + 'Make your own map' + '</h1>';
  html += '</div>';
  this.cnt.innerHTML = html;

  nonFreeLink = document.createElement('a');
  nonFreeLink.setAttribute('href', options.orderUrl);
  nonFreeLink.setAttribute('class', 'external-link nonfree-data');
  nonFreeContent += '<h2 class="h">' + 'Illustrative maps:' + '</h2>';
  if (options.svgOrderIllustration) {
    nonFreeContent += options.svgOrderIllustration;
  }
  nonFreeContent += '<span>' + 'Simple illustration maps of Norway, in several different formats. These maps can be used as they are, or easily be transformed to suit specific needs.' + '</span>';
  nonFreeLink.innerHTML = nonFreeContent;

  freeLink = document.createElement('a');
  freeLink.setAttribute('href', options.freeUrl);
  freeLink.setAttribute('class', 'external-link free-data');
  freeContent += '<h2 class="h">' + 'Map data:' + '</h2>';
  if (options.svgFreeIllustration) {
    freeContent += options.svgFreeIllustration;
  }
  freeContent += '<span>' + 'Map data are geographic data in vector format.' + '</span>';
  freeLink.innerHTML = freeContent;

  this.cnt.appendChild(nonFreeLink);
  this.cnt.appendChild(freeLink);

  $(freeLink).click(this, function() {
    window.open(freeLink.href);
  });
  $(nonFreeLink).click(this, function() {
    window.open(nonFreeLink.href);
  });

  this.widget = NK.util.createWidget(this.cnt, 1);

  options.target.appendChild( this.widget );
  this.div = options.target;

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.MakeYourOwn, ol.control.Control);

NK.controls.MakeYourOwn.prototype.toggle = function (event) {
        var self = event.data;
        $(self.div).toggleClass('active');
};

goog.object.extend(options, {target:container});
NK.functions.addControlToContext(new NK.controls.MakeYourOwn(options), context);

