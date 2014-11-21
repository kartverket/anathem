
<%include file="/3/functions/vector.mako" />
<%include file="/3/styles/dekning/land.mako" />

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
    style: NK.styles.dekning.land["default"],
    visible: ${visible},
    layerGroup: "${layerGroup}",
    preferredBackground: "${preferredBackground}",

    source: new ol.source.GeoJSON({ 
      url: "${url}"
    }) 
  });

  M.addLayer(layer);

  var featureOverlay = new ol.FeatureOverlay({
    map: M,
    style: NK.styles.dekning.land.highlight
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

  var mousemoveFn = function(evt) {
    displayFeatureInfo(M.getEventPixel(evt.originalEvent));
  };

  layer.on('change:visible', function(evt) {
    if (layer.getVisible()) {
      $(M.getViewport()).on('mousemove', mousemoveFn);
    } else {
      $(M.getViewport()).off('mousemove', mousemoveFn);
    }
    listenFn();
  });

  /* TODO ********
  onPopupClose = function (evt) {
      selectControl.unselect(NK.selectedCoverageMap);
      delete NK.selectedCoverageMap;
  };

  generatePopupMarkup = function (feature) {
    var a  = feature.attributes;
      var markup = '<article>';
      if (a.n && a.n !== 'NULL') {
        markup += '<h1 class="h">' + a.n + '</h1>';
      }
      if (a.nr) {
        markup += '<p>' + OpenLayers.Lang.translate('Map number') + ': ' + a.nr + '</p>';
      }
      if (a.k) {
        markup += '<div class="municipalities">' + OpenLayers.Lang.translate('Municipalities') + ': <span>' + a.k.split(',').join(',</span><span>') + '</span></div>';
      }
      if (a.u) {
        markup += '<p>' + OpenLayers.Lang.translate('Updated') + ': ' + a.u + '</p>';
      }
      if (a.e) {
        markup += '<p>' + OpenLayers.Lang.translate('EAN-number') + ': ' + a.e + '</p>';
      }
      markup += '</article>';
      return markup;
  };

  onFeatureUnselect = function (feature) {
      if (feature === NK.selectedCoverageMap) {
          NK.selectedCoverageMap = null;
      }
      if (feature.popup) {
        M.removePopup(feature.popup);
        feature.popup.destroy();
        feature.popup = null;
      }
  };

  onFeatureSelect = function (feature) {
      if (NK.easyXDM && NK.easyXDM.socket) {
        // there is an active easyXDM socket - send feature data
        var message = {
          type: 'featureSelected', 
          feature: feature.attributes,
          layer: feature.layer.shortid
        };
        NK.easyXDM.socket.postMessage(JSON.stringify(message));
      } else {
        NK = NK || {};
        if (NK.selectedCoverageMap ) {
            selectControl.unselect(NK.selectedCoverageMap);
        }
        NK.selectedCoverageMap = feature;
        var mousePosition = map.getLonLatFromPixel((map.getControlsByClass('OpenLayers.Control.MousePosition')[0]).lastXy);
        M.setCenter(mousePosition);
        var popup = new OpenLayers.Popup.FramedSideAnchored("nk-selected-coverage-map", 
                                 mousePosition,
                                 null,
                                 generatePopupMarkup(feature),
                                 null, true, onPopupClose);
        popup.autoSize = true;
        feature.popup = popup;
        M.addPopup(popup);
    }
  };

  NK.functions.vector.addVectorHoverControls(M, layer);

  selectControl = new OpenLayers.Control.SelectFeature(layer, {
      select: onFeatureSelect,
      unselect: onFeatureUnselect,
      click: true,
      autoActivate: true
  });

  M.addControl(selectControl);

% if not 'n50LangNB' in vars:  
OpenLayers.Util.extend(OpenLayers.Lang.nb, {
  'Map number': 'Kartblad',
  'Latest print': 'Siste trykk',
  'Datum': 'Datum',
  'Municipalities': 'Kommuner',
  'EAN-number': 'EAN-nummer',
  'Projection': 'Projeksjon',
  'Scale': 'M&aring;lestokk',
  'Updated': 'Sist oppdatert',
  'Special in map': 'Spesiale i kartblad',
  'Vignette in map': 'Vignett i kartblad'
});
<% vars['n50LangNB']=True %>
% endif

********** TODO */ 

}(map, mapProj, proj));
