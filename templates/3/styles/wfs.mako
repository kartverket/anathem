% if not 'styles.wfs' in vars:  
NK.styles = NK.styles || {};

var blueStyle = function(text) {
  return [new ol.style.Style({
    stroke: new ol.style.Stroke({
      color: [68,68,170,1],
      width: 2
    }),
    text: new ol.style.Text({
      font: '14px calibri, sans-serif',
      text: text,
      fill: new ol.style.Fill({
        color: [68,68,170,1],
      }),
      stroke: new ol.style.Stroke({
        color: "#fff",
        width: 4
      })
    }) 
  })]
};
var unlabeled = blueStyle("");

var blueHighlight = [new ol.style.Style({
  stroke: new ol.style.Stroke({
    color: "#aae",
    width: 2
  }),
  fill: new ol.style.Fill({
    color: [68,68,170,0.1],
  }),
})]; 
var pointStyle = [new ol.style.Circle({
  radius: 10,
  stroke: new ol.style.Stroke({
    color: "#aae",
    width: 2
  })
})]; 

NK.styles.wfs = {
  "default": function(feature, resolution) { 
    if (feature.getGeometry().getType() == ol.geom.GeometryType.Point) {
      return pointStyle;
    } 
    if (resolution > 2000) {
      return unlabeled;
    } else {
      return blueStyle(feature.getId()); 
    }
  },
  "highlight": function(feature, resolution) { 
    return blueHighlight; 
  }
};

<% vars['styles.wfs']=True %>
% endif
