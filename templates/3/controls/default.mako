var interactions=ol.interaction.defaults().array_;
var controls    =ol.control.defaults().array_;
for (var i in interactions) {
  map.addInteraction(interactions[i]);
}
for (var c in controls) {
  if (!(controls[c] instanceof ol.control.Attribution)) {
    map.addControl(controls[c]);
  }
}
map.addControl(new ol.control.ScaleLine({units:ol.control.ScaleLineUnits.METRIC}));
