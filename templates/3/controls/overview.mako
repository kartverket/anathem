var simpleLayer = NK.util.getLayersBy('title','enkel')[0];

var omap = new ol.control.OverviewMap({
  className: 'ol-overviewmap ol-custom-overviewmap',
  layers: [simpleLayer],
  collapsed: false
})

omap.setCollapsible(false);

map.addControl(omap);
