% if not 'vectorControls' in vars:  

NK.functions = NK.functions || {};
NK.functions.vector = NK.functions.vector || {};
NK.functions.popup = NK.functions.popup || {};

var skipKeys = ["boundedBy", "geometry", "msGeometry"];
NK.functions.popup.ify = function(object) {
  var str="<table>"
  for (var k in object) {
    if (skipKeys.indexOf(k)>-1) { continue; }
    str += "<tr><td>"+k+":</td><td>"+object[k]+"</td></tr>";
  }
  str += "</tr></table>";
  return str;
}

NK.functions.vector.addHoverControls = function (map, layer, style, featureIdentity) {
  if (!featureIdentity) {featureIdentity = Object.is;}

  var featureOverlay = new ol.FeatureOverlay({
    map: map,
    style: style
  });

  var highlight=[];
  var mouseHint = document.createElement("div");
  mouseHint.className = "ol-mouse-hint";
  map.getOverlayContainer().appendChild(mouseHint);
  mouseHint.style.visibility = false;

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
        mouseHint.style.visibility = false;
      }
      if (!!feature) {
        highlight = $.grep(layer.getSource().getFeatures(), function(f) {
          return featureIdentity(feature, f);
        });
        for (var h in highlight) {
          featureOverlay.addFeature(highlight[h]);
        }
        mouseHint.style.visibility = true;
      }
    }
    if (!!feature) {
      mouseHint.innerHTML = NK.functions.popup.ify(feature.values_);
      $.extend(mouseHint.style, {
        left: pixel[0]+10+"px",
        top: pixel[1]+15+"px",
      });
    };
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
  if (layer.getVisible()) {
    $(map.getViewport()).on('mousemove', mousemoveFn);
  } 

};


<% vars['vectorControls']=True %>
% endif