"use strict";

var NK = NK || {};
NK.mapEventListeners = {};

var gkopen, 
    gkopen_wmts,
    proj,
    mapProj,
    mapBounds,
    xdmsocket,
    initLayers,
    postEvent,
    map;

gkopen = "http://opencache.statkart.no/gatekeeper/gk/gk.open";
gkopen_wmts = "http://opencache.statkart.no/gatekeeper/gk/gk.open_wmts";

NK.gkToken = "unInitialized";

% if tokenServiceUrl:
NK.tokenService = "${tokenServiceUrl}";
% endif

NK.baseProjection = "25833";
% if projection:
NK.baseProjection = "${projection}";
% endif

NK.tokenLastUpdated = new Date(0);
NK.tokenUpdatePaused = false;

% if i18n:
  ${i18n}
% endif

NK.tokenError = {
  PAUSE_MINUTES: 2,
  RELOAD_LIMIT_SECONDS: 15,
  messagePopup: null,
  pauseTimeRemainingElement: null,
  pauseTimeRemainingText: null,
  pauseTimer: null,
  pauseCountdownTimer: null
};

NK.mapservers = {};
NK.mapservers.wmts = [
  "http://cache1.kartverket.no/grunnkart/wmts",
  "http://cache2.kartverket.no/grunnkart/wmts",
  "http://cache3.kartverket.no/grunnkart/wmts",
  "http://cache4.kartverket.no/grunnkart/wmts"
];
NK.zoomLevels = 18;

NK.functions = NK.functions || {};

NK.functions.resetTokenError = function () {
  if (NK.tokenError.pauseTimeRemainingElement) {
    NK.tokenError.pauseTimeRemainingElement.parentNode.removeChild(NK.tokenError.pauseTimeRemainingElement);
    NK.tokenError.pauseTimeRemainingElement = null;
  }
  if (NK.tokenError.messagePopup) {
    NK.tokenError.messagePopup.parentNode.removeChild(NK.tokenError.messagePopup);
    NK.tokenError.messagePopup = null;
  }
  if (NK.tokenError.pauseTimer) {
    clearTimeout(NK.tokenError.pauseTimer);
    NK.tokenError.pauseTimer = null;
  }
  if (NK.tokenError.pauseCountdownInterval) {
    clearInterval(NK.tokenError.pauseCountdownInterval);
    NK.tokenError.pauseCountdownInterval = null;
  }
};

NK.functions.updateToken = function (request) {
  var i, 
      j, 
      reloadLimit;

  reloadLimit = new Date(Date.now() - NK.tokenError.RELOAD_LIMIT_SECONDS * 1000);

  NK.gkToken = request.responseText.replace(/[\"\r\n]/g, '');

  if (NK.tokenLastUpdated < reloadLimit) { // was token updated less than RELOAD_LIMIT_SECONDS ago?
    if (!NK.tokenUpdatePaused) {
      NK.functions.resetTokenError();
      NK.tokenLastUpdated = new Date();

      for (i = 0, j = map.layers.length; i < j; i += 1) {
        if (map.layers[i].params && map.layers[i].params.gkt) {
          map.layers[i].params.gkt = NK.gkToken;
          map.layers[i].redraw();
        }
      }
    }
  } else {
    NK.functions.pauseTokenUpdate();
  }
};

NK.functions.pauseTokenUpdate = function () {
  var popup, innerWrapper, heading, message, timeRemaining, statusLink;

  if (!NK.tokenUpdatePaused) {
    NK.tokenUpdatePaused = true;

    NK.functions.log(OpenLayers.Lang.translate('Server error') +" - "+ OpenLayers.Lang.translate('An error has occured.'));

    NK.tokenError.pauseTimer = setTimeout(function () {
      NK.tokenUpdatePaused = false;
      NK.functions.getNewToken();
    },  60 * parseInt(NK.tokenError.PAUSE_MINUTES, 10) * 1000);

    NK.tokenError.pauseCountdownInterval = setInterval(function () {
      var content, timeLeft;
      if (NK.tokenError.pauseTimeRemainingElement) {
        content = NK.tokenError.pauseTimeRemainingElement.innerHTML;
        timeLeft = (parseInt(content, 10) - 1);
        NK.tokenError.pauseTimeRemainingElement.innerHTML = timeLeft.toString();
        if (timeLeft === 1) {
          if (NK.tokenError.pauseTimeRemainingText.textContent) {
            NK.tokenError.pauseTimeRemainingText.textContent = ' ' + OpenLayers.Lang.translate('minute.');
          } else {
            // old IE...
            NK.tokenError.pauseTimeRemainingText.innerText = ' ' + OpenLayers.Lang.translate('minute.');
          }
        }
      }
    }, 60 * 1000);
  }
};

NK.functions.getNewToken = function () {
  if (NK.gkToken !== null) {
    NK.gkToken = null;
    OpenLayers.Request.GET({url: NK.tokenService, success: NK.functions.updateToken});
  }
};

% if functions :
  ${functions}
% endif

% if internationalization:
  ${internationalization}
% endif

NK.init = function () {
  var prmstr, prmarr, params, tmparr, 
      i, j;

  if ((!ol) || (!proj4)) {
    setTimeout(NK.init, 100);
    return;
  }

  // TODO: cleanup projection loading
  var extents = {
      'EPSG:25833': [-2500000, 3500000, 3045984, 9045984]
  };
  
  proj4.defs("EPSG:25833","+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs");

  NK.projections = proj = {  
    //pregenerated projection objects
    "25833": new ol.proj.Projection({ code:"EPSG:25833", extent:extents["EPSG:25833"] })
  };

  mapProj = proj[NK.baseProjection];
  ol.proj.addProjection(mapProj);
  ol.proj.addCoordinateTransforms('EPSG:4326', 'EPSG:25833', proj4('EPSG:4326', 'EPSG:25833').forward);
  ol.proj.addCoordinateTransforms('EPSG:3857', 'EPSG:25833', proj4('EPSG:3857', 'EPSG:25833').forward);

% if language:
  // TODO
% endif

  // extract URL parameters into dictionary
  prmstr = window.location.search.substr(1);
  prmarr = prmstr.split ("&");
  params = {};

  for (i = 0, j = prmarr.length; i < j; i += 1) {
    tmparr = prmarr[i].split("=");
    params[tmparr[0]] = tmparr[1];
  }

  // Create map canvas

  if (!!params.proj) {
    mapProj = proj[params.proj]; 
  }

 
% if center:
  // Default placement and zoom of the map
  ${center}
% endif

  NK.view = new ol.View({
    projection: mapProj,
    extent:     mapProj.getExtent(),
    center:     NK.defaultCenter,
    zoom:       NK.defaultZoom
  });

  NK.mapOptions = {
    target: 'map',
    view  : NK.view,
    interactions: [], 
    controls: []     
  };
  map = new ol.Map(NK.mapOptions);

% if baselayers:
  // Base layers
  ${baselayers}
% endif

%if overlays:
  // Overlays
  ${overlays}
% endif

% if controls:
  ${controls}
% endif

};
// end init()


var addEvent = function(event, handler) {
  var listen = window.addEventListener || window.attachEvent;
  if (window.addEventListener) {
    listen(event, handler, false);
  } else {
    listen("on" + event, handler);
  }
};

var cb = function(response, status, request) {
  NK.gkToken = request.responseText.replace(/[\"\r\n]/g, '');
  NK.init();
};

var initializeToken = function () {
  $.ajax({
    url: NK.tokenService, 
    success: cb,
    type: 'GET'
  });
};
addEvent('load', initializeToken);
