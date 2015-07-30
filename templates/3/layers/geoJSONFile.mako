<%include file="/3/functions/vector.mako" />

(function () {
  var options = {};

  NK.addLayerType.geoJSONFile = (function (M, MP, P) {
    return function (id, name, url, options) {
    var layer,
    layerOptions,
    formatOptions;

    layerOptions = {
        title: "${name}",
        shortid: "${id}",
        layerGroup: "${layerGroup}",
        source: new ol.source.GeoJSON({
            projection: MP,
            url: "${url}"
        }),
        style: function(feature, resolution) {
            var color = feature.get('color');
            if (!!color) {
                var rgb = color.split(" ");
                var width = feature.get('size') || 2;
                var symbol = feature.get('symbol') || 'circle';
                var stroke = new ol.style.Stroke({
                    color: [rgb[0],rgb[1],rgb[2],1],
                    width: 2
                });
                var fill = new ol.style.Fill({
                    color: [rgb[0],rgb[1],rgb[2],0.8]
                });
                var pointStyle;

                if (symbol == 'square') {
                    pointStyle = new ol.style.RegularShape({
                        points: 4,
                        angle: Math.PI/4,
                        fill: fill,
                        stroke: stroke,
                        radius: width
                    });
                } else {
                    pointStyle = new ol.style.Circle({
                        fill: fill,
                        stroke: stroke,
                        radius: width
                    });
                }
                return [new ol.style.Style({
                    fill: fill,
                    stroke: stroke,
                    image: pointStyle
                })];
            } else {
                return NK.styles.wfs['default'](feature, resolution);
            }
        },
        type: 'geojson',
        displayInLayerSwitcher: (options && options.hideFromLayerSwitcher) ? 0 : 1,
        visibility: (options && options.visible) ? 1 : 0
    };

    layer = new ol.layer.Vector(
        layerOptions
    );

    if (options) {
        if (options.styleName && NK.styles && NK.styles[options.styleName]) {
            //layerOptions.style = NK.styles[options.styleName];
        }
        if (options && options.layerGroup) {
            goog.object.extend(layer, {'layerGroup': options.layerGroup});
        }

        if (options && options.visible) {
            NK.defaultVisibleLayers = NK.defaultVisibleLayers || [];
            NK.defaultVisibleLayers.push(id);
        }

        if (options && options.popupConfig) {
           //NK.functions.popup.addConfiguredPopup(M, layer, options.popupConfig);
        }
    }
    //NK.functions.vector.addHoverControls(map, layer, NK.styles.unlabeledMarker.select);
    M.addLayer(layer);
    //NK.functions.vector.addHoverControls(map, layer, NK.styles.wfs.highlight);
};
}(map, mapProj, proj));

% if layerGroup:
  options.layerGroup = '${layerGroup}';
% endif
% if visible:
  options.visible = "${visible}";
% endif
% if hidefromlayerswitcher:
  options.hideFromLayerSwitcher = "${hidefromlayerswitcher}";
% endif
% if cluster:
  options.cluster = true;
% endif
% if styleName:
  options.styleName = '${styleName}';
% endif
% if label:
  options.label = '${label}';
% endif
% if styleNameSLD:
  options.styleNameSLD = '${styleNameSLD}';
% endif
% if epsgCode:
  options.epsgCode = '${epsgCode}';
% endif
% if popup:
  options.popupConfig = ${popup}
% endif
NK.addLayerType.geoJSONFile('${id}', '${name}', '${url}', options);
}());