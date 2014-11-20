var interactions=ol.interaction.defaults().array_;
var controls    =ol.control.defaults().array_;
for (var i in interactions) {
  map.addInteraction(interactions[i]);
}
for (var c in controls) {
  map.addControl(controls[c]);
}
