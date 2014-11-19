
<%include file="/3/functions/vector.mako" />
<%include file="/3/styles/dekning/sjo.mako" />

(function (M, MP, P) {
  var layer,
      selectControl,
      onPopupClose = null,
      onFeatureUnselect,
      onFeatureSelect,
      generatePopupMarkup,
      requestHandler;

  // dekningsoversikt - vector layer
  layer = new ol.layer.Vector({
    title: "${name}",
    shortid: "${id}", 
    style: NK.styles.dekning.sjo.default,
    visible: ${visible},
    layerGroup: "${layerGroup}",
    preferredBackground: "${preferredBackground}",

    source: new ol.source.GeoJSON({ 
      url: "${url}",
      projection: "EPSG:4326"
    }) 
  });

  M.addLayer(layer);

  var featureOverlay = new ol.FeatureOverlay({
    map: M,
    style: NK.styles.dekning.sjo.highlight
  });

  var highlight;
  var displayFeatureInfo = function(pixel) {
    var feature = M.forEachFeatureAtPixel(pixel, function(feature, layer) {
      return feature;
    });
    if (feature !== highlight) {
      if (!!highlight) {
        featureOverlay.removeFeature(highlight);
      } 
      if (!!feature) {
        featureOverlay.addFeature(feature);
      }
      highlight = feature;
    }
  };

  layer.on('visible', function(evt) {
    featureOverlay.setVisible(layer.getVisible());
  });

  $(M.getViewport()).on('mousemove', function(evt) {
    displayFeatureInfo(M.getEventPixel(evt.originalEvent));
  });

}(map, mapProj, proj));
