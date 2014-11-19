% if not 'styles.dekning.sjo' in vars:  
NK.styles = NK.styles || {};
NK.styles.dekning = NK.styles.dekning || {};

var greenStyle = function(text) {
  return [new ol.style.Style({
    stroke: new ol.style.Stroke({
      color: "#484",
      width: 2,
    }),
    /* opacity is broken */
    //fill: new ol.style.Fill({
    //  color: "#884",
    //  opacity: 0.1
    //})
    text: new ol.style.Text({
      font: '14px calibri, sans-serif',
      text: text,
      fill: new ol.style.Fill({
        color: "#484"
      }),
      stroke: new ol.style.Stroke({
        color: "#fff",
        width: 4
      })
    }) 
  })]
};
var unlabeled = greenStyle("");

var greenHighlight = [new ol.style.Style({
  stroke: new ol.style.Stroke({
    color: "#ada",
    width: 2,
  })
})]; 

NK.styles.dekning.sjo = {
  default: function(feature, resolution) { 
    if (resolution > 2000) {
      return unlabeled;
    } else {
      return greenStyle(feature.getId()); 
    }
  },
  highlight: function(feature, resolution) { return greenHighlight; },
};

<% vars['styles.dekning.sjo']=True %>
% endif
