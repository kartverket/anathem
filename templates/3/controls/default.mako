var interactions=ol.interaction.defaults().array_;
var controls    =ol.control.defaults().array_;
for (var i in interactions) {
  map.addInteraction(interactions[i]);
}
map.addControl(new ol.control.ScaleLine({units:ol.control.ScaleLineUnits.METRIC}));
