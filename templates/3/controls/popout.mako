NK.controls = NK.controls || {};
NK.controls.Popout = function(options) {
  var wrapper, img, link;

  options = options || {};
  
  img = document.createElement('div');
  img.innerHTML = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="20px" height="20px" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20" class="icon fullscreen"><path d="M14.949,3.661l1.429,1.428l1.539-1.54l1.612,1.612V0.485h-4.676l1.636,1.636L14.949,3.661z M17.894,16.6l-1.54-1.539l-1.428,1.428l1.539,1.54l-1.611,1.612h4.676v-4.676L17.894,16.6z M4.895,16.465l-1.428-1.428l-1.54,1.539l-1.612-1.611v4.676h4.675l-1.636-1.637L4.895,16.465z M3.491,5.064l1.428-1.428l-1.54-1.539l1.612-1.612H0.315v4.675l1.636-1.635L3.491,5.064zM15.769,12.033V8.199c0-1.587-1.288-2.875-2.875-2.875H6.907c-1.588,0-2.875,1.287-2.875,2.875v3.834c0,1.588,1.287,2.875,2.875,2.875h5.987C14.48,14.908,15.769,13.621,15.769,12.033z" /></svg>';
  img.className = "panel toolbar";
  $.extend(img.style, {
    position:"fixed",
    padding:"5px",
    right:"0",
    bottom:"0"
  });

  wrapper = document.createElement('div');

  link = document.createElement('a');
  link.target = "_blank";
  link.href   = "#";
  link.appendChild(img);

  wrapper.appendChild(link);
  wrapper.className += " popoutDiv";

  this.link_ = link;

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.Popout, ol.control.Control);

NK.controls.Popout.prototype.updateLink = function() {
  var testHash = window.location.href.split("#")[0].split('/');
  if (testHash.length > 4) {
    this.link_.href = "http://www.norgeskart.no/" + testHash[3] + "/#" + window.location.href.split("#")[1];
  } else {
    this.link_.href = "http://www.norgeskart.no/#" + window.location.href.split("#")[1];
  }
}

var popout = new NK.controls.Popout();
map.addControl(popout);

function poll() {
  popout.updateLink();
  setTimeout(poll, 100);
}
setTimeout(poll, 10);
  
