<%inherit file="/3/controls/controlcontext.mako" />

//TODO
NK.controls = NK.controls || {};
NK.controls.PanPanel = function(options) {
  var wrapper,nord, ost, vest, sor;

  options = options || {};
  
  wrapper = document.createElement('div');

  nord = document.createElement('button');
  nord.title = "nordover";
  $(nord).addClass("olControlPanNorthItemInactive olButton");
  options.target.appendChild(nord);

  sor = document.createElement('button');
  sor.title = "s&oslash;rover";
  $(sor).addClass("olControlPanSouthItemInactive olButton");
  options.target.appendChild(sor);

  ost = document.createElement('button');
  ost.title = "&oslash;stover";
  $(ost).addClass("olControlPanEastItemInactive olButton");
  options.target.appendChild(ost);

  vest = document.createElement('button');
  vest.title = "vestover";
  $(vest).addClass("olControlPanWestItemInactive olButton");
  options.target.appendChild(vest);

  nord.addEventListener("click", this.pan(0,1), false);
  sor.addEventListener("click", this.pan(0,-1), false);
  vest.addEventListener("click", this.pan(-1,0), false);
  ost.addEventListener("click", this.pan(1,0), false);

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.PanPanel, ol.control.Control);

NK.controls.PanPanel.prototype.pan = function(x,y) {
  return function(evt) {
    var view = map.getView();
    var center = view.getCenter();
    var res  = view.getResolution();
    var PAN_DISTANCE = 100;
 
    var pan = ol.animation.pan({
      duration: 250,
      source: center
    });
    map.beforeRender(pan);
    view.setCenter([center[0] + x * res * PAN_DISTANCE, center[1] + y * res * PAN_DISTANCE]);
  };
}


NK.functions.addControlToContext(new NK.controls.PanPanel({target: container}), context);
