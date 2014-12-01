<%inherit file="/3/controls/controlcontext.mako" />
% if svgLogo:
	options.svgLogo = '${svgLogo}';
% endif
% if left:
	options.logoPaddingLeft = '${left}';
% endif

NK.controls = NK.controls || {};
NK.controls.Logo = function(options) {
  options = options || {};
  var wrapper, img, link;
  
  wrapper = document.createElement('div');

  img = document.createElement('img');
  img.src = "img/logo.png";
  img.alt  = "Norgeskart.no - Kartverket";

  link = document.createElement('a');
  link.href = "http://kartverket.no";
  link.target = "_blank";

  if (options.svgLogo) {
    link.innerHTML = options.svgLogo;
  }
  if (options.logoPaddingLeft) {
    img.style["padding-left"]=options.logoPaddingLeft;
  }
  link.appendChild(img);
  wrapper.appendChild(link);

  wrapper.className='logoDiv';

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.Logo, ol.control.Control);

NK.functions.addControlToContext(new NK.controls.Logo({target: container}), context);

