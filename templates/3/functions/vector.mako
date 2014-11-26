% if not 'vectorControls' in vars:  

NK.functions = NK.functions || {};
NK.functions.vector = NK.functions.vector || {};

NK.functions.vector.addHoverControls = function (map, layer, style, featureIdentity) {

  var featureOverlay = new ol.FeatureOverlay({
    map: map,
    style: style
  });

  var highlight=[];
  var displayFeatureInfo = function(pixel) {
    var feature;
    map.forEachFeatureAtPixel(pixel, function(f, layer) {
      if ((!feature) || (feature.getGeometry().getArea() > f.getGeometry().getArea())) {
        feature = f;
      }
    });
    if (!(highlight.length && featureIdentity(feature, highlight[0]))) {
      if (highlight.length) {
        for (var h in highlight) {
          featureOverlay.removeFeature(highlight[h]);
        }
        highlight = [];
      }
      if (!!feature) {
        highlight = $.grep(layer.getSource().getFeatures(), function(f) {
          return featureIdentity(feature, f);
        });
        for (var h in highlight) {
          featureOverlay.addFeature(highlight[h]);
        }
      }
    }
  };

  var mousemoveFn = function(evt) {
    displayFeatureInfo(map.getEventPixel(evt.originalEvent));
  };

  layer.on('change:visible', function(evt) {
    if (layer.getVisible()) {
      $(map.getViewport()).on('mousemove', mousemoveFn);
    } else {
      $(map.getViewport()).off('mousemove', mousemoveFn);
    }
  });

};


<% vars['vectorControls']=True %>
% endif
