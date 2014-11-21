<%inherit file="/3/controls/controlcontext.mako" />

//TODO
NK.controls = NK.controls || {};
NK.controls.ZoomPanel = function(options) {
  var wrapper, sliderWrapper, buttonWrapper;
  var zoomIn, zoomOut;

  options = options || {};
  
  wrapper = document.createElement('div');
  wrapper.className = "zoombar-and-buttons-wrapper";
  wrapper.style.height = "70px";

  sliderWrapper = document.createElement('div');
  sliderWrapper.classname = "sliderWrapper";

  buttonWrapper = document.createElement('div');
  buttonWrapper.classname = "wrapper";
  
  zoomIn = document.createElement('button');
  zoomIn.className = "olControlZoomIn olButton";
  zoomIn.title = "Zoom inn";
  zoomIn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="64px" height="64px" version="1.1" preserveAspectRatio="xMidYMid meet" viewBox="0 0 64 64" class="plus icon"><path fill-rule="evenodd" d="m 14,27.5 13.5,0 0,-13.5 9,0 0,13.5 13.5,0 0,9 -13.5,0 0,13.5 -9,0 0,-13.5 -13.5,0 z M 63,32 C 63,49.120827 49.120827,63 32,63 14.879173,63 1,49.120827 1,32 1,14.879173 14.879173,1 32,1 49.120827,1 63,14.879173 63,32z"></path></svg>';

  zoomOut = document.createElement('button');
  zoomOut.className = "olControlZoomOut olButton";
  zoomOut.title = "Zoom ut";
  zoomOut.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="64px" height="64px" version="1.1" preserveAspectRatio="xMidYMid meet" viewBox="0 0 64 64" class="minus icon"><path fill-rule="evenodd" d="m 14,27.5 36,0 0,9 -36,0 zM 63,32 C 63,49.120827 49.120827,63 32,63 14.879173,63 1,49.120827 1,32 1,14.879173 14.879173,1 32,1 49.120827,1 63,14.879173 63,32z"></path></svg>';

  zoomIn.addEventListener("click", this.zoom(1), false);
  zoomOut.addEventListener("click", this.zoom(-1), false);

  buttonWrapper.appendChild(zoomIn);
  buttonWrapper.appendChild(zoomOut);

  wrapper.appendChild(buttonWrapper);

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.ZoomPanel, ol.control.Control);

NK.controls.ZoomPanel.prototype.zoom = function(dir) {
  return function() {
    var view = map.getView();
    var zoom = ol.animation.zoom({
      duration: 250,
      resolution: view.getResolution()
    });
    map.beforeRender(zoom);
    view.setZoom(view.getZoom()+dir);
  }
}


NK.functions.addControlToContext(new NK.controls.ZoomPanel({target: container}), context);
