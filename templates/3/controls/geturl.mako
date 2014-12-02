<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};
NK.controls.GetURL = function(options) {
  options = options || {};
  var wrapper, btn;
  var cName = 'getURL-button nkButton';
  
  wrapper = document.createElement('div');
  btn    = document.createElement('button');
  wrapper.appendChild(btn);

  $(btn).click(this, this.toggle);
  
  map.getView().on("change:center", this.changeHash);
  map.getView().on("change:resolution", this.changeHash);
  
  btn.title = this.title;
  btn.className = btn.className === "" ? cName : btn.className + " " + cName;
  btn.innerHTML = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="24px" height="24px" viewBox="0 0 24 24" preserveAspectRatio="xMidYMid meet" class="icon share"><path d="M14.843,15.493c-0.497,0-0.967,0.118-1.385,0.329l-2.421-2.495c0.178-0.407,0.277-0.858,0.277-1.335c0-0.476-0.1-0.927-0.277-1.334l2.411-2.485c0.42,0.214,0.894,0.334,1.395,0.334C16.587,8.507,18,7.051,18,5.253C18,3.457,16.587,2,14.843,2s-3.157,1.457-3.157,3.253c0,0.436,0.083,0.851,0.233,1.23L9.453,9.025C9.058,8.842,8.619,8.739,8.157,8.739C6.414,8.739,5,10.196,5,11.992c0,1.797,1.414,3.254,3.157,3.254c0.462,0,0.9-0.104,1.296-0.286l2.471,2.546c-0.153,0.383-0.238,0.802-0.238,1.241c0,1.797,1.413,3.254,3.157,3.254S18,20.544,18,18.747S16.587,15.493,14.843,15.493z" /></svg>';
 
  this.cnt = document.createElement("div");
  this.cnt.className="cnt";
  this.widget = NK.util.createWidget(this.cnt, 1);

  wrapper.appendChild( this.widget );
  this.div = options.target;

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.GetURL, ol.control.Control);

NK.controls.GetURL.prototype.changeHash = function() {        
    	var btn = this.div;
    	if (! $(btn).hasClass('active') ) return;
    	setTimeout( function() { $(btn).addClass('active'); }, 500 );
};

NK.controls.GetURL.prototype.toggle = function (event) {
        var self = event.data;
        $(self.div).hasClass('active') ? self.hide() : self.show();
};

NK.controls.GetURL.prototype.show = function () {
    	this.cnt.innerHTML = this.getContent();
        $(this.div).addClass('active');
};
NK.controls.GetURL.prototype.hide = function () {
        $(this.div).removeClass('active');
};

NK.controls.GetURL.prototype.getContent = function (center) {   
        var url     = window.location.href;
        url = url.replace("[","%5B").replace("]","%5D");
        var safeURL = encodeURIComponent(window.location.href);
        safeURL = safeURL.replace("%5B","%255B").replace("%5D","%255D");

        var html = '<h1 class="h">Share map</h1>';
        html += '<div class="page-url">' + url + '</div>';
        html += '<span>Share by:</span>';
        html += '<a class="share-link email" title="e-mail" href="mailto:?subject=norgeskart.no&body=' + safeURL + '"><span>e-mail</span><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" width="71.878px" height="54.479px" viewBox="0 0 71.878 54.479" preserveAspectRatio="xMidYMid meet"  class="icon email"><path d="M69.28,17.595c-1.732-3.751-4.121-6.928-7.164-9.526c-3.044-2.597-6.64-4.592-10.786-5.983C47.185,0.695,42.696,0,37.867,0c-5.091,0-9.919,0.879-14.485,2.637c-4.567,1.76-8.582,4.266-12.046,7.518c-3.464,3.255-6.22,7.192-8.266,11.81C1.023,26.584,0,31.753,0,37.474c0,5.617,0.891,10.563,2.676,14.841c0.298,0.715,0.96,2.078,0.96,2.078h10.545c-1.454-1.827-2.635-3.89-3.514-6.211c-1.234-3.254-1.85-6.928-1.85-11.021c0-4.146,0.734-7.992,2.204-11.535c1.469-3.543,3.504-6.598,6.102-9.171c2.597-2.571,5.654-4.592,9.172-6.062c3.515-1.469,7.321-2.204,11.415-2.204c3.569,0,6.901,0.421,9.999,1.259c3.096,0.84,5.787,2.165,8.07,3.976c2.282,1.81,4.079,4.107,5.392,6.888c1.312,2.782,1.969,6.141,1.969,10.078c0,2.729-0.328,5.091-0.983,7.085c-0.658,1.996-1.51,3.648-2.559,4.961c-1.052,1.312-2.232,2.283-3.543,2.913c-1.313,0.629-2.651,0.945-4.016,0.945c-1.365,0-2.244-0.553-2.638-1.654c-0.394-1.103-0.381-2.885,0.041-5.354l3.778-21.335h-5.512l-2.44,2.52c-1.051-0.892-2.204-1.614-3.464-2.165c-1.261-0.552-2.81-0.826-4.646-0.826c-2.676,0-5.209,0.721-7.597,2.164c-2.389,1.444-4.488,3.344-6.299,5.707c-1.81,2.363-3.241,5.079-4.29,8.148c-1.05,3.071-1.575,6.233-1.575,9.488c0,1.731,0.249,3.307,0.748,4.723c0.498,1.416,1.168,2.625,2.008,3.621c0.839,0.998,1.836,1.771,2.991,2.323c1.155,0.551,2.362,0.826,3.621,0.826c1.575,0,3.019-0.235,4.33-0.708c1.312-0.473,2.52-1.115,3.623-1.93c1.101-0.812,2.111-1.744,3.031-2.795c0.917-1.049,1.771-2.126,2.559-3.228h0.314c-0.158,1.628-0.053,2.99,0.315,4.095c0.367,1.102,0.932,1.994,1.691,2.676c0.762,0.683,1.707,1.169,2.835,1.457c1.129,0.289,2.349,0.433,3.66,0.433c3.15,0,6.103-0.63,8.857-1.89c2.756-1.26,5.17-2.965,7.244-5.117c2.071-2.152,3.699-4.696,4.88-7.637c1.181-2.939,1.771-6.087,1.771-9.447C71.878,25.612,71.013,21.349,69.28,17.595 M40.781,38.34c-0.579,1.051-1.234,2.048-1.968,2.99c-0.737,0.946-1.497,1.787-2.284,2.521c-0.788,0.736-1.601,1.326-2.44,1.771c-0.84,0.447-1.628,0.671-2.362,0.671c-1.732,0-2.953-0.553-3.661-1.654c-0.709-1.103-1.063-2.52-1.063-4.251c0-1.681,0.262-3.399,0.787-5.158c0.525-1.757,1.272-3.345,2.243-4.763c0.971-1.417,2.127-2.57,3.465-3.464c1.339-0.892,2.794-1.338,4.369-1.338c1.103,0,2.021,0.157,2.756,0.472c0.734,0.315,1.444,0.762,2.126,1.34L40.781,38.34z" /></svg></a>';
        html += '<a class="share-link twitter" title="Twitter" href="http://twitter.com/share?url=' + safeURL + '"><span>Twitter</span><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="72px" height="72px" viewBox="0 0 72 72" preserveAspectRatio="xMidYMid meet" class="icon twitter"><path d="M36,0C16.118,0,0,16.117,0,36s16.118,36,36,36s36-16.117,36-36S55.882,0,36,0 M32.07,45.868c1.087,1.087,2.404,1.63,3.958,1.63H47.2c1.551,0,2.882,0.557,3.991,1.664c1.106,1.106,1.662,2.435,1.662,3.984c0,1.549-0.556,2.879-1.662,3.985c-1.109,1.106-2.437,1.66-3.989,1.66h-11.17c-4.652,0-8.63-1.649-11.932-4.952c-3.303-3.303-4.952-7.28-4.952-11.934V19.369c0-1.596,0.549-2.935,1.649-4.022c1.099-1.084,2.444-1.629,4.029-1.629c1.54,0,2.863,0.554,3.962,1.663c1.101,1.105,1.652,2.433,1.652,3.984v5.647h16.742c1.558,0,2.891,0.552,4.004,1.662c1.111,1.105,1.667,2.433,1.667,3.983c0,1.549-0.556,2.879-1.662,3.986c-1.109,1.105-2.44,1.662-3.991,1.662H30.44v5.597C30.44,43.458,30.982,44.777,32.07,45.868"/></svg></a>';
//        html += '<iframe src="//www.facebook.com/plugins/like.php?href=' + encodeURIComponent(window.location.href) + '&amp;send=false&amp;layout=button_count&amp;width=45&amp;show_faces=false&amp;font=arial&amp;colorscheme=light&amp;action=like&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:45px; height:21px;" allowTransparency="true"></iframe>';
        html += '<a class="share-link facebook" title="Facebook" href="http://www.facebook.com/sharer.php?u=' + safeURL + '"><span>Facebook</span><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="140px" height="140px" viewBox="0 0 140 140" preserveAspectRatio="xMidYMid meet" class="icon facebook"><path d="M70.148,0C31.407,0,0,31.407,0,70.149c0,36.744,28.258,66.87,64.225,69.881V86.93h-17.79V64.832h17.79V53.714c0-15.94,11.97-28.909,26.684-28.909h17.79v22.029h-17.79c-2.099,0-4.448,2.854-4.448,6.671v11.327h22.238V86.93H86.461v51.441c30.872-7.356,53.837-35.099,53.837-68.222C140.298,31.407,108.891,0,70.148,0"/></svg>' + '</a>';
	
	   return '<div class="getURLcontent">'+html+'</div>';
}; 

NK.functions.addControlToContext(new NK.controls.GetURL({target: container}), context);

