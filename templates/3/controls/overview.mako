var simpleLayer = NK.util.getLayersBy('title','enkel')[0];

var omap = new ol.control.OverviewMap({
  className: 'overview-container-panel',
//  layers: [simpleLayer] // this is broken
})

omap.setCollapsible(false);

map.addControl(omap);
