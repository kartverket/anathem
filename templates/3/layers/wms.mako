(function () {
  var wms = new ol.layer.Image({
    title: "${name}",
    source: new ol.source.ImageWMS({
      url: "${url}",
      crossOrigin: 'anonymous',
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
    displayInLayerSwitcher: false,
% endif
    visible: ${visible}
  });
// TODO: minZoom - create a trigger that zooms in when layer becomes visible (manually)

  map.addLayer(wms);
}());
