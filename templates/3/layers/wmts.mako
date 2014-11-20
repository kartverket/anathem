% if not 'layerTypeWMTS' in vars:

NK.addLayerType = NK.addLayerType || {};
NK.addLayerType.WMTS = (function (M, MP) {
  var matrixIds = [],
      resolutions = [],
      i;
  var extent = map.getView().getProjection().getExtent();
  var size = ol.extent.getWidth(extent) / 256;

  for (i = 0; i <= NK.zoomLevels; ++i) {
    matrixIds[i] = [];
    resolutions[i] = size / Math.pow(2, i);
    matrixIds[i] = MP.getCode() + ":" + i;
  } 


  return function (id, name, url, layer, options) {
    var layer, 
        layerOptions;
    var myMatrixIds = [],
        customOrigin,
        customExtent;

    if (options.shortMatrixIds) {
      for (i = 0; i <= NK.zoomLevels; ++i) {
        myMatrixIds.push( ""+i);
      }
    }
   
     
    if (options.tileOrigin) {
      customOrigin = options.tileOrigin.split(",");
    }
    if (options.databbox) {
      customExtent = options.databbox.split(",");
    }

    var sourceOptions ={
        layer: layer,
        matrixSet: options.customProj || MP.getCode(),
        projection: MP,
        format: "image/png",
        tileGrid: new ol.tilegrid.WMTS({ 
          origin: customOrigin || ol.extent.getTopLeft(extent),
          resolutions: resolutions,
          matrixIds: myMatrixIds.length ? myMatrixIds : matrixIds
        }),
        attributions: [new ol.Attribution({html: "<a href='http://kartverket.no/Kart/Gratis-kartdata/Lisens/'>CC-BY</a> <a href='http://kartverket.no'>Kartverket</a>"})]
    };
    if (typeof(url)==='string') {
      sourceOptions['url']=url;
    } else { 
      sourceOptions['urls']=url;
    }
    if (!!customExtent) {
      sourceOptions['extent'] = customExtent;
    } 
    var source = new ol.source.WMTS(sourceOptions);

    layerOptions = {
      title: name,
      source: source,
      shortid: id, 
      isBaseLayer: !!options.isBaseLayer,
      visible: !!options.visible
    };

    if (!!customExtent) {
      layerOptions['extent'] = customExtent;
    } 
    if (!!options.minResolution) {
      layerOptions['minResolution']=options.minResolution;
    }

    layer = new ol.layer.Tile(layerOptions);

    M.addLayer(layer);
    return layer;
  };
}(map, mapProj));

<% vars['layerTypeWMTS']=True %>
% endif

(function () {
  var url, 
      options = {};

  % if url:
    url = "${url}";
  % else:
    url = NK.mapservers.wmts;
  % endif

  % if hidefromlayerswitcher:
    options.displayInLayerSwitcher = false;
  % else:
    options.displayInLayerSwitcher = true;
  % endif

  % if visible:
    options.visible = true;
  % endif

  % if layerGroup:
    options.layerGroup = "${layerGroup}";
  % endif

  % if usetoken:
    options.params = { 'gkt': NK.gkToken };
  % endif

  % if isBaseLayer:
    options.isBaseLayer = true;
  % endif

  % if minResolution:
    options.minResolution = ${minResolution};
  % endif

  % if epsg:
    options.customProj = "${epsg}"
  % endif

  % if shortMatrixIds:
    options.shortMatrixIds = true
  % endif

  % if extent:
    options.extent = "${extent}"
  % endif

  % if databbox:
    options.databbox = "${databbox}"
  % endif

  % if tileorigin:
    options.tileOrigin = "${tileorigin}"
  % endif

  var layer = NK.addLayerType.WMTS('${id}', '${name}', url, '${layer}', options);

  % if onZoom:
    ${onZoom}
  % endif
}());
