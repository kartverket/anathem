
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
    style: NK.styles.dekning.sjo["default"],
    visible: ${visible},
    layerGroup: "${layerGroup}",
    preferredBackground: "${preferredBackground}",

    source: new ol.source.GeoJSON({ 
      url: "${url}",
      projection: "EPSG:25833"
    }) 
  });

  M.addLayer(layer);

  var featureOverlay = new ol.FeatureOverlay({
    map: M,
    style: NK.styles.dekning.sjo.highlight
  });

  var highlight=[];
  var displayFeatureInfo = function(pixel) {
    var feature;
    M.forEachFeatureAtPixel(pixel, function(f, layer) {
      if ((!feature) || (feature.getGeometry().getArea() > f.getGeometry().getArea())) {
        feature = f;
      }
    });    
    var group = feature && feature.getId().split("_")[0];
    var check = highlight.length && highlight[0].getId().split("_")[0];
    if (group != check) {
      if (highlight.length) {
        for (var h in highlight) {
          featureOverlay.removeFeature(highlight[h]);
        }
        highlight = [];
      } 
      if (!!feature) {
        highlight = $.grep(layer.getSource().getFeatures(), function(feature) {
          return feature.getId().split("_")[0] == group;
        });
        for (var h in highlight) {
          featureOverlay.addFeature(highlight[h]);
        }
      }
    }
  };

  layer.on('visible', function(evt) {
    featureOverlay.setVisible(layer.getVisible());
  });

  $(M.getViewport()).on('mousemove', function(evt) {
    displayFeatureInfo(M.getEventPixel(evt.originalEvent));
  });

}(map, mapProj, proj));
