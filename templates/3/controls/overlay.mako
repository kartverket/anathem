## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};
NK.controls.Overlays = function(options) {
  options = options || {};
  var wrapper, btn;
  var cName = 'geoportal-button nkButton';
  
  this.title = 'Overlays';

  wrapper = document.createElement('div');
  btn    = document.createElement('button');
  wrapper.appendChild(btn);

  $(btn).click(this, this.toggle);
  
  btn.title = this.title;
  btn.className = btn.className === "" ? cName : btn.className + " " + cName;
  btn.innerHTML = '<svg xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="18.00239" height="17.992767" id="svg5952"> <defs id="defs5954"> <linearGradient id="linearGradient2485"> <stop id="stop2486" style="stop-color:#ffffff;stop-opacity:1" offset="0" /> <stop id="stop2487" style="stop-color:#aaaaaa;stop-opacity:1" offset="1" /> </linearGradient> <linearGradient id="linearGradient3480-1"> <stop id="stop3482-7" style="stop-color:#646464;stop-opacity:1" offset="0" /> <stop id="stop3484-4" style="stop-color:#000000;stop-opacity:1" offset="1" /> </linearGradient> <linearGradient id="linearGradient5704"> <stop id="stop5706" style="stop-color:#5a5a5a;stop-opacity:1" offset="0" /> <stop id="stop5708" style="stop-color:#000000;stop-opacity:1" offset="1" /> </linearGradient> <linearGradient x1="974.19751" y1="182.46863" x2="979.80444" y2="184.8026" id="linearGradient3147" xlink:href="#linearGradient2485" gradientUnits="userSpaceOnUse" gradientTransform="translate(-963.99154,-169)" /> <linearGradient x1="968.88806" y1="178.31856" x2="977.93347" y2="181.70978" id="linearGradient3149" xlink:href="#linearGradient5704" gradientUnits="userSpaceOnUse" gradientTransform="translate(-963.99154,-169)" /> <linearGradient x1="974.19751" y1="182.46863" x2="979.80444" y2="184.8026" id="linearGradient3152" xlink:href="#linearGradient2485" gradientUnits="userSpaceOnUse" gradientTransform="translate(-963.99154,-169)" /> <linearGradient x1="967.73901" y1="178.93727" x2="974.57471" y2="184.71498" id="linearGradient3154" xlink:href="#linearGradient3480-1" gradientUnits="userSpaceOnUse" gradientTransform="translate(-963.99154,-169)" /> </defs> <metadata id="metadata5957"> <rdf:RDF> <cc:Work rdf:about=""> <dc:format>image/svg+xml</dc:format> <dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage" /> <dc:title></dc:title> </cc:Work> </rdf:RDF> </metadata> <path d="m 5.5084634,16.5 10.9999996,0 -4,-5 -10.9999996,0 4,5 z" id="rect4045" style="opacity:0.48093842;color:#000000;fill:url(#linearGradient3152);fill-opacity:1;fill-rule:evenodd;stroke:url(#linearGradient3154);stroke-width:0.99994743;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:0;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;display:inline" /> <path d="m 5.5084634,13.5 10.9999996,0 -4,-5 -10.9999996,0 4,5 z" id="path4802" style="color:#000000;fill:url(#linearGradient3147);fill-opacity:1;fill-rule:evenodd;stroke:url(#linearGradient3149);stroke-width:0.99994743;stroke-linecap:square;stroke-linejoin:round;stroke-miterlimit:0;stroke-opacity:1;stroke-dasharray:none;stroke-dashoffset:0;marker:none;display:inline" /> <path d="m 3.0084634,3 0,-2 2,0 0,2 2,0 0,2 -2,0 0,2 -2,0 0,-2 -2,0 0,-2 2,0 z" id="path4048" style="fill:#000000;fill-opacity:1;fill-rule:evenodd;stroke:none" /> </svg>';


  this.cnt = document.createElement("div");
  this.cnt.className="cnt";

  var html = '';

  var url = options.url || "";

    html += '<div class="header" id="tabs-container">'+'Overlays';
    html += '<header><ol class="type-active tabs-menu">';
    html += '<li class="lagTab"><span class="step-number"><a href="#showLayersTab" id="showLayer">1</a></span> of <span>3</span><span class="step-label">'+'Layer'+'</span></li>';
    html += '<li class="legendTab"><span class="step-number"><a href="#legendTab" id="legend">2</a></span> of <span>3</span><span class="step-label">'+'Legend'+'</span></li>';
    html += '</ol></header>';
    html += '</div>';
    html += '<div class="tab">';
    html += '<div class="tab-content" id="showLayersTab"><div id="layerList" style="width:436px"></div></div>';
    html += '<div class="tab-content" id="legendTab"><div id="legendBox"">'+'No legend available.'+'</div></div>';
    html += '</div>';
    html += '<div id="addLayer">';
    html += '<form id="geoportal-form" style="height: 300px;">';
    html += 'Connect to service'+': ';
    html += '<span style="color:gray"><i>'+'e.g.'+': http://openwms.statkart.no/skwms1/wms.topo2</i></span><br/>';
    html += '<input id="geoportalUrl" type="url" style="width:100%;" value="'+url+'"/>';
    html += '<span style="margin-top:3px">WMS: <input checked name="gp-service-type" type="radio" value="wms"/> WFS: <input name="gp-service-type" type="radio" value="wfs"/></span>';
    html += '<button id="geoportalUrl-submit" type="button" style="float:right; margin:3px">'+'Connect'+'</button>';
    html += '</form>';
    html += '</div>';

  this.cnt.innerHTML = html;

  this.widget = NK.util.createWidget(this.cnt, 1);

  options.target.appendChild( this.widget );
  this.div = options.target;

  $("#geoportalUrl-submit").click(this, this.getLayers);

  $(".tabs-menu a").click(function (event) {
      event.preventDefault();
      $(this).parent().parent().parent().children().children().removeClass("current");
      $(this).parent().addClass("current");
      var tab = $(this).attr("href");
      $(".tab-content").not(tab).hide();
      $(tab).fadeIn();
  });

  this.addLayerSwitcher($('#layerList'));

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.Overlays, ol.control.Control);

NK.controls.Overlays.prototype.addLayerSwitcher = function(parent) {
  
        this.layersDiv = document.createElement("div");
        this.layersDiv.id = this.id + "_layersDiv";
        $(this.layersDiv).addClass("layersDiv");

        this.visibleLbl = document.createElement("div");
        this.visibleLbl.innerHTML = "Visible overlays";

        this.visibleDiv = document.createElement("table");
        this.visibleDiv.id = this.id + "_visibleTree";
        this.visibleDiv.innerHTML = "<colgroup><col width='*'></col><col width='20px'></col><col width='50px'></col></colgroup>";
        this.visibleDiv.innerHTML += "<thead><tr height=0><th></th><th></th><th></th></tr></thead>";
        this.visibleDiv.innerHTML += "<tbody><tr><td></td><td></td><td></td></tr></tbody>";
        $(this.visibleDiv).addClass("visibleDiv");

        this.layersDiv.appendChild(this.visibleLbl);
        this.layersDiv.appendChild(this.visibleDiv);

        this.availableLbl = document.createElement("div");
        var compactLabel = NK.compactMode ? "All" : "Only starred";
        this.availableLbl.innerHTML = "Available overlays"  + " - <button style='color:#ccc' id='compact-toggle'>" + 
                                      compactLabel + "</button>";


        this.availableDiv = document.createElement("table");
        this.availableDiv.id = this.id + "_availableTree";
        this.availableDiv.innerHTML = "<colgroup><col width='*'></col><col width='20px'></col><col width='50px'></col></colgroup>";
        this.availableDiv.innerHTML += "<thead><tr height=0><th></th><th></th><th></th></tr></thead>";
        this.availableDiv.innerHTML += "<tbody><tr><td></td><td></td><td></td></tr></tbody>";
        $(this.availableDiv).addClass("availableDiv");

        this.layersDiv.appendChild(this.availableLbl);
        this.layersDiv.appendChild(this.availableDiv);

        parent.append(this.layersDiv);
 
}

NK.controls.Overlays.prototype.getLayers = function (event) {
  var layerURL = document.getElementById('geoportalUrl').value;
  var type = $("input[name='gp-service-type']:checked").val();
  if (type == "wms") {
    NK.functions.addWMSLayer(layerURL);
  } else if (type == "wfs") {
    NK.functions.addWFSLayer(layerURL);
  }
};

NK.controls.Overlays.prototype.toggle = function (event) {
        var self = event.data;
        $(self.div).toggleClass('active');
};


NK.functions.addControlToContext(new NK.controls.Overlays({target: container}), context);

