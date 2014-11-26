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

  NK.functions.vector.addHoverControls(map, layer, NK.styles.dekning.sjo.highlight, function(a,b) {
    if ((!a)||(!b)) {return false;}
    return a.getId().split("_")[0] == b.getId().split("_")[0];
  });
}(map, mapProj, proj));
