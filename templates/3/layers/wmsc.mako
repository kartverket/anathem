(function () {
  var wms = new ol.layer.Tile({
    title: "${name}",
    source: new ol.source.TileWMS({
      url: "${url}",
      params: {
        LAYERS: "${layers}", 
        VERSION: "1.1.1",
% if usetoken:
        gkt: NK.gkToken,
% endif    
        TRANSPARENT: ${transparent}, 
% if styles:
        STYLES: "${styles}",
% endif
        FORMAT: "${format}"
      }
    }),
    shortid: "${id}", 
    isBaseLayer: false,
% if layerGroup:
    layerGroup: "${layerGroup}",
% endif
% if hidefromlayerswitcher:
    displayInLayerSwitcher: false;
% endif
    visible: ${visible}, 
  });

  map.addLayer(wms);
}());
