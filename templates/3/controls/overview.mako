var simpleLayer = NK.util.getLayersBy('title','enkel')[0];

var omap = new ol.control.OverviewMap({
  projection: NK.projections['32633'],
  className: 'overview-container-panel'
})

map.addControl(omap);

ol.interaction.defaults().forEach(function(i){ 
  omap.ovmap_.addInteraction(i);
});
