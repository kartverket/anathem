<%inherit file="/3/controls/controlcontext.mako" />

//TODO
NK.controls = NK.controls || {};
NK.controls.ZoomToSelection = function(options) {
  var wrapper, btn; 

  options = options || {};
  
  this.dragzoom = new ol.interaction.DragZoom({
    condition: ol.events.condition.always
  });

  btn = document.createElement('btn');

  btn.title = "Zoom to selection";
  btn.style.cursor = "pointer";
  btn.innerHTML = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="32" height="26" viewBox="0 0 32 26" preserveAspectRatio="xMidYMid meet" class="icon zoom-to-selection"><g class="selection-dots"><circle cx="2" cy="2"  r="1.5" /><circle cx="2" cy="8"  r="1.5" /><circle cx="2" cy="14" r="1.5" /><circle cx="2" cy="20" r="1.5" /><circle cx="8"  cy="2"  r="1.5" /><circle cx="8"  cy="20" r="1.5" /><circle cx="14" cy="2"  r="1.5" /><circle cx="14" cy="20" r="1.5" /><circle cx="20" cy="2"  r="1.5" /><circle cx="20" cy="20" r="1.5" /><circle cx="26" cy="2"  r="1.5" /><circle cx="26" cy="8"  r="1.5" /><circle cx="26" cy="14" r="1.5" /><circle cx="26" cy="20" r="1.5" /></g><path class="crosshair" d="M25,19v-4h3v4h4v3h-4v4h-3v-4h-4v-3z" /></svg>';
  btn.className = "zoom-to-selection-button";

  $(btn).click(this, this.toggle);

  ol.control.Control.call(this, {
    element: btn,
    target: options.target
  });

}
ol.inherits(NK.controls.ZoomToSelection, ol.control.Control);

NK.controls.ZoomToSelection.prototype.enable = function() {
  map.addInteraction(this.dragzoom);

};
NK.controls.ZoomToSelection.prototype.disable = function() {
  map.removeInteraction(this.dragzoom);
};
NK.controls.ZoomToSelection.prototype.toggle = function(event) {
  var self = event.data;
  if (map.getInteractions().getArray().indexOf(self.dragzoom)>-1) {
    self.disable();
  } else {
    self.enable();
  }
};


NK.functions.addControlToContext(new NK.controls.ZoomToSelection({target: container}), context);
