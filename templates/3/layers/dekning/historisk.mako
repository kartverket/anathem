<%include file="/3/functions/vector.mako" />
<%include file="/3/styles/dekning/historisk.mako" />

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
    style: NK.styles.dekning.historisk["default"],
    visible: ${visible},
    layerGroup: "${layerGroup}",
    preferredBackground: "${preferredBackground}",

    source: new ol.source.GeoJSON({ 
      url: "${url}"
    }) 
  });

  M.addLayer(layer);

  NK.functions.vector.addHoverControls(map, layer, NK.styles.dekning.historisk.highlight, Object.is, NK.styles.dekning.historisk.popupBuilder);
  NK.functions.vector.addSelectControls(map, layer, NK.styles.dekning.historisk.highlight, Object.is);

}(map, mapProj, proj));
