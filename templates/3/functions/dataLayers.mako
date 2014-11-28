NK.supportedCRS = ['EPSG:32633','EPSG:25833','urn:ogc:def:crs:EPSG::32633','urn:ogc:def:crs:EPSG::25833'];
NK.supportedWFSFormats = ['application/json; subtype=geojson','text/xml; subtype=gml/3.1.1', 'text/xml; subtype=gml/3.2.1'];

NK.functions.getWMSCapabilities = function (url) {
  return NK.functions.corsRequest(url, {"service":"WMS", "request":"GetCapabilities"});
};
NK.functions.getWFSCapabilities = function (url) {
  return NK.functions.corsRequest(url, {"service":"WFS", "request":"GetCapabilities", "version":"1.1.0"});
};
NK.functions.getWCSCapabilities = function (url) {
  return NK.functions.corsRequest(url, {"service":"WCS", "request":"GetCapabilities"});
};
NK.functions.corsRequest = function (url, params) {
  if(!!url) {
    if (url.slice(-1) != '?') {url = url+'?';}
    for (var k in params) {
      url += k+"="+params[k]+"&";
    }
    return $.ajax({
      url: '/ws/px.py',
      type: 'GET',
      data: url,
      dataType: 'xml'
    });
  }
};

NK.functions.addWMSLayer = function(wmsUrl) {
  if (NK.util.getLayersBy("url",wmsUrl).length) {return;}
  var layers = [], formats=[], crs=[], fiFormats=[], serviceParms={}, layerParms;

  var resultWMS = NK.functions.getWMSCapabilities(wmsUrl);
  resultWMS.error(function (msg) { NK.functions.log(msg.responseText); });
  resultWMS.done(function (xml) {
    serviceParms['version'] = $(xml).children()[0].getAttribute("version");
    $(xml).find('Service').each(function () {
      serviceParms['serviceTitle'] = $(this).children('Title').text();
    });
    $(xml).find('GetFeatureInfo').each(function () {
      $(this).children('Format').each(function() {
        fiFormats.push($(this).text());
      });
    });
    serviceParms['featureInfoFormats'] = fiFormats;
    $(xml).find('GetMap').each(function () {
      $(this).children('Format').each(function () {;
        formats.push($(this).text());
      });
    });
    serviceParms['formats'] = formats;
    var attribution;
    $(xml).find('Attribution').each(function () {
      var href = $(this).children('OnlineResource')[0];
      var logo = $(this).children('LogoURL').children('OnlineResource')[0];
      attribution = { 
          'title': $(this).children('Title').text(),
          'href' : href && href.getAttribute("xlink:href"),
          'logo' : logo && logo.getAttribute("xlink:href")
      }
    });
    if (!attribution) { attribution={'title':'missing', 'href':'#'}; }
    serviceParms['attribution'] = attribution;
    $(xml).find('AccessConstraints').each(function () {
      serviceParms['constraints'] = $(this).text();
    });
    $(xml).find('CRS').each(function () {
      crs.push($(this).text());
    });
    serviceParms['crs'] = crs;
    $(xml).find('Layer').each(function () {
      layerParms={};
      var name = $(this).children('Name').text();
      if (!name) {return;}

      /* if this layer is a child layer, identify parent */
      if ($(this).parent()[0].nodeName=="Layer") {
        layerParms['parent'] = $(this).parent().children('Title').text() || $(this).parent().children('Name').text();
      }

      layerParms['title'] = $(this).children('Title').text();
      layerParms['visible'] = !!NK.visibleLayerQueue[name];
      layerParms['opacity'] = NK.opacityQueue[name] || 1.0;
      if (name in NK.opacityQueue) {delete NK.opacityQueue[name];}
      if (name in NK.visibleLayerQueue) {delete NK.visibleLayerQueue[name];}
      layers.push(name);
      var bbox = $(xml).find('BoundingBox');
      if (!!bbox) {
        var atts = bbox[0].attributes;
        var srs = atts['CRS'] || atts['SRS'];
        if (srs && (srs.value == map.getView().getProjection().getCode())) { 
          layerParms['layerBounds'] = new OpenLayers.Bounds(atts["minx"].value, atts["miny"].value,
                                                            atts["maxx"].value, atts["maxy"].value);
        }
      }
      layerParms['layerText']=name;
      NK.functions.createDynamicWMSLayer(layerParms['title'], wmsUrl, $.extend({},serviceParms,layerParms));
      if (!!NK.xdm) {
        NK.functions.postMessage({"type":"layerLoaded", "title":layerParms['title'], "parent":layerParms['parent'],"url":wmsUrl}); 
      }
    });
    NK.functions.updateHistory();
  });

  if (NK.controls.Geoportal) {
    var geoportal =  NK.util.getControlsByClass(NK.controls.Geoportal)[0]; // heh, the optimism!
    geoportal.showControls(wmsUrl);
    geoportal.displayLayerList();
  }
};

/* monkeypatch for ol.source.TileWMS.getRequestUrl_ to support custom CRS ***/
ol.source.ImageWMS.prototype.getRequestUrl_orig = ol.source.ImageWMS.prototype.getRequestUrl_ ;
ol.source.ImageWMS.prototype.getRequestUrl_ = function(extent, size, pixelRatio, projection, params) {
  if (!!this.getProjection()) {
    projection = this.getProjection();
  }
  return this.getRequestUrl_orig(extent, size, pixelRatio, projection, params);
};


NK.functions.createDynamicWMSLayer = function (name, url, parms) {
  var crs = $.grep(parms['crs'], function(s) {
    return ($.inArray(s, NK.supportedCRS)>-1)
  })[0];

  var wms = new ol.layer.Image({
    title: parms['title'],
    source: new ol.source.ImageWMS({ 
      url: url,
      projection: crs,
      params: {
        LAYERS: parms['layerText'],
        VERSION: parms['version'], 
        //gkt: NK.gkToken || '',
        TRANSPARENT: true,
        EXCEPTIONS: 'XML',
        FORMAT: 'image/png'
      }
    }),
    serviceTitle: parms['serviceTitle'],
    parent: parms['parent'] || null,
    isBaseLayer: false,
    visible: parms['visible'],
    opacity: parms['opacity'] || 1.0,
    isUrlDataLayer: true,
    dataFormats: parms['formats'],
    attribution: parms['attribution'],
    constraints: parms['constraints'],
    type: 'wms'
  });
  if (!!parms['bounds']) {
    wms.set('maxExtent',parms['bounds']);
  }
  if (!!parms['featureInfoFormats']) {
    var formats = parms['featureInfoFormats'];
    var preferredFormats = ['application/vnd.ogc.wms_xml', 'text/xml', 'text/plain', 'text/html'];
    var preferredFormat  = 'x';

    while (preferredFormat && formats.indexOf(preferredFormat)==-1) {
      preferredFormat = preferredFormats.shift();
    }

    /* TODO *********
    if (!!preferredFormat) {
      var popupFn = NK.functions.popup.wmsFeatureInfoPopup;
      var featureInfo = new OpenLayers.Control.WMSGetFeatureInfo({
        url: url,
        proxyUrl: "/ws/px.py?"+url,
        title: parms['title'],
        queryVisible: true,
        infoFormat: preferredFormat,
        eventListeners: {
          "getfeatureinfo": function(event) {
            var popup = new OpenLayers.Popup.FramedSideAnchored(null, map.getLonLatFromPixel(event.xy), null, popupFn(event, formats), null, true,
                              NK.functions.closePopupCallBack, {x: 10, y: -65}, 'selected-feature-popup, user-marker')
            map.addPopup(popup, true);
            if (!event.features.length && (!event.text || !event.text.trim().length)) {
              setTimeout(function() {
                map.removePopup(popup);
              }, 3000);
            }
          }
        }
      });
      wms.featureInfoControl = featureInfo;
      wms.events.register('visibilitychanged', wms, function() {
        if(this.getVisibility()) {
          featureInfo.activate();
          if (!!this.maxExtent) {
            var extent = this.maxExtent;
            if (!extent.containsLonLat(map.getCenter())) {
              map.zoomToExtent(extent);
            }
          }
        } else {
          featureInfo.deactivate();
        }
      });
      map.addControl(featureInfo);
      if (parms['visible']) {
        featureInfo.activate();
      }
    }
    *********************/
  }
  map.addLayer(wms);
  // NK.functions.createLegend();
};

NK.functions.addWFSLayer = function(wfsUrl) {
  if (NK.util.getLayersBy("url",wfsUrl).length) {return;}
  var layers = [], crs=[], formats={}, serviceParms={}, layerParms;
  var resultWFS = NK.functions.getWFSCapabilities(wfsUrl);
  resultWFS.error(function (msg) { NK.functions.log(msg.responseText); });
  resultWFS.done(function (xml) {
    var exception = $(xml).find('ExceptionText').text();
    if (!!exception) {
      NK.functions.log(exception);
    } else {
      serviceParms['version'] = '1.1.0'; // we only support this atm
      $(xml).find('Service').each(function () {
        serviceParms['serviceTitle'] = $(this).children('Title').text();
      });
      $(xml).find('OutputFormats').each(function () {
        $(this).children('Format').each(function () {;
          formats[$(this).text()] = true;
        });
      });
      serviceParms['formats'] = Object.keys(formats);
      $(xml).find('AccessConstraints').each(function () {
        serviceParms['constraints'] = $(this).text();
      });
      var attribution;
      $(xml).find('Attribution').each(function () {
        var href = $(this).children('OnlineResource')[0];
        var logo = $(this).children('LogoURL').children('OnlineResource')[0];
        attribution = { 
          'title': $(this).children('Title').text(),
          'href' : href && href.getAttribute("xlink:href"),
          'logo' : logo && logo.getAttribute("xlink:href")
        }
      });
      if (!attribution) { attribution={'title':'missing', 'href':'#'}; }
      serviceParms['attribution'] = attribution;
      $(xml).find('DefaultSRS').each(function () {
        crs.push($(this).text());
      });
      $(xml).find('OtherSRS').each(function () {
        crs.push($(this).text());
      });
      $(xml).find('SpatialOperator[name="BBOX"]').each(function () {
        $(xml).find('GeometryOperand').each(function () {
          if ($(this).text() == "gml:Envelope") {
            serviceParms['bboxFilter'] = true;
          }
        });
      });
      serviceParms['crs'] = crs;
      $(xml).find('FeatureType').each(function () {
        layerParms = {};
        var name = $(this).children('Name').text();
        if (!name) {return;}
        layers.push(name);
        layerParms['title'] = $(this).children('Title').text();
        layerParms['visible'] = name in NK.visibleLayerQueue;
        if (name in NK.visibleLayerQueue) {delete NK.visibleLayerQueue[name];}
        if (name in NK.opacityQueue) {delete NK.opacityQueue[name];}
        layerParms['opacity'] = NK.opacityQueue[name] || 1.0;
        layerParms['type'] = name;
        NK.functions.createDynamicWFSLayer(layerParms['title'], wfsUrl, $.extend({},serviceParms, layerParms));
        if (!!NK.xdm) {
          NK.functions.postMessage({"type":"layerLoaded", "title":layerParms['title'], "url":wfsUrl}); 
        }
      });
      NK.functions.updateHistory();
    }
  });

  if (NK.controls.Geoportal) {
    //var geoportal =  map.getControlsByClass('OpenLayers.Control.Geoportal')[0];
    geoportal.showControls(wfsUrl);
    geoportal.displayLayerList();
  }
};

/*********** monkey patch to support more GML name spaces ***/
for (var i in ol.format.GML) {
  if (!!ol.format.GML[i]['http://www.opengis.net/gml']) {
    ol.format.GML[i]['http://www.opengis.net/gml/3.2'] = ol.format.GML[i]['http://www.opengis.net/gml'];
  }
}
/************************************************************/
/** monkey patch to accept any name space in ol.xml.parse ***/
ol.xml.parse = function(parsersNS, node, objectStack, opt_this) {
  if (!!parsersNS["*"]) {
    parsersNS[node.firstElementChild.namespaceURI] = parsersNS["*"];
  } 
  var n;
  for (n = node.firstElementChild; !goog.isNull(n); n = n.nextElementSibling) {
    var parsers = parsersNS[n.namespaceURI];
    if (goog.isDef(parsers)) {
      var parser = parsers[n.localName] || parsers[n.nodeName];
      if (goog.isDef(parser)) {
        parser.call(opt_this, n, objectStack);
      }
    }
  }
};
/************************************************************/
/** monkey patch to read GML features properly *************/
ol.format.GML.readFeature_ = function(node, objectStack) {
  var n, i, hasGeometry;
  var knownGeometries = Object.keys(ol.format.GML.GEOMETRY_PARSERS_['http://www.opengis.net/gml']);
  var fid = node.getAttribute('fid') ||
      ol.xml.getAttributeNS(node, 'http://www.opengis.net/gml', 'id');
  var values = {}, geometryName;
  for (n = node.firstElementChild; !goog.isNull(n);
      n = n.nextElementSibling) {
    // Assume there is only one geometry node, and that is has a know geometry as child node:
    hasGeometry = false;
    for (i=0;i<n.childNodes.length;i++) {
      hasGeometry = hasGeometry | (knownGeometries.indexOf(n.childNodes[i].localName) > -1);
    }
    if (!hasGeometry) {
      var data = ol.xml.getStructuredTextContent(n, false);
      if (goog.object.isEmpty(data)) {
        data = undefined;
      }
      values[ol.xml.getLocalName(n)] = data;
    } else {
      geometryName = ol.xml.getLocalName(n);
      values[geometryName] = ol.format.GML.readGeometry(n, objectStack);
    }
  }
  var feature = new ol.Feature(values);
  if (goog.isDef(geometryName)) {
    feature.setGeometryName(geometryName);
  }
  if (fid) {
    feature.setId(fid);
  }
  return feature;
};
/************************************************************/
ol.xml.getStructuredTextContent = function(node, normalizeWhitespace) {
  var accumulator = {};
  if (node.nodeType == goog.dom.NodeType.CDATA_SECTION ||
      node.nodeType == goog.dom.NodeType.TEXT) {
    accumulator["text_"] = normalizeWhitespace ? String(node.nodeValue).replace(/(\r\n|\r|\n)/g, '') : node.nodeValue;
  } else {
    var n;
    for (n = node.firstChild; !goog.isNull(n); n = n.nextSibling) {
      if (n.nodeType == goog.dom.NodeType.TEXT) { 
        accumulator["text_"] = (accumulator["text_"] || "") + (normalizeWhitespace ? String(n.nodeValue).replace(/(\r\n|\r|\n)/g, '') : n.nodeValue); 
      } else {
        accumulator[n.localName] = ol.xml.getStructuredTextContent(n, normalizeWhitespace, {});
      }
    }
  }
  return accumulator;
};



NK.functions.createDynamicWFSLayer = function (name, url, parms) {
  // TODO: read GeoJSON if supported  
  // var format = new ol.format.GeoJSON();

  var crs = $.grep(parms['crs'], function(s) {
    return ($.inArray(s, NK.supportedCRS)>-1)
  })[0];
  var mimeFormat = 'text/xml; subtype=gml/3.2.1',
      format;
  for (var f in NK.supportedWFSFormats) {
    if (parms.formats.indexOf(NK.supportedWFSFormats[f])>-1) {
      mimeFormat = NK.supportedWFSFormats[f];
      break;
    }
  }
  if (mimeFormat.indexOf('gml')>-1) {
    format = new ol.format.WFS({
      featureNS:   '*', //see monkey patch above,
      //featureNS:   'http://mapserver.gis.umn.edu/mapserver', //FIXME: parms['namespace'],
      featureType: parms['type']
    });
  } else { 
    format = ol.format.GeoJSON();
  }
  var source = new ol.source.ServerVector({
    format: format,
    loader: function(extent, resolution, projection) {
      var request = "/ws/px.py?" + url + "?service=WFS&version=1.1.0&request=GetFeature";
      request += "&typename=" + parms['type'];
      request += "&srsName=" + crs; 
      request += "&outputFormat=" + mimeFormat;
      //if (parms['bboxFilter']) {
      //  request += '&filter=<Filter%20xmlns="http://www.opengis.net/ogc"><BBOX><Envelope%20srsName="'+ crs +'"%20xmlns="http://www.opengis.net/gml"><lowerCorner>'+extent[0]+' '+extent[1]+'</lowerCorner><upperCorner>'+extent[2]+' '+extent[3]+'</upperCorner></Envelope></BBOX></Filter>';
      //} else {
        request += "&bbox="+extent.join(",");
      //}
      //request += "&bbox="+extent.join(",") + "," + crs;
      $.ajax({url:request}).done(function(response) {
        var features = source.readFeatures(response);
        source.addFeatures(features);
      });
    }
  });
  var wfs = new ol.layer.Vector({
    source: source,
    style: NK.styles.wfs['default'],
    type: 'wfs',
    url:  url,
    featureType: parms['type'],
    dataFormats: parms['formats'],
    attribution: parms['attribution'],
    constraints: parms['constraints'],
    visible:     parms['visible'],
    opacity:     parms['opacity'], 
    isUrlDataLayer: true
  });

  map.addLayer(wfs);
  NK.functions.vector.addHoverControls(map, wfs, NK.styles.wfs.highlight); 
} 
