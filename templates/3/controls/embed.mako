## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};

NK.controls.Embed = function(options) {
  options = options || {};
  var wrapper, btn;
  var cName = 'embed-button nkButton';
  
  this.title = 'Embed';

  this.navButtons = {};
  this.navButtons.next = null;
  this.navButtons.back = null;

  this.widgetStates = {};
  this.stepSpecificElements = {};
  this.data = {};

  this.attr = {'type':'embedLight','names':['base','square','left','top','right','bottom']};

  wrapper = document.createElement('div');
  btn    = document.createElement('button');
  wrapper.appendChild(btn);

  $(btn).click(this, this.toggle);
  
  btn.title = this.title;
  btn.className = btn.className === "" ? cName : btn.className + " " + cName;
  btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="72.151px" height="38.936px" preserveAspectRatio="xMidYMid meet" viewBox="0 0 72.151 38.936" class="icon embed"><path d="m 51.541,0 -6.91,5.549 14.83,13.918 -14.635,13.919 6.91,5.55 20.415,-19.469 z M 20.415,0 0,19.469 20.61,38.936 27.52,33.387 12.69,19.469 27.325,5.55 z" /></svg>';

  this.cnt = document.createElement("div");
  this.cnt.className="cnt";

  this.widget = NK.util.createWidget(this.cnt, 1);

  this.insertContent(this.cnt);

  options.target.appendChild( this.widget );
  this.div = options.target;

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });

}
ol.inherits(NK.controls.Embed, ol.control.Control);

NK.controls.Embed.prototype.insertDragArea = function( e ) {

    	var self = this, 
            attr = self.attr, 
            wrapper = document.body,
            i,
            name;

    	attr['nodes'] = {};
    	for (i = 0; i < attr['names'].length; i += 1) {
    	    name = attr['names'][i];
    	    attr['nodes'][name] = document.createElement('div');
    	    attr['nodes'][name].setAttribute( 'class', attr['type'] );
    	    attr['nodes'][name].setAttribute( 'id', attr['type']+'OF'+name );
    	   
    	    if (name === 'top' || name === 'bottom') {
        		attr['nodes'][name].innerHTML = 
        		    '<div class="tool left ' + name + '"></div>' +
    	       	    '<div class="tool right ' + name + '"></div>';		    
    	    } else if (name === 'square') {
        		attr['nodes'][name].innerHTML = '<div class="tool"></div>';
    	    }

    	    wrapper.appendChild(attr['nodes'][name]);
    	    
    	    $(attr['nodes'][name]).mousemove(self, self.moveDragArea);
    	    $(attr['nodes'][name]).mousedown(self, self.downDragArea);
    	    $(attr['nodes'][name]).mouseup  (self, self.upDragArea);
    	    $(attr['nodes'][name]).bind('touchstart', self, self.downDragArea);
    	    $(attr['nodes'][name]).bind('touchend',   self, self.upDragArea);
    	    $(attr['nodes'][name]).bind('touchmove',  self, self.moveDragArea);
    	}
};

NK.controls.Embed.prototype.getIframe = function ( onPreview, panel ) {
        var iframe = document.createElement('iframe'),
            shortDesc = this.data.shortDesc || '',
            longDesc = this.data.longDesc || '';

        iframe.setAttribute('src', this.getURL());
        iframe.setAttribute('width', this.data.width);
        iframe.setAttribute('height', this.data.height);
        iframe.setAttribute('title', shortDesc);
        iframe.setAttribute('longdesc', longDesc);
        return iframe;
};

NK.controls.Embed.prototype.getURL =  function () {
        var hash,
            url,
            i, j, m, x, y, hashLayers,
            markers = this.data.markers;

        // Include selected map layer
        hashLayers = window.location.hash.toString().split('/');
        hashLayers.splice(0,3);
        hashLayers = hashLayers.join('/');
        if (!!hashLayers)
            hashLayers += '/';

        x = this.data.centerX.toString().split('.')[0];
        y = this.data.centerY.toString().split('.')[0];

        var zoom = map.getView().getZoom();
        //hash = window.location.hash.replace(/#([0-9]+\/){3}/, '#' + zoom + '/' + this.data.centerX + '/' + this.data.centerY + '/').replace('/+embed.box', '');
        hash = '#' + zoom + '/' + x + '/' + y + '/' + hashLayers + '+embed.box';

        if (markers && markers.length) {
            for (i = 0, j = markers.length; i < j; i += 1) {
                m = markers[i];
                hash += '/m/' + m.x + '/' + m.y + '/' + encodeURIComponent(m.label);
            }
        }

        var extraPath;
        switch (this.data.type) {
            case 'STATIC':
                extraPath = 'statisk.html';
                break;
            case 'DYNAMIC':
                if (this.data.includeTools) {
                    extraPath = 'dynamisk-med-navigasjon.html';
                } else {
                    extraPath = 'dynamisk.html';
                }
                break;
            default:
                extraPath = '';
        }

        url = window.location.protocol + '//' + window.location.host + window.location.pathname + extraPath + hash;

        return url;
};

NK.controls.Embed.prototype.moveDragArea = function (e) {
        e.preventDefault();
	    var self = e.data, 
            attr = self.attr,
            nodes = attr['nodes'] || {},
            dTarget,
            isTop,
            isLeft,
            allow,
            x,
            y,
            s,
            pos = {},
            downPos = {},
            i;

	    if (!nodes['base'] || !attr['downEvent']) {
            return;
        }

        if (e.type === 'touchmove') {
            for (i = 0; i < e.changedTouches.length; i += 1) {
                if (e.changedTouches[i] === attr['downEvent'].touch) {
                    pos.x = e.changedTouches[i].clientX;
                    pos.y = e.changedTouches[i].clientY;
                    e.preventDefault();
                    e.stopPropagation();
                }
            }

            if ( ! pos.x ) pos.x = e.targetTouches[0].pageX;
            if ( ! pos.y ) pos.y = e.targetTouches[0].pageY;

        } else if (e.type === 'mousemove') {
            pos.x = e.clientX;
            pos.y = e.clientY;
        }

	    dTarget = attr['downEvent'].target;
    	if ($(dTarget).hasClass('tool')) {
    	    $(nodes['base']).removeClass('adjust');
    	    isTop  = $(dTarget).hasClass('top');
    	    isLeft = $(dTarget).hasClass('left');

            if (isTop && isLeft) {         // top - left
                attr['points'][0] = [pos.x, pos.y];
            } else if (isTop && !isLeft)  { // top - right
                attr['points'][0][1] = pos.y;
                attr['points'][1][0] = pos.x;
            } else if (isLeft) {             // bottom - left
                attr['points'][0][0] = pos.x;
                attr['points'][1][1] = pos.y;
            } else {                           // bottom - right
                attr['points'][1] = [pos.x, pos.y];
            }
    	    
    	    allow = attr['points'][0][0] < attr['points'][1][0] && attr['points'][0][1] < attr['points'][1][1];
    	    
    	    if (allow) {
                self.setDragAreaShadow(attr['points']);
            }
    	} else if (nodes['square'] && self.activeStep === 'area') {
    	    x = [attr['downEvent'].clientX, pos.x, pos.x];
    	    y = [attr['downEvent'].clientY, pos.y, pos.y];
    	    
    	    if (x[0] > x[1]) { 
                x[1] = x[0];
                x[0] = x[2];
            }
    	    if (y[0] > y[1]) {
                y[1] = y[0];
                y[0] = y[2];
            }
    	    
    	    s = 'left:' + x[0] + 'px;top:' + y[0] + 'px;' + 'width:' + (x[1] - x[0]) + 'px;height:' + (y[1] - y[0]) + 'px;';

    	    nodes['square'].setAttribute('style', s );
    	    attr['points'] = [[x[0], y[0]], [x[1], y[1]]];
    	    self.describeSquareSize();
    	}
};

NK.controls.Embed.prototype.downDragArea = function (e) {
    	var self = e.data,
            attr = self.attr,
            nodes = attr['nodes'] || {};


    	//if ( self.activeStep != 'area' ) { attr['downEvent'] = null; return;}
    	if (nodes['base'] && $(nodes['base']).hasClass('adjust')) {
    	    if (!$(e.target).hasClass('tool')) {
                if (self.activeStep === 'area') {
                    self.resetDragArea();
                }
    	    }
    	}
        if (e.type === 'mousedown') {
            attr['downEvent'] = e;
        } else if (e.type === 'touchstart') {
            attr['downEvent'] = {
                touch: e.changedTouches[0],
                clientX: e.changedTouches[0].clientX,
                clientY: e.changedTouches[0].clientY,
                target: e.target
            };
        }
};

NK.controls.Embed.prototype.upDragArea = function (e) {
    	var self = e.data,
            attr = self.attr;

    	attr['events']    = [attr['downEvent'], e];
    	attr['downEvent'] = null;	
    	self.setDragAreaShadow(attr['points'], true);
};

NK.controls.Embed.prototype.describeSquareSize = function() {

	var self  = this, attr = self.attr;
	var nodes = attr['nodes'], points = attr['points'];
        if ( ! nodes || ! nodes['square'] || ! points ) return;	
	
	var wrapper = nodes['square'].firstChild || nodes['square'];
	var size = self.getSizeOfPoints( points );
	wrapper.innerHTML = size[0]+'X'+size[1];
};

NK.controls.Embed.prototype.getSizeOfPoints = function( points ) {
  return ! points ? [0,0]:
    [points[1][0]-points[0][0], points[1][1]-points[0][1]]
};

NK.controls.Embed.prototype.setDragAreaShadow = function( pin, end ) {

	var self  = this, attr = self.attr;
	var nodes = attr['nodes'], points = pin || attr['points'];
        var hidden = false;
        
        if ( ! nodes || ! points ) return;

        if (self.maskLayer && self.maskLayer.getVisible()) hidden = true;

        var size = self.getSizeOfPoints( points );
        var style = '';

        style = 'top:0;bottom:0;left:0;width:'+points[0][0]+'px;';
        if (hidden) style += 'visibility:hidden;';
        nodes['left'].setAttribute( 'style', style );
	    
        style = 'top:0;height:'+points[0][1]+'px;' +
	    'left:'+points[0][0]+'px;width:'+(size[0])+'px;';
        if (hidden) style += 'visibility:hidden;';
        nodes['top'].setAttribute( 'style', style );
	
        style = 'top:0;bottom:0;right:0;left:'+points[1][0]+'px;';
        if (hidden) style += 'visibility:hidden;';
        nodes['right'].setAttribute( 'style', style );
	
        style = 'top:'+points[1][1]+'px;bottom:0;'+
	    'left:'+points[0][0]+'px;width:'+size[0]+'px;';
        if (hidden) style += 'visibility:hidden;';
        nodes['bottom'].setAttribute( 'style', style );

    	style = 'left:'+points[0][0]+'px;top:'+points[0][1]+'px;';
        if (hidden) style += 'visibility:hidden;';
    	nodes['square'].setAttribute( 'style', style );

    	self.describeSquareSize( points );
        self.setAreaSelectedBounds( points );

    	if ( ! end ) return;
    	
    	for (var i=0; i<attr['names'].length; i++ ) {
    	    if ( nodes[attr['names'][i]] ) 
    		$(nodes[attr['names'][i]]).addClass('adjust');
    	}
        self.updatePoints();
};

NK.controls.Embed.prototype.updatePoints = function() {

        if (!this.areaSelectedBounds) {
            return;
        }

        var self = this,
            b = self.areaSelectedBounds.getExtent(),
            center, tlp, brp,
            pixelBounds;

        tlp = map.getPixelFromCoordinate([b[0], b[3]]);
        brp = map.getPixelFromCoordinate([b[2], b[1]]);

        self.attr['points'][0][0] = tlp[0];
        self.attr['points'][0][1] = tlp[1];
        self.attr['points'][1][0] = brp[0];
        self.attr['points'][1][1] = brp[1];

        self.setDragAreaShadow(self.attr['points']);
        
        // Update self.data attributes for iFrame and URL generation
        center = ol.extent.getCenter(b);
        pixelBounds = [
            Math.min(tlp[0], brp[0]),
            Math.min(tlp[1], brp[1]),
            Math.max(tlp[0], brp[0]),
            Math.max(tlp[1], brp[1])
        ];
        
        self.data.width = Math.abs(ol.extent.getWidth(pixelBounds));
        self.data.height = Math.abs(ol.extent.getHeight(pixelBounds));
        self.data.centerX = center[0];
        self.data.centerY = center[1];

};

NK.controls.Embed.prototype.translateMaskToFeature = function(){

        if (!this.attr['nodes'] || !this.div || !$(this.div).hasClass('active')) {
            return;
        }

        var self = this, outerBounds, innerBounds, polygon;

        if (!self.maskLayer) {
            self.addMaskLayer();
        } else {
            self.maskLayer.getSource().clear();
        }

        outerBounds = self.getViewportBounds();
        innerBounds = self.areaSelectedBounds;

        // Create vector and add to layer
        polygon = new ol.geom.Polygon([]);
        polygon.appendLinearRing(outerBounds);
        polygon.appendLinearRing(innerBounds);
        self.featureMask = new ol.Feature({
          geometry:polygon
        });
        self.maskLayer.getSource().addFeature(self.featureMask);
        
        self.disableMaskControls();
};

NK.controls.Embed.prototype.addMaskLayer = function(){

        var self = this;

        var maskStyle = new ol.style.Style({
            fill: new ol.style.Fill({
              color : [0,0,0,0.5]
            }),
            stroke: new ol.style.Stroke({
              width : 0
            })
        });

        self.maskLayer = new ol.layer.Vector({
            title   : 'embedMaskLayer',
            shortid : 'embedMaskLayer',
            isHelper: true,
            style   : maskStyle,
            source  : new ol.source.Vector()
        });

        map.addLayer(self.maskLayer);

};

NK.controls.Embed.prototype.removeDragArea = function(){
        var self = this,
            attr = self.attr,
            nodes = attr['nodes'] || {},
            i,
            name,
            target;

        for (i = 0; i < attr['names'].length; i += 1) {
            name   = attr['names'][i]; 
            target = document.getElementById(attr['type'] + 'OF' + name);
            if (target) {
                target.parentNode.removeChild(target);
            }
            nodes[name] = null;
        }
        attr['downEvent'] = null;
        attr['points'] = null; 
        attr['events'] = null;
        attr['nodes'] = null;

        if (self.maskLayer) {
            self.maskLayer.getSource().clear();
            map.removeLayer(self.maskLayer);
            delete self.maskLayer;
        }

        if (self.areaSelectedBounds) {
            delete self.areaSelectedBounds;
        }
};

NK.controls.Embed.prototype.getViewportBounds = function(){

        var self = this, size, tl, tr, bl, br, 
            p1, p2, p3, p4, pts = [];

        //size = map.getSize();
        var v = map.getView().getProjection().getExtent();

        //tl = map.getCoordinateFromPixel([0, 0]);
        //tr = map.getCoordinateFromPixel([size[0], 0]);
        //bl = map.getCoordinateFromPixel([0, size[1]]);
        //br = map.getCoordinateFromPixel([size[0], size[1]]);

        p1 = [v[0], v[1]];
        p2 = [v[2], v[1]];
        p3 = [v[2], v[3]];
        p4 = [v[0], v[3]];

        pts.push(p1, p2, p3, p4);

        return new ol.geom.LinearRing(pts);

};

NK.controls.Embed.prototype.resetDragArea = function() {
        var self = this,
            attr = self.attr,
            nodes = attr['nodes'] || {},
            i,
            name,
            target,
            children,
            j;

        for (i = 0; i < attr['names'].length; i += 1) {
            name = attr['names'][i];
            target = document.getElementById(attr['type'] + 'OF' + name) || nodes[name];
            if (!target) {
                continue;
            }
            target.removeAttribute('style');
            target.removeAttribute('class'); 
            target.setAttribute('class', attr['type']);

            children = target.children || [];

            for (j = 0; i < children.length; j += 1) { 
                children[j].removeAttribute('style'); 
            }
        }
        attr['downEvent'] = null;
        attr['points'] = null;
        attr['events'] = null;
};

NK.controls.Embed.prototype.setAreaSelectedBounds = function(points){

        if (!points || !points.length) return;

        var self = this, tl, tr, bl, br, p1, p2, p3, p4, 
            size, pts = [];

        size = self.getSizeOfPoints(points);

        tl = map.getCoordinateFromPixel([points[0][0], points[0][1]]);
        br = map.getCoordinateFromPixel([points[1][0], points[1][1]]);

        p1 = [tl[0], tl[1]];
        p2 = [br[0], tl[1]];
        p3 = [br[0], br[1]];
        p4 = [tl[0], br[1]];

        pts.push(p1, p2, p3, p4);

        self.areaSelectedBounds = new ol.geom.LinearRing(pts);

};


NK.controls.Embed.prototype.updateStepProgressPanel = function( ) { 
        $(this.stepProgressPanel).removeClass('type-active');
        $(this.stepProgressPanel).removeClass('terms-active');
        $(this.stepProgressPanel).removeClass('area-active');
        $(this.stepProgressPanel).removeClass('markers-active');
        $(this.stepProgressPanel).removeClass('descriptions-active');
        $(this.stepProgressPanel).removeClass('preview-active');
        $(this.stepProgressPanel).removeClass('output-active');
        $(this.stepProgressPanel).addClass(this.activeStep + '-active');
};

NK.controls.Embed.prototype.selectType = function (type) {
        if (type === 'STATIC' || type === 'DYNAMIC') {
            this.data.type = type;
            if (type === 'STATIC') {
                $(this.stepSpecificElements.dynamicButton).removeClass('active');
                $(this.stepSpecificElements.staticButton).addClass('active');
            } else {
                $(this.stepSpecificElements.staticButton).removeClass('active');
                $(this.stepSpecificElements.dynamicButton).addClass('active');
            }
        }
        this.nextStep();
};

NK.controls.Embed.prototype.removeStepSpecificElements =  function () {
        var panel = this.stepSpecificPanel,
            elements = this.stepSpecificElements,
            e;

        for (e in elements) {
            if (elements.hasOwnProperty(e)) {
                elements[e].parentNode.removeChild(elements[e]);
                elements[e] = null;
                delete elements[e];
            }
        }
};

NK.controls.Embed.prototype.deleteStepData = function() {

	var self = this, data = self.data || {}, i = 0, j = 0;

        for ( var d in data ) {
            if ( ! data.hasOwnProperty(d) ) continue;

            if (d === 'markers') {
                for (i = 0, j = data[d].length; i < j; i += 1) {
                    if (data[d][i].feature) {
                        self.removeMarkerFeature(data[d][i].feature);
                        data[d][i].feature = null;
                        delete data[d][i].feature;
                    }
                }
            }

            data[d] = null;
            delete data[d];
        }

        self.steps[self.activeStep].remove.apply(self);
        self.activeStep = null;
        if (self.areaElement) {
            self.areaElement.parentNode.removeChild(self.areaElement);
            self.areaElement = null;            
        }

        /*
            Note: the "pekere" layer is automatically created by 
            NK.functions.addLabeledMarker if it doesn't exist.
        */
        var markerLayer = NK.util.getLayersBy('shortid', 'pekere');
        if (markerLayer.length) {
            markerLayer[0].destroy();
        }
	
};

NK.controls.Embed.prototype.enableMaskControls = function(){
        var self = this;
        $('.embedLight.adjust').css('visibility', 'visible');
        if (self.maskLayer) {
            self.maskLayer.setVisible(false);
        }
};
    
NK.controls.Embed.prototype.disableMaskControls = function(){
        var self = this;
        $('.embedLight.adjust').css('visibility', 'hidden');
        if (self.maskLayer) {
            self.maskLayer.setVisible(true);
        }
};

NK.controls.Embed.prototype.insertContent = function( holder ) { 
  if ( ! holder ) return;
  var self = this, stepCount = 0, stepElements = [];

  holder.innerHTML = '';

  $(holder).addClass("embedContent");

  var header = document.createElement('header');
  header.innerHTML = '<h1 class="h">Embed</h1>';

  self.stepProgressPanel = document.createElement('ol');
  self.stepProgressPanel.setAttribute('class', 'progress');

  for (var step in self.steps) {
            if (self.steps.hasOwnProperty(step)) {
                stepCount++;
                var item = document.createElement('li');
                item.setAttribute('class', step);
                item.innerHTML = 'step <span class="step-number">'+stepCount+'</span> of ';
                stepElements.push( item );
                self.stepProgressPanel.appendChild( item );
            }
  }

        while (stepElements.length > 0) {
            var stepCountElement = document.createElement('span');
            stepCountElement.innerHTML = '' + stepCount;
            stepElements.pop().appendChild(stepCountElement);
        }

        header.appendChild(self.stepProgressPanel);
        holder.appendChild(header);

        self.stepSpecificPanel = document.createElement('div');
        self.stepSpecificPanel.setAttribute('class', 'step-specific');

        holder.appendChild(self.stepSpecificPanel);

        // add the bottom navigation (next/previous) buttons
        var buttonsPanel = document.createElement('div');
        buttonsPanel.setAttribute('class', 'buttons-panel');

        self.backButton = document.createElement('button');
        self.backButton.setAttribute('class', 'back');
        self.backButton.innerHTML = 'Previous';
        buttonsPanel.appendChild(self.backButton);

        self.nextButton = document.createElement('button');
        self.nextButton.setAttribute('class', 'next');
        self.nextButton.innerHTML = 'Next';
        buttonsPanel.appendChild(self.nextButton);


        $(self.backButton).click(this, function (evt) {
            evt.data.previousStep();
        });
        $(self.nextButton).click(this, function (evt) {
            evt.data.nextStep();
        });

        holder.appendChild( buttonsPanel );
};

NK.controls.Embed.prototype.nextStep = function () {
        var removeCurrent,
            drawNext,
            validate,
            next;

        switch (this.activeStep) {
        case 'type':
            next = 'terms';
            break;
        case 'terms':
            next = 'area';
            break;
        case 'area':
            next = 'markers';
            break;
        case 'markers':
            next = 'descriptions';
            break;
        case 'descriptions':
            next = 'preview';
            break;
        case 'preview':
            next = 'output';
            break;
        case 'output':
            next = null;
            break;
        default:
            break;
        }

	this.clicked  = 'next';
        removeCurrent = this.steps[this.activeStep].remove;

        if (next) {
            validate = this.steps[this.activeStep].validate;
            if (!validate || (validate && validate.apply(this))) {
                removeCurrent.apply(this);
                drawNext = this.steps[next].draw;
                drawNext.apply(this);
                this.activeStep = next;
                this.updateStepProgressPanel();		
            }
        } else {
            // clicked next at last step
            removeCurrent.apply(this);
            this.hideControls();
	    if ( typeof(this.tracking)=='function' ) {
		this.tracking({
		    'step'   : 'end',
		    'module' : this,
		    'clicked': this.clicked
		});
            }
        }
};

NK.controls.Embed.prototype.previousStep = function () {
        var removeCurrent,
            drawPrevious,
            previous;

        switch (this.activeStep) {
        case 'type':
            previous = null;
            break;
        case 'terms':
            previous = 'type';
            break;
        case 'area':
            previous = 'terms';
            break;
        case 'markers':
            previous = 'area';
            break;
        case 'descriptions':
            previous = 'markers';
            break;
        case 'preview':
            previous = 'descriptions';
            break;
        case 'output':
            previous = 'preview';
            break;
        default:
            break;
        }

	this.clicked  = 'previous';
        removeCurrent = this.steps[this.activeStep].remove;
        removeCurrent.apply(this);

        if (previous) {
            drawPrevious = this.steps[previous].draw;
            drawPrevious.apply(this);
            this.activeStep = previous;
        }
        this.updateStepProgressPanel();
};

NK.controls.Embed.prototype.showControls = function () {
  var self = this;

  self.activeStep = 'type';
  self.steps[self.activeStep].draw.apply(self);
  self.updateStepProgressPanel();  
  $(this.div).addClass( 'active');
};

NK.controls.Embed.prototype.hideControls = function () {
  var self = this;
  var btn  = self.div;
  if ( ! btn || ! $(btn).hasClass('active') ) return;
        
  $(btn).removeClass( 'active' ); 

  self.deleteStepData();
  self.removeDragArea();
};

NK.controls.Embed.prototype.toggle = function (event) {
        var self = event.data;
        $(self.div).hasClass('active') ? self.hideControls() : self.showControls();
};

NK.controls.Embed.prototype.steps = {
        type: {
            draw: function () {

                var that = this,
                    panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements;

                $(panel).addClass('type');

                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Select type';
                panel.appendChild(elements.heading);

                // add 'dynamic map' button
                elements.dynamicButton = document.createElement('button');
                if (this.data.type === 'DYNAMIC') {
                    elements.dynamicButton.setAttribute('class', 'dynamic-button active');
                } else {
                    elements.dynamicButton.setAttribute('class', 'dynamic-button');
                }                
                elements.dynamicButton.value = 'DYNAMIC';
                elements.dynamicButton.innerHTML = '<span>Dynamic map based on open services</span><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="314.852px" height="145.847px" viewBox="0 0 314.852 145.847" class="embed type illustration" fill="none" stroke="#fff"><path d="M183.363,11.556c1.947-0.456,3.921-0.186,5.882-0.17c6.879,0.053,13.783,0.517,20.631,0.087c5.294-0.333,10.594-0.345,15.852-0.292c7.127,0.072,14.271-0.825,21.354-0.062c4.734,0.508,9.451,0.249,14.163,0.557c5.138,0.336,10.231-0.459,15.364-0.419c4.077,0.032,8.163,0.051,12.242-0.039c4.651-0.102,9.27-0.848,14.047-0.533c0.02-1.869,0.036-3.469,0.054-5.158c-6.03-0.425-11.907-0.778-17.885-0.469c-6.775,0.352-13.583,0.68-20.397,0.429c-6.154-0.226-12.34-0.517-18.472-0.145c-9.057,0.547-18.096,0.25-27.128,0.012c-5.438-0.142-10.87-0.557-16.317-0.31c-5.364,0.245-10.726,0.551-16.091,0.765c-1.193,0.048-2.394-0.505-3.884,0.004c0.163,1.738-0.423,3.569,0.3,5.229"/><path d="M313.147,142.771c0.129-6.331,0.491-12.667-0.507-18.969c-0.1-0.624-0.012-1.278,0.008-1.918c0.322-10.493,0.098-20.989-0.72-31.44c-0.457-5.852-0.529-11.69-0.801-17.531c-0.187-4.01-0.027-8.015-0.266-12.008c-0.511-8.479-0.582-16.962-0.741-25.449c-0.088-4.645,0.713-9.287-0.016-13.923"/><path d="M288.565,61.147c-3.28-0.034-6.563,0.03-9.837-0.121c-11.38-0.521-22.743,0.143-34.086,0.713c-10.179,0.511-20.327-0.109-30.489,0.064"/><path d="M309.867,21.29c-10.884,0.285-21.772,0.898-32.649,0.751c-8.636-0.116-17.279-0.2-25.919-0.397c-5.518-0.126-11.058-0.507-16.552-0.33c-10.724,0.347-21.458,1.441-32.166,0.647c-6.663-0.494-13.289-0.12-19.926-0.242c-4.951-0.092-9.94-0.279-14.873,0.095c-2.814,0.214-5.608,0.214-8.412,0.29"/><path d="M314.102,143.261c-3.445-0.388-6.904-0.023-10.316,0.222c-4.928,0.355-9.8-0.773-14.635-0.381c-7.21,0.587-14.43-0.294-21.622,0.585c-2.853,0.349-5.775,0.263-8.641,0.32c-10.244,0.203-20.469,0.941-30.728,0.825c-5.672-0.063-11.359,0.203-17.044,0.26c-6.728,0.068-13.428-0.561-20.156-0.542c-4.082,0.011-8.16,0.164-12.241,0.181c-3.627,0.017-17.935,0.861-18.094-0.818c-0.467-4.956-0.259-10.547-0.375-15.508c-0.091-3.873,0.31-8.842,0.057-12.687c-0.285-4.329,0.556-8.642,0.337-12.955c-0.404-8.004-0.558-16.017-1.106-24.018c-0.446-6.546-0.343-13.109-0.215-19.681c0.101-5.114,0.446-10.234,0.308-15.357c-0.194-7.201-0.749-14.377-0.701-21.608c0.031-4.923-0.299-9.918-0.362-14.886c-0.021-1.777,0.458-3.505,0.226-5.516c3.83,0.039,7.352,0.134,10.873,0.1c5.361-0.052,10.723-0.255,16.084-0.283c8.56-0.042,17.135,0.321,25.677-0.063c10.729-0.482,21.448,0.016,32.172-0.227c4.793-0.108,9.599-0.162,14.4-0.203c6.799-0.057,13.597-0.373,20.403-0.238c6.639,0.132,13.309-0.189,19.908,0.357c3.761,0.31,7.549,0.057,11.286,0.677c0.699,0.115,1.152,0.212,1.188,1.001c0.25,5.6,0.133,11.201,0.028,16.801c-0.013,0.642-0.461,1.276-0.707,1.913"/><path d="M291.886,133.186c0.682-3.168,0.204-6.399,0.491-9.602c0.205-2.336-1.779-3.821-4.183-3.345c-2.897,0.576-5.773,0.348-8.654,0.302c-2.266-0.037-4.442,0.676-6.729,0.495c-1.387-0.108-2.034,0.727-1.991,2.329c0.101,3.597,0.065,7.205-0.351,10.795c1.323,0.333,2.604,0.1,3.886,0.108c5.796,0.037,11.516-0.94,17.291-1.085"/><path d="M237.996,122.538c-0.04,3.76-0.113,7.52-0.099,11.279c0.004,1.113-0.753,1.534-1.466,1.381c-5.942-1.283-11.837,0.802-17.781,0.192c-1.189-0.123-2.523,0.574-3.843,0.056c-1.044-4.603-0.016-9.231-0.003-13.547c5.684-0.24,11.188,0.324,16.714,0.318c2.246-0.001,4.556,0.934,6.725-0.397"/><path d="M265.47,134.588c-0.159-0.082-0.331,0.212-0.481,0.204c-6.729-0.372-13.439,0.542-20.165,0.289c-0.32-0.012-0.638-0.158-1.19-0.303c-0.048-4.097,0.672-8.265,0.118-12.478c7.195-1.093,14.405-0.466,21.52-0.158c1.839,3.998,0.162,8.131,0.441,12.207"/><path d="M208.998,38.866c-3.276,0.429-6.566,0.035-9.866,0.249c-7.274,0.469-14.581,0.627-21.872,0.6c-3.358-0.013-6.728,0.242-10.332,0.157c0.074-1.924,0.384-3.643,0.138-5.279c-0.256-1.708,0.62-1.951,1.832-2.098c3.518-0.427,7.043,0.094,10.588-0.207c2.927-0.249,5.932-0.319,8.881-0.181c4.491,0.209,8.968-0.517,13.453-0.026c1.666,0.181,3.357,0.208,5.034,0.194c1.003-0.01,1.713,0.169,1.874,1.296L208.998,38.866z"/><path d="M288.633,54.668c-0.24,0.078-0.482,0.228-0.721,0.222c-9.934-0.237-19.853,0.576-29.769,0.535c-7.597-0.031-15.207,0.138-22.798-0.16c-7.215-0.285-14.399,0.617-21.604,0.294"/><path d="M188.617,70.895c-5.683,0.006-11.353,0.629-17.046,0.344c-0.803-0.04-1.925-0.245-2.408,0.891"/><path d="M203.095,18.004c-4.504,0.763-8.941-0.809-13.437-0.382"/><path d="M185.172,79.018c-2.642,0.133-5.282,0.3-7.926,0.388c-2.799,0.093-5.601,0.11-8.4,0.16"/><path d="M187.468,88.883c-2.95,0.694-5.933-0.002-8.882-0.007c-2.926-0.005-5.909-0.35-8.874-0.42"/><path d="M288.345,36.664c-3.295-0.815-6.562,0.181-9.845,0.129c-0.88-0.014-1.79,0.153-2.635-0.26"/><path d="M260.23,16.927c-4.149,0.588-8.32,0.366-12.485,0.348"/><path d="M177.656,17.736c-3.066,0.642-6.073-0.34-9.116-0.332c-0.805,0.002-1.629-0.166-2.403,0.21"/><path d="M178.153,61.663c-1.917,0.869-3.999,0.657-6.011,0.888c-1.193,0.136-2.422-0.25-3.601,0.212"/><path d="M288.547,17.464c-4.981-0.079-9.978-0.383-14.891,0.804"/><path d="M249.706,36.256c-2.81-0.044-5.611,0.101-8.404,0.392"/><path d="M231.903,17.348c-3.045-0.307-6.073,0.496-9.121,0.147c-1.116-0.127-2.271,0.203-3.358-0.278"/><path d="M184.955,54.055c-3.582,0.679-7.173,0.772-10.811,0.41c-1.652-0.164-3.372-0.34-5.036,0.143"/><path d="M267.71,35.966c-2.423-0.022-4.856-0.146-7.208,0.644"/><path d="M234.581,36.577c-2.642-0.032-5.285-0.019-7.917-0.323"/><path stroke-width="2" d="M255.127,90.941c-1.556,0.375-2.709-0.697-3.944-1.247c-6.373-2.833-13.023-5.012-19.332-7.939c-6.977-3.239-14.326-5.21-21.641-7.296c-7.852-2.24-15.607-4.862-23.616-6.537c-4.24-0.887-8.496-1.694-12.751-2.512c-2.525-0.487-4.955-1.412-7.537-1.641c0,0-29.19-5.183-33.688-5.474"/><path stroke-width="2" d="M252.102,85.983c0.856,1.483,2.764,2.32,3.061,4.021l0.328,1.949c-2.17,1.641-4.745,1.063-7.169,1.309"/><path d="M63.308,6.532c-3.917,0.383-7.85,0.14-11.778,0.358c-6.549,0.364-21.861-0.487-23.029-0.539C20.659,6.003,12.818,6.75,4.973,6.313c-3.405-0.19-3.699,0.441-3.968,3.944c-0.607,7.925,0.064,15.845,0.032,23.767c-0.021,5.031,0.218,10.121,0.912,15.155c0.338,2.457-0.225,4.941-0.209,7.434c0.043,6.458,1.156,12.828,1.401,19.245c0.187,4.876,1.143,9.74,0.469,14.651c-0.21,1.53,0.764,1.939,2.098,1.729c4.076-0.644,8.154-0.4,12.25-0.205c4.874,0.231,9.756,0.442,14.641,0.169c3.041-0.17,6.086,0.235,9.11,0.364c4.647,0.197,9.286,0.033,13.924,0.109c1.334,0.022,2.735-0.014,4.082,0.005c6.575,0.084,13.141-0.335,19.695-0.617c7.773-0.335,15.539-0.073,23.298-0.335c4.406-0.148,8.807-0.549,13.223-0.569c1.296-0.005,1.738-0.683,1.735-1.884c-0.006-2.011-0.061-4.001-0.266-6.018c-0.313-3.096,0.027-6.225-0.251-9.368c-0.606-6.862,0.113-13.769-0.11-20.636c-0.385-11.929,0.207-23.873-0.543-35.783c-0.252-4.013-0.436-8.005-0.345-12.031c-3.281-0.843-6.584-0.006-9.836,0.15c-2.379,0.114-4.874,0.576-7.227,0.526c-6.091-0.126-12.163,0.333-18.249,0.17C75.96,6.154,71.073,6.38,66.193,6.316L63.308,6.532z"/><path d="M71.67,75.403c0.883,3.369,4.044,2.923,6.399,3.728c2.618,0.894,5.463,0.526,8.151,1.571c2.113,0.822,3.574-1.085,4.83-2.654c2.766-3.457,4.239-7.561,5.821-11.614c0.671-1.718-0.259-2.639-1.622-3.137c-3.088-1.13-6.057-2.592-9.268-3.383c-1.904-0.469-3.5-1.703-5.461-2.099c-1.436-0.29-2.231-0.04-2.702,1.411c-1.409,4.352-3.179,8.568-5.385,12.571c-0.618,1.123-0.159,2.333-0.757,3.366"/><path d="M44.367,92.005c-0.371-2.666,0.834-5.24,0.445-7.912c-0.23-1.592,0.693-3.177-0.103-4.815c-1.003-2.063-2.892-2.285-4.765-2.483c-2.233-0.238-4.52-0.497-6.705-0.518c-3.101-0.029-6.045,1.237-7.571,4.452c-0.582,1.226-1.428,2.329-1.967,3.569c-0.573,1.323-1.47,2.216-2.739,2.802c-1.97,0.909-3.061,2.598-3.952,4.462"/><path d="M116.656,81.329c-1.689,0.337-3.326,0.169-5.049-0.043c-3.49-0.432-6.909,0.444-10.11,1.847c-5.734,2.51-11.652,3.558-17.83,2.38c-3.041-0.579-6.082-0.234-9.118-0.417c-3.094-0.187-5.547-1.154-6.892-4.255c-0.945-2.182-2.648-3.668-5.146-3.986"/><path d="M53.831,30.303c-1.251,3.093-2.393,6.251-4.323,9.004c-1.568,2.237-3.644,3.788-6.017,5.292c-3.289,2.085-6.75,4.257-8.769,8c-1.159,2.148-1.16,4.343-0.898,6.47c0.093,0.756-0.263,1.483,0.028,2.185"/><path d="M108.712,14.869c0.105,4.966-0.356,9.782-4.428,13.317c-3.164,2.746-4.705,6.367-6.03,10.18c-0.451,1.295-0.621,2.528-0.308,3.842"/><path d="M50.869,91.208c0.906-3.538,1.27-7.176,1.925-10.759c0.345-1.892-0.832-3.11-2.269-4.141c-2.38-1.707-4.96-2.94-7.837-3.555c-4.753-1.018-7.542-4.356-9.578-8.426c-0.401-0.801,0.071-1.93,0.496-2.839"/><path d="M42.441,44.183c-1.498-1.701-3.235-3.174-4.456-5.138c-1.384-2.228-3.622-3.038-6.136-3.302c-1.639-0.171-3.028-0.69-4.066-2.221c-1.713-2.525-4.221-3.666-7.32-3.332"/><path d="M78.782,21.324c-0.687,1.983-1.377,3.967-2.131,6.142c1.269,1.409,3.024,1.683,4.816,1.553c0.653-0.047,2.547-5.439,2.319-6.13c-0.363-1.094-2.735-1.871-4.764-1.559"/><path d="M50.34,45.1c-2.226,1.639-3.832,3.699-4.754,6.353c-0.557,1.6-2.029,2.583-3.169,3.785c-0.971,1.022-1.968,2.025-2.279,3.529c-0.737,3.558-2.103,4.197-5.577,2.755c-0.285-0.117-0.626-0.399-0.956-0.034"/><path d="M78.182,6.903c-1.244,2.989-2.249,3.542-5.607,3.526c-0.577-0.003-1.319,0.448-1.964,0.811c-5.939,3.349-10.482,7.973-13.578,14.08c-0.79,1.559-2.109,2.849-3.185,4.263"/><path d="M92.734,20.231c-0.96,0.495-1.479,1.604-1.415,2.356c0.22,2.634-1.121,4.017-3.04,5.531c-2.112,1.667-3.037,4.489-5.458,6.086c-2.163,1.428-2.978,3.946-3.827,6.416c0.843,1.371,1.769,2.728,3.047,3.838c2.629,2.286,7.428,2.841,10.273,0.926c1.054-0.709,2.206-1.221,3.25-1.973c2.139-1.543,4.753-1.023,7.17-0.788c1.649,0.16,3.466,2.43,2.962,3.838c-1.7,4.75,0.382,8.829,1.908,13.032c0.919,2.529,1.936,5.026,2.202,7.739"/><path d="M78.783,40.529c-0.24-0.006-0.575,0.09-0.706-0.032c-2.88-2.706-6.61-3.162-10.205-4.185c-2.989-0.85-6.047-1.821-8.613-3.899c-1.536-1.243-3.523-1.902-5.416-2.59"/><path d="M57.92,10.719c0.076,0.162,0.012,0.396-0.254,0.463c-5.715,1.412-11.401,3.327-17.314,0.808c-0.548-0.233-1.35-0.264-1.894-0.044c-4.075,1.648-8.305,1.406-12.522,1.063c-1.72-0.14-2.983,0.478-4.124,1.609"/><path d="M70.93,37.692c-0.274,1.108-1.287,1.596-1.983,2.347c-1.979,2.132-2.325,4.536-1.953,7.412c0.377,2.912,0.519,6.3-1.687,8.463c-1.39,1.361-3.291,2.403-4.774,3.841c-0.61,0.592-0.911,1.564-1.957,1.636"/><path d="M100.125,70.351c-0.864,1.485-1.136,3.283-2.505,4.507c-2.189,1.954-1.778,4.625-1.866,7.148c-0.031,0.88-0.045,1.759-0.066,2.639"/><path stroke-width="2" d="M12.663,73.424c0.498-2.069,0.358-4.147,0.167-6.24c-0.299-3.277-0.135-6.563,0.013-9.841c0.12-2.658-0.009-5.294-0.301-7.93"/><path stroke-width="2" d="M12.638,45.574c0.877,0.52,2.109,0.673,1.89,2.21c-0.139,0.979-0.852,0.983-1.495,1.155c-1.278,0.34-1.675-0.619-2.238-1.606c1.668-1.35,1.707-3.034,1.557-5.138c-0.295-4.134,0.242-8.312-0.043-12.474c-0.032-0.484-0.131-0.964-0.199-1.445"/><path d="M47.179,56.305c0.335,0.222,0.458,0.838,0.937,0.727c1.709-0.401,1.95-2.04,2.426-3.305c0.413-1.092-0.323-1.869-1.682-1.966c-0.68,1.371-1.606,2.658-1.675,4.304"/><path stroke-width="2" d="M17.801,80.886c-2.723,0.096-5.433,0.573-8.169,0.276"/><path d="M73.913,52.892c-1.555-2.377-3.871-3.778-6.358-4.96"/><path d="M48.96,23.459c0.815-0.599,1.6,0.013,2.396,0.068c1.431-3.844,1.254-4.265-2.245-4.899c0.142,1.571-2.803,2.727-0.385,4.584"/><path stroke-width="2" d="M11.986,21.508c-0.425-2.076-0.687-4.115-0.139-6.258c0.329-1.284,0.123-2.705,0.157-4.065"/><path stroke-width="2" d="M15.483,16.074c-2.54,0.727-5.122,0.321-7.69,0.288"/><path d="M47.268,33.5c-0.352-0.845-1.34-0.941-1.853-1.514c-1.354-1.517-2.285-1.009-3.18,0.333c0.365,1.724,1.076,3.115,2.566,4.067c1.45-0.323,1.692-1.738,2.461-2.646"/></svg>';
                panel.appendChild(elements.dynamicButton);                    
                $(elements.dynamicButton).click(that, function (evt) {
                    evt.data.selectType(evt.data.stepSpecificElements.dynamicButton.value);
                });

                // add 'static map' button
                elements.staticButton = document.createElement('button');
                elements.staticButton.value = 'STATIC';
                elements.staticButton.innerHTML = '<span>Static map</span><svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="251.729px" height="140.72px" viewBox="0 0 251.729 140.72" class="embed type static illustration"><g stroke-width="1.5" fill="none"><path stroke-width="2" d="M212.252,82.787c-1.557,0.375-2.709-0.698-3.942-1.248c-6.373-2.833-13.025-5.011-19.333-7.938c-6.978-3.239-14.327-5.21-21.642-7.296c-7.852-2.24-15.606-4.862-23.615-6.537c-4.24-0.887-8.496-1.694-12.751-2.512c-2.526-0.487-4.955-1.412-7.537-1.641c0,0,4.497,0.291,0,0"/><path stroke-width="2" d="M209.228,77.828c0.856,1.484,2.764,2.321,3.061,4.021l0.328,1.949c-2.17,1.642-4.746,1.064-7.17,1.31"/><path d="M50.926,9.66c-3.917,0.383-7.85,0.14-11.778,0.358c-6.549,0.364-21.862-0.487-23.029-0.539c-7.842-0.348-3.3,0.399-11.145-0.038c-3.405-0.19-3.699,0.441-3.969,3.944C0.398,21.31,1.07,29.229,1.036,37.152c-0.02,5.031,0.219,10.121,0.913,15.155c0.339,2.457-0.225,4.941-0.209,7.434c0.043,6.458,0.408,14.468,0.654,20.885c0.185,4.876,0.215,8.799-0.458,13.71c-0.21,1.531-0.389,1.287,3.708,1.483c4.874,0.23,9.687-0.216,14.573-0.489c3.041-0.17,6.087,0.235,9.11,0.364c4.647,0.197,9.286,0.033,13.924,0.11c1.334,0.021,2.735-0.015,4.082,0.004c6.575,0.084,13.141-0.335,19.695-0.617c7.773-0.335,15.539-0.073,23.298-0.335c4.406-0.148,8.807-0.549,13.223-0.569c1.296-0.005,1.738-0.683,1.735-1.884c-0.006-2.011-0.061-4.001-0.266-6.018c-0.313-3.096,0.027-6.225-0.251-9.368c-0.606-6.862,0.113-13.769-0.11-20.636c-0.385-11.929,0.207-23.873-0.543-35.783c-0.252-4.013-0.436-8.005-0.345-12.031c-3.281-0.843-6.584-0.006-9.836,0.15c-2.379,0.114-4.874,0.576-7.227,0.526c-6.091-0.126-12.163,0.333-18.249,0.17c-4.879-0.131-9.766,0.095-14.646,0.031L50.926,9.66z"/><path d="M59.289,78.531c0.883,3.369,4.044,2.923,6.399,3.728c2.618,0.894,5.463,0.526,8.151,1.571c2.113,0.822,3.574-1.085,4.83-2.654c2.766-3.457,4.239-7.561,5.821-11.614c0.671-1.718-0.259-2.639-1.622-3.137c-3.088-1.13-6.057-2.592-9.268-3.383c-1.904-0.469-3.5-1.703-5.461-2.099c-1.436-0.29-2.231-0.04-2.702,1.411c-1.409,4.352-3.179,8.568-5.385,12.571c-0.618,1.123-0.159,2.333-0.757,3.366"/><path d="M31.985,95.133c-0.371-2.666,0.834-5.24,0.445-7.912c-0.23-1.592,0.693-3.177-0.103-4.815c-1.003-2.063-2.892-2.285-4.765-2.483c-2.232-0.238-4.52-0.497-6.705-0.518c-3.101-0.029-6.045,1.237-7.57,4.452c-0.582,1.226-1.429,2.329-1.968,3.569c-0.573,1.323-1.47,2.216-2.739,2.802c-1.971,0.909-3.061,2.598-3.952,4.462"/><path d="M104.274,84.456c-1.689,0.338-3.326,0.17-5.049-0.043c-3.49-0.431-6.909,0.445-10.11,1.848c-5.734,2.51-11.652,3.558-17.83,2.38c-3.041-0.579-6.082-0.234-9.118-0.417c-3.094-0.187-5.547-1.154-6.892-4.255c-0.945-2.182-2.648-3.668-5.146-3.986"/><path d="M41.449,33.431c-1.251,3.093-2.393,6.251-4.323,9.004c-1.568,2.237-3.644,3.788-6.017,5.292c-3.289,2.085-6.75,4.257-8.769,8c-1.159,2.148-1.161,4.343-0.899,6.47c0.094,0.756-0.262,1.483,0.029,2.185"/><path d="M96.331,17.997c0.105,4.966-0.356,9.782-4.428,13.317c-3.164,2.746-4.705,6.367-6.03,10.18c-0.451,1.295-0.621,2.528-0.308,3.842"/><path d="M38.487,94.335c0.906-3.538,1.27-7.176,1.925-10.759c0.345-1.892-0.832-3.11-2.269-4.141c-2.38-1.707-4.96-2.94-7.837-3.555c-4.753-1.019-7.543-4.356-9.578-8.426c-0.401-0.801,0.071-1.93,0.496-2.839"/><path d="M30.059,47.311c-1.497-1.701-3.235-3.174-4.456-5.138c-1.385-2.228-3.621-3.038-6.136-3.302c-1.639-0.171-3.028-0.69-4.065-2.221c-1.714-2.525-4.223-3.666-7.321-3.332"/><path d="M66.4,24.452c-0.687,1.983-1.377,3.967-2.131,6.142c1.269,1.409,3.024,1.683,4.816,1.553c0.653-0.047,2.547-5.439,2.319-6.13c-0.363-1.094-2.735-1.871-4.764-1.559"/><path d="M37.958,48.228c-2.226,1.639-3.832,3.699-4.754,6.353c-0.557,1.6-2.029,2.583-3.169,3.785c-0.971,1.022-1.968,2.025-2.279,3.529c-0.737,3.558-2.103,4.197-5.577,2.755c-0.285-0.117-0.626-0.399-0.955-0.034"/><path d="M65.8,10.031c-1.244,2.989-2.249,3.542-5.607,3.526c-0.577-0.003-1.319,0.448-1.964,0.811c-5.939,3.349-10.482,7.973-13.578,14.08c-0.79,1.559-2.109,2.849-3.185,4.263"/><path d="M80.352,23.359c-0.96,0.495-1.479,1.604-1.415,2.356c0.22,2.634-1.121,4.017-3.04,5.531c-2.112,1.667-3.037,4.489-5.458,6.086c-2.163,1.428-2.978,3.946-3.827,6.416c0.843,1.371,1.769,2.728,3.047,3.838c2.629,2.286,7.428,2.841,10.273,0.926c1.054-0.709,2.206-1.221,3.25-1.973c2.139-1.543,4.753-1.023,7.17-0.788c1.649,0.16,3.466,2.43,2.962,3.838c-1.7,4.75,0.382,8.829,1.908,13.032c0.919,2.529,1.936,5.026,2.202,7.739"/><path d="M66.401,43.657c-0.24-0.006-0.575,0.09-0.706-0.032c-2.88-2.706-6.61-3.162-10.205-4.185c-2.989-0.85-6.047-1.821-8.613-3.899c-1.536-1.243-3.523-1.902-5.416-2.59"/><path d="M45.539,13.847c0.076,0.162,0.012,0.396-0.254,0.463c-5.715,1.412-11.401,3.327-17.314,0.808c-0.548-0.233-1.35-0.264-1.895-0.044c-2.433,0.984-4.924,1.294-7.433,1.312c-1.69,0.01-3.39-0.111-5.088-0.249c-1.719-0.14-2.983,0.478-4.124,1.609l-8.298,3.626"/><path d="M58.548,40.82c-0.274,1.108-1.287,1.596-1.983,2.347c-1.979,2.132-2.325,4.536-1.953,7.412c0.377,2.912,0.519,6.3-1.687,8.463c-1.39,1.361-3.291,2.403-4.774,3.841c-0.61,0.592-0.911,1.564-1.957,1.636"/><path d="M87.743,73.479c-0.864,1.485-1.136,3.283-2.505,4.507c-2.189,1.954-1.778,4.625-1.866,7.148c-0.031,0.88-0.045,1.759-0.066,2.639"/><path d="M34.797,59.433c0.335,0.222,0.458,0.838,0.937,0.727c1.709-0.401,1.95-2.04,2.426-3.305c0.413-1.092-0.323-1.869-1.682-1.966c-0.68,1.371-1.606,2.658-1.675,4.304"/><path d="M61.531,56.02c-1.555-2.377-3.871-3.778-6.358-4.96"/><path d="M36.579,26.587c0.815-0.599,1.6,0.013,2.396,0.068c1.431-3.844,1.254-4.265-2.245-4.899c0.142,1.571-2.803,2.727-0.385,4.584"/><path d="M34.886,36.628c-0.352-0.845-1.34-0.941-1.853-1.514c-1.354-1.517-2.285-1.009-3.18,0.333c0.365,1.724,1.076,3.115,2.566,4.067c1.45-0.323,1.692-1.738,2.461-2.646"/><path d="M228.589,107.571c-5.675-0.365-11.363-0.341-17.045-0.637c-6.861-0.355-13.756-0.053-20.636-0.093c-7.359-0.042-14.72-0.167-22.08-0.218c-1.52-0.011-3.04,0.146-4.56,0.226"/><path d="M229.309,27.65c-1.456-1.3-3.064-0.132-4.561-0.144c-4.238-0.034-8.477,0.484-12.721,0.598c-4.881,0.13-9.761,0.238-14.642,0.423c-8.069,0.305-16.157,0.126-24.237,0.057c-2.402-0.02-4.773,0.717-7.217,0.09c-0.73-0.188-1.72,0.236-2.383,0.896"/><path d="M232.908,101.089c-13.68,0-27.368,0.286-41.036-0.116c-7.124-0.21-14.245-0.164-21.362-0.396c-1.942-0.062-3.813,0.86-5.762,0.273"/><path d="M188.269,1.01c-2.96,0.61-5.96,0.256-8.87-0.086c-3.582-0.421-7.08,0.018-10.562,0.392c-5.754,0.617-11.524,0.937-17.29,1.342c-1.381,0.097-2.36,0.187-2.17,1.954c0.862,8.005-0.584,15.985-0.289,24.001c0.231,6.271,0.601,12.499,1.412,18.729c0.389,2.987,0.338,6.073,0.581,9.107c0.604,7.589-0.817,12.363-0.189,19.936c0.274,3.297,0.192,8.12,0.5,11.389c0.663,7.032-0.343,14.362,0.25,21.361c0.55,6.486,0.386,12.241,1,18.729c0.267,2.817,0.281,7.648,0,10.771c4.061,0,9.088,0.144,12.821-0.184c2.995-0.261,5.926,0.174,8.887,0.092c2.399-0.064,4.802,0.044,7.199-0.023c5.372-0.154,10.752,0.016,16.074,0.563c7.357,0.758,14.731,0.408,22.092,0.77c4.93,0.241,9.914-0.189,14.875,0.116c0.611,0.038,1.034-0.315,1.442-0.716c3.035-2.966,6.029-5.974,9.136-8.862c1.889-1.758,3.003-4.112,4.965-5.845c1.391-1.226,0.641-3.342,0.687-4.978c0.23-8.168-0.296-16.327-0.842-24.48c-0.177-2.628-0.036-5.277-0.026-7.918c0.026-7.295-0.541-14.571-1.055-21.833c-0.396-5.606-0.584-11.197-0.634-16.806c-0.052-5.921-0.19-11.84-0.223-17.761c-0.047-8.092-1.531-16.124-0.98-24.24c0.075-1.115-0.132-2.262,0.043-3.354c0.271-1.696-0.47-1.952-1.953-1.957c-6.247-0.022-12.479,0.005-18.726,0.438c-4.778,0.332-9.58-0.609-14.395-0.415c-6.009,0.243-11.994-0.747-17.997-0.428c-1.843,0.098-3.681,0.163-5.522,0.196"/><path d="M224.988,11.81c-2.773-0.624-5.615-0.336-8.401-0.392c-6.313-0.125-12.637-0.266-18.961,0.103c-4.152,0.243-8.336,0.067-12.474,0.558c-2.646,0.314-5.294,0.271-7.922,0.166c-4.664-0.188-9.269,0.753-13.922,0.526c-1.007-0.049-2.003,0.383-1.619,1.416c0.8,2.151,0.19,4.354,0.598,6.515c0.301,1.597,1.106,2.015,2.461,1.9c5.835-0.496,11.694,0.09,17.516-0.299c4.561-0.304,9.131-0.328,13.693-0.812c5.243-0.556,10.543-0.953,15.834-0.097c4.948,0.802,9.915-0.244,14.879-0.008c2.636,0.126,5.286,0.118,8.342-0.39c0.087-3.082-1.576-6.176-1.028-9.552c-2.995-0.489-5.875,0.874-8.755,0.126"/><path d="M214.188,119.571c-2.561-0.649-5.121,0.045-7.68-0.008c-6.888-0.139-13.771,0.288-20.633,0.613c-6.02,0.285-12.012-0.424-18.01,0.092c-1.347,0.116-2.718,0.655-4.078,0.022"/><path d="M233.868,33.65c-3.35,0.493-6.72,0.148-10.08,0.241c-8.238,0.226-16.475-0.214-24.727,0.387c-6.366,0.463-12.794,0.17-19.192,0.068c-5.373-0.085-10.722,0.302-16.081,0.504"/><path d="M223.788,113.81c-3.439,0.463-6.878,0.271-10.32,0.013c-1.033-0.078-2.079-0.018-3.119-0.012c-8.961,0.046-17.925-0.28-26.879-0.146c-5.298,0.081-10.556-0.621-15.841-0.335c-0.804,0.042-1.631-0.145-2.4,0.24"/><path d="M213.229,47.57c-2.24-0.387-4.45,0.239-6.726,0.091c-5.503-0.361-11.047-0.527-16.552-0.268c-8.56,0.402-17.123,0.422-25.683,0.656"/><path d="M232.429,39.41c-4.711,0.631-9.404,0.753-14.167,0.314c-3.967-0.365-8-0.224-11.991-0.033c-4.16,0.199-8.348,0.112-12.476,0.507c-10.149,0.97-20.337,0.472-30.486,1.132"/><path d="M236.748,125.571c1.404,1.389,0.249,3.045,0.464,4.562c0.364,2.564-0.447,5.108-0.224,7.677"/><path d="M247.309,127.01c-0.765-0.042-1.445,0.197-2.171,0.447c-2.638,0.909-5.125,0.148-7.549-0.927"/></g></svg>';
                if (this.data.type === 'STATIC') {
                    elements.staticButton.setAttribute('class', 'static-button active');
                } else {
                    elements.staticButton.setAttribute('class', 'static-button');
                }
                panel.appendChild(elements.staticButton);
                $(elements.staticButton).click(that, function (evt) {
                    evt.data.selectType(evt.data.stepSpecificElements.staticButton.value);
                });

            },
            validate: function () {
                return this.data.type === 'STATIC' || this.data.type === 'DYNAMIC';
            },
            remove: function () {
                $(this.stepSpecificPanel).removeClass('type');
                this.removeStepSpecificElements();
            }
        },
        terms: {
            draw: function () {

                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements;

                $(panel).addClass('terms');
                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Terms';
                panel.appendChild(elements.heading);

                elements.p1 = document.createElement('p');
                elements.p1.innerHTML = 'You can use the maps freely for any internet based purposes. You are not allowed to combine multiple maps to form a bigger, continous map.';
                panel.appendChild(elements.p1);

                elements.p2 = document.createElement('p');
                elements.p2.innerHTML = 'Svalbard terms';
                panel.appendChild(elements.p2);

                elements.p3 = document.createElement('p');
                elements.p3.innerHTML = 'Content providers: Kartverket, Geovekst, municipalities and Norge digitalt partners.';
                panel.appendChild(elements.p3);

            },
            remove: function () {
                var panel = this.stepSpecificPanel;
                $(panel).removeClass('terms');
                this.removeStepSpecificElements();
            }
        },
        area: {
            draw: function () {

                if (this.div && $(this.div).hasClass('active')) {
                    this.enableMaskControls();
                    //this.translateFeatureToMask();
                }

                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    that = this,
                    attr = that.attr;

                $(panel).addClass('area');
                
                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Choose area';
                panel.appendChild(elements.heading);

                elements.modeOptionsContainer = document.createElement('div');
                elements.modeOptionsContainer.setAttribute('class', 'mode-options-container');

                elements.instructions = document.createElement('p');
                elements.instructions.setAttribute('class', 'draw-instructions');
                elements.instructions.innerHTML = 'Hold down left mouse button and draw desired embed area on the map. You may later adjust the size of the area with the buttons that appear on the corners of the drawn rectangle.';

                elements.modeOptionsContainer.appendChild(elements.instructions);

                if (this.data.type === 'DYNAMIC') {

                    elements.includeTools = document.createElement('input');
                    elements.includeTools.setAttribute('id', 'include-map-tools');
                    elements.includeTools.setAttribute('type', 'checkbox');
                    elements.includeTools.innerHTML = 'Include map tools';
                    if (this.data.includeTools) {
                        elements.includeTools.setAttribute('checked', 'checked');
                    }
                    elements.modeOptionsContainer.appendChild(elements.includeTools);

                    elements.label = document.createElement('label');
                    elements.label.setAttribute('for', 'include-map-tools');
                    elements.label.innerHTML = 'Include map tools';
                    elements.modeOptionsContainer.appendChild(elements.label);

                    $(elements.includeTools).change(that, function (evt) {
                        var include = !!this.checked;
                        evt.data.data.includeTools = include;
                    });
                }

                panel.appendChild(elements.modeOptionsContainer);
                //panel.appendChild(elements.fixedInputsContainer);

                if ( ! attr['nodes'] ) that.insertDragArea();

            },
            validate: function () {
                var d = this.data;
                return d.width && d.height && d.centerX && d.centerY;
            },
            remove: function () {
                var panel = this.stepSpecificPanel;
                //this.boxControl.deactivate();
                $(panel).removeClass('area');
                this.removeStepSpecificElements();
            }
        },
        markers: {
            draw: function () {

                if (this.div && $(this.div).hasClass('active')) {
                    this.translateMaskToFeature();
                }

                this.addedMarker = null;

                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    that = this,
                    i, j,
                    markerListItem,
                    removeMarkerElement,
                    id,
                    illustration,
                    explanation;

                $(panel).addClass('markers');

                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Include markers';
                panel.appendChild(elements.heading);

                elements.instructions = document.createElement('div');
                elements.instructions.setAttribute('class', 'instructions');

                illustration = document.createElement('div');
                illustration.setAttribute('class', 'marker-illustration');
                illustration.innerHTML = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="110.66px" height="70px" viewBox="0 0 110.66 70"><g fill-rule="evenodd" clip-rule="evenodd"><path d="M29.665,36.869c0-0.794,0-0.794,0.453-1.556c1.917-1.584,3.918-0.551,4.938,0.821c2.44,3.28,3.329,5.362,5.307,8.916c2.675,4.812,5.153,9.73,7.834,14.539c0.625,1.121,0.549,1.962-0.187,2.822c-1.825,2.138-3.814,4.093-6.507,5.126c-1.358,0.521-2.71,0.771-4.159,0.122c-3.13-1.402-6.334-2.643-9.449-4.078c-2.753-1.268-5.417-2.727-8.137-4.067c-1.401-0.69-2.549-1.644-3.346-2.984c-0.906-1.524-0.208-2.886,1.566-3.036c1.738-0.146,3.263,0.657,4.836,1.208c0.598,0.209,1.152,0.541,1.835,0.869c0.23-0.758-0.337-1.054-0.666-1.399c-2.588-2.718-5.183-5.431-7.805-8.116c-1.682-1.725-2.994-3.738-4.463-5.627c-1.182-1.521-1.754-3.444-2.045-5.241c-0.753-4.642-1.959-9.228-2.078-13.961c-0.017-0.718-0.349-0.919-0.93-1.137c-5.758-2.164-6.891-6.776-6.628-11.247c0.192-3.258,2.298-5.467,4.81-7.374c2.042-1.549,4.304-1.716,6.604-1.217c2.515,0.544,5.308,2.529,6.044,5.032c0.698,2.379,0.911,4.587,1,7.083c0.122,3.41-2.519,5.646-5.126,7.45c-0.779,0.54-1.341,0.975-1.401,1.997c-0.22,3.826-0.545,7.646-0.756,11.472c-0.095,1.705-0.014,1.71,1.628,1.968c1.334,0.209,2.344,1.002,3.241,1.914c1.008,1.029,3.795,4.464,5.193,5.563c-0.417-1.477-0.552-2.641,0.485-3.707c1.274-1.31,2.338-0.139,3.577,0.17c0.588-0.952-0.147-1.97,1.117-2.619C27.703,35.932,28.447,36.714,29.665,36.869 M29.845,59.031c-0.912,0.366-1.581-0.155-2.269-0.513c-1.417-0.737-2.794-1.555-4.236-2.236c-1.513-0.716-3.064-1.377-4.779-1.451c-0.4-0.018-0.824,0.008-1.055,0.404c-0.285,0.49-0.078,0.897,0.259,1.294c0.624,0.737,1.286,1.423,2.155,1.875c5.452,2.843,11.023,5.432,16.679,7.838c1.626,0.691,3.206,0.572,4.868-0.106c2.172-0.887,3.54-2.682,5.191-4.161c0.799-0.717,0.552-1.622,0.15-2.432c-0.709-1.429-1.511-2.812-2.231-4.236c-3.399-6.699-6.009-11.744-10.119-18.035c-0.971-1.486-1.882-1.999-2.965-1.583c-0.22,0.084-0.856,0.681-0.833,0.916c0.125,1.763,0.626,2.147,1.455,3.23c1.261,1.648,2.344,3.426,3.509,5.144c0.245,0.362,0.356,0.783-0.042,1.053c-0.387,0.261-0.756,0.012-1.019-0.325c-0.243-0.316-0.468-0.648-0.699-0.973c-1.812-2.534-2.551-3.578-4.367-6.107c-0.606-0.842-0.559-0.696-1.576-1.115c-0.704-0.289-1.546,0.243-1.47,1.052c0.141,1.491,0.011,1.721,1,2.792c2.014,2.18,2.667,3.208,4.549,5.383c0.258,0.299,0.478,0.635,0.672,0.978c0.13,0.229,0.027,0.473-0.161,0.646c-0.189,0.177-0.459,0.226-0.64,0.057c-0.408-0.376-0.809-0.773-1.148-1.211c-1.323-1.703-2.78-3.183-4.188-4.812c-1.401-1.624-0.667-0.958-2.35-2.366c-0.456-0.382-1.021-0.43-1.535,0.036c-0.498,0.452-0.154,2.315,0.412,3.065c1.777,2.352,2.609,3.118,4.423,5.443c0.882,1.131,0.722,0.798,1.534,1.98c0.191,0.276,0.147,0.657-0.175,0.82c-0.164,0.084-0.5,0.013-0.657-0.114c-0.369-0.299-0.73-0.636-1.004-1.021c-1.433-2.034-2.226-2.262-3.904-4.079c-2.601-2.816-5.153-5.683-8.001-8.26c-1.434-1.297-2.603-1.693-3.106-1.025c-0.877,1.164-0.025,2.176,0.587,3.031c1.86,2.596,3.722,5.244,6.097,7.374c3.752,3.366,6.771,7.441,10.618,10.7C29.708,58.175,29.93,58.439,29.845,59.031 M17.159,11.97c-0.055-0.794-0.239-4.366-1.063-6.375c-1.17-2.864-6.238-5.164-8.998-4.098C3.409,2.921,0.993,6.79,1.304,10.771c0.347,4.412,2.795,7.405,6.926,8.334C13.11,20.202,17.437,15.765,17.159,11.97 M9.818,27.813c0.174,0.008,0.347,0.017,0.521,0.024c0.135-1.979,0.283-3.959,0.401-5.94c0.036-0.592-0.083-1.125-0.852-1.168c-0.752-0.042-0.975,0.391-0.957,1.04C8.992,23.824,9.271,25.841,9.818,27.813"/></g><g fill-rule="evenodd" clip-rule="evenodd" transform="translate(26, 0)"><path d="M33.611,25.087c-3.092-0.08-5.993,0.094-8.877,0.405c-4.486,0.486-8.994,0.245-13.476,0.53c-2.924,0.188-5.864,0.251-8.777,0.609c-0.749,0.092-0.886-0.141-0.863-0.829c0.145-4.362-0.291-8.672-1.179-12.943C-0.29,9.363-0.013,5.858,0.558,2.383c0.21-1.275,1.585-1.254,2.461-1.268c2.635-0.042,5.262-0.248,7.893-0.264c1.357-0.008,2.689-0.253,4.058-0.21c5.4,0.17,10.804,0.191,16.204,0.358c6.923,0.214,13.808-0.452,20.712-0.724c4.941-0.196,9.898,0.039,14.85,0.014c2.434-0.013,4.865-0.178,7.297-0.28c2.252-0.094,4.429,0.56,6.66,0.69c0.575,0.033,1.005,0.485,0.964,1.153c-0.339,5.533,0.089,11.069-0.096,16.604c-0.056,1.692,0.206,3.401,0.001,5.102c-0.042,0.348-0.109,0.744-0.308,1.012c-0.294,0.396-0.801,0.638-0.896-0.121c-0.092-0.741-0.516-0.737-1.063-0.801c-1.624-0.188-3.146,0.434-4.74,0.538c-5.991,0.392-11.965,1.058-17.958,1.343c-4.175,0.199-8.365,0.189-12.548,0.32c-0.982,0.03-1.809,0.28-2.517,0.88c-3.933,3.332-8.038,6.455-11.825,9.967c-2.738,2.538-5.585,4.959-8.267,7.562c-0.421,0.407-0.978,0.682-1.494,0.979c-0.344,0.197-0.707,0.169-0.953-0.19c-0.248-0.362-0.061-0.619,0.172-0.947c4.499-6.304,9.096-12.53,14.128-18.424C33.391,25.56,33.44,25.407,33.611,25.087 M23.727,40.495c0.153-0.115,0.309-0.229,0.458-0.349c2.111-1.704,4.044-3.605,6.052-5.424c3.783-3.426,7.844-6.526,11.783-9.768c0.281-0.23,0.574-0.541,0.941-0.433c1.599,0.476,3.168-0.091,4.752-0.075c5.591,0.059,11.163-0.287,16.736-0.691c4.928-0.359,9.851-0.722,14.757-1.309c1.034-0.124,1.423-0.458,1.363-1.549c-0.097-1.826-0.193-3.682,0.017-5.49c0.491-4.226-0.174-8.426-0.088-12.638c0.01-0.44-0.054-0.839-0.654-0.968c-3.297-0.704-6.694-1.053-9.985-0.765c-4.784,0.418-9.549,0.125-14.31,0.148C51.055,1.205,46.586,1.608,42.1,1.681c-3.127,0.049-6.272,0.321-9.414,0.305c-3.068-0.014-6.146,0.022-9.2-0.214C20.743,1.56,18.008,1.703,15.27,1.61c-1.903-0.064-3.823,0.015-5.72,0.195C7.184,2.029,4.76,1.839,2.469,2.696C1.993,2.874,1.626,3.058,1.536,3.635C1.154,6.052,1.01,8.485,1.41,10.897c0.742,4.476,1.783,8.912,1.635,13.492c-0.026,0.801,0.251,0.968,1.051,0.95c4.745-0.104,9.462-0.619,14.23-0.589c5.524,0.035,11.052-0.673,16.578-1.063c0.399-0.028,0.838-0.161,1.066,0.287c0.214,0.421-0.043,0.751-0.331,1.058c-2.699,2.873-5.239,5.885-7.611,9.03C26.48,36.114,24.723,38.024,23.727,40.495"/><path d="M38.877,12.34c0.632-0.607,1.211-1.265,2.089-1.549c1.275-0.412,2.463,0.33,2.577,1.653c0.182,2.094-1.021,3.931-3.03,4.626c-1.328,0.459-2.262-0.031-2.501-1.528c-0.158-0.974-0.537-0.821-1.013-0.382c-0.734,0.677-1.938,0.651-2.406,1.767c-0.166,0.395-1.296-0.239-1.247-0.83c0.247-3.057,0.099-6.158,0.963-9.15c0.033-0.115,0.062-0.232,0.108-0.342c0.131-0.308,0.298-0.589,0.705-0.479c0.408,0.111,0.465,0.477,0.36,0.769c-0.32,0.89-0.197,1.819-0.326,2.722c-0.071,0.497,0.007,0.684,0.591,0.719C37.462,10.438,38.009,10.829,38.877,12.34 M42.577,13.146c-0.017-1.098-0.637-1.472-1.437-0.909c-1.054,0.741-1.675,1.811-1.699,3.135c-0.015,0.864,0.41,1.167,1.211,0.731C41.885,15.433,42.379,14.297,42.577,13.146 M35.706,11.465c-0.538-0.066-0.81,0.169-0.815,0.722c-0.003,0.357-0.069,0.718-0.027,1.067c0.072,0.583-0.673,1.336-0.106,1.639c0.654,0.35,1.211-0.498,1.804-0.831c0.624-0.349,1.122-0.927,0.917-1.623C37.252,11.672,36.43,11.569,35.706,11.465"/><path d="M71.832,12.674c-0.936,1.308-1.609,2.3-2.955,2.421c-1.281,0.114-1.771-0.327-1.769-1.627c0.007-2.459,1.842-4.629,4.283-5.089c0.23-0.042,0.444-0.165,0.664-0.251c0.754-0.292,1.311,0.018,1.192,0.767c-0.449,2.847,0.455,5.63,0.289,8.458c-0.097,1.635-0.838,2.617-2.376,3.018c-0.844,0.22-2.98-0.709-3.463-1.535c-0.131-0.223-0.35-0.509-0.117-0.768c0.259-0.287,0.584-0.174,0.87,0.006c0.367,0.232,0.707,0.521,1.096,0.708c1.429,0.688,2.379,0.193,2.671-1.354C72.506,15.913,72.007,14.485,71.832,12.674 M71.611,10.437c-0.048-0.661-0.397-1.062-0.987-0.602c-1.167,0.911-1.843,2.19-2.117,3.636c-0.115,0.598,0.205,0.92,0.862,0.62C70.261,13.682,71.657,11.414,71.611,10.437"/><path d="M14.478,11.362c0.149,3.093-0.97,6.218-0.961,9.458c0.002,0.267-0.055,0.514-0.337,0.535c-0.389,0.03-0.597-0.266-0.601-0.605c-0.012-0.913-0.324-1.8-0.157-2.734c0.176-0.98,0.298-1.976,0.36-2.97c0.026-0.416,0.547-1.078-0.322-1.239c-0.753-0.14-1.681,0.582-1.674,1.314c0.009,1.196,0.109,2.39,0.168,3.586c0.017,0.362,0.338,0.85-0.266,0.995c-0.64,0.153-0.72-0.452-0.79-0.824c-0.212-1.13-0.383-2.277-0.319-3.433c0.04-0.719-0.05-1.21-0.961-0.941c-0.35,0.104-0.822,0.155-0.869-0.314c-0.044-0.441,0.417-0.535,0.785-0.519c0.972,0.04,1.235-0.474,1.155-1.345c-0.116-1.257,0.23-2.454,0.547-3.651c0.107-0.406,0.31-0.826,0.787-0.734c0.538,0.103,0.433,0.58,0.339,0.976c-0.248,1.051-0.464,2.11-0.481,3.192c-0.007,0.419-0.237,1.083,0.573,1.023c0.668-0.05,1.542,0.127,1.622-0.949c0.065-0.875,0.106-1.752,0.142-2.629c0.021-0.516,0.202-0.837,0.781-0.824c0.665,0.015,0.642,0.453,0.604,0.919C14.561,10.167,14.527,10.684,14.478,11.362"/><path d="M66.586,14.946c-1.191,0.613-2.227,1.009-3.321,1.195c-1.013,0.173-1.738-0.261-1.927-1.31c-0.38-2.116,0.26-3.946,1.739-5.465c0.677-0.695,2.009-0.552,2.689,0.195c0.702,0.768,0.598,2.142-0.264,2.914c-0.622,0.558-1.345,0.97-2.121,1.299c-0.428,0.183-0.959,0.405-0.686,1.046c0.232,0.546,0.686,0.481,1.209,0.43C64.715,15.17,65.436,14.508,66.586,14.946M62.777,12.875c0.858-0.325,1.51-0.708,2.038-1.239c0.361-0.363,0.415-0.845,0.032-1.28c-0.458-0.521-0.834-0.079-1.088,0.192C63.197,11.146,62.77,11.847,62.777,12.875"/><path d="M54.057,19.462c1.463,1.315,2.243,1.153,2.908-0.598c0.782-2.055,0.575-4.209,0.415-6.337c-0.058-0.749-0.286-1.484-0.4-2.23c-0.059-0.393-0.084-0.861,0.448-0.942c0.472-0.072,0.843,0.101,0.927,0.678c0.449,3.13,0.824,6.256-0.206,9.351c-0.259,0.781-0.683,1.423-1.476,1.788C55.265,21.82,54.22,21.209,54.057,19.462"/><path d="M19.171,11.637c0.833-0.029,1.695,0.019,1.915,1.01c0.196,0.88-0.299,1.513-1.082,1.927c-0.559,0.295-1.103,0.603-1.709,0.818c-0.51,0.182-1.229,0.314-0.913,1.22c0.266,0.763,0.769,0.929,1.495,0.825c0.384-0.054,0.985-0.606,1.118,0.007c0.138,0.631-0.691,0.498-1.083,0.596c-2.197,0.547-3.586-0.812-3.227-3.099C16,12.936,17.293,11.711,19.171,11.637 M17.814,14.681c0.779-0.135,1.454-0.527,2.017-1.115c0.164-0.17,0.345-0.381,0.216-0.629c-0.141-0.273-0.415-0.341-0.717-0.296c-1.022,0.152-1.567,0.862-1.943,1.722C17.246,14.687,17.489,14.771,17.814,14.681"/><path d="M46.847,11.314c1.294-0.415,2.519-0.728,3.807-0.667c0.292,0.014,0.647,0.029,0.676,0.323c0.037,0.391-0.337,0.549-0.671,0.486c-1.123-0.209-1.957,0.513-2.86,0.911c-1.374,0.606-1.67,1.489-1.408,3.219c0.056,0.37,0.417,0.886-0.314,1.047c-0.672,0.149-0.83-0.314-0.938-0.802c-0.424-1.922,0.026-3.803,0.308-5.687c0.071-0.478,0.474-0.633,0.903-0.602c0.552,0.04,0.562,0.464,0.541,0.884C46.874,10.696,46.863,10.967,46.847,11.314"/><path d="M28.955,13.019c-1.214,0.653-2.565,0.821-3.8,1.375c-0.897,0.402-1.493,0.823-1.374,1.913c0.065,0.587-0.018,1.191-0.029,1.787c-0.008,0.402,0.034,0.827-0.551,0.863c-0.601,0.037-0.781-0.439-0.806-0.839c-0.074-1.188-0.127-2.39-0.03-3.573c0.048-0.595,0.021-1.186,0.067-1.778c0.043-0.552,0.283-0.943,0.85-0.959c0.537-0.015,0.797,0.412,0.78,0.873c-0.029,0.844,0.365,0.761,0.967,0.607C26.309,12.956,27.598,12.561,28.955,13.019"/><path d="M57.544,7.22c-0.192-0.654,0.176-0.838,0.585-0.917c0.556-0.105,0.696,0.318,0.689,0.731c-0.007,0.469-0.034,1.065-0.679,1.073C57.533,8.114,57.619,7.516,57.544,7.22"/></g></svg>';
                elements.instructions.appendChild(illustration);

                explanation = document.createElement('p');
                explanation.innerHTML = 'Click in the map to add markers with descriptions.';             
                elements.instructions.appendChild(explanation);

                panel.appendChild(elements.instructions);

                if (this.data.markers) {
                    for (i = 0, j = this.data.markers.length; i < j; i += 1) {
                        this.addMarkerToMarkerList(this.data.markers[i]);
                    }
                }

                //this.markerAdder.activate();
                //this.map.events.register('embedMarkerPointSelected', this, this.embedMarkerPointSelectHandler);
                $(map.getViewport()).addClass('nkAddMarker');

            },
            remove: function () {
                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    e, r;

                $(panel).removeClass('markers');
                if (this.addedMarker) {
                    this.removeMarkerFeature(this.addedMarker);
                    this.addedmarker = null;
                    delete this.addedMarker;
                }

                if (elements.markerRemoveLinks) {
                    while (elements.markerRemoveLinks.length > 0) {
                        r = elements.markerRemoveLinks.pop();
                        r.parentNode.removeChild(r);
                        r = null;
                    }
                    delete elements.markerRemoveLinks;
                }

                for (e in elements) {
                    if (elements.hasOwnProperty(e)) {
                        elements[e].parentNode.removeChild(elements[e]);
                        elements[e] = null;
                        delete elements[e];
                    }
                }
                //this.markerAdder.deactivate();
                //this.map.events.remove('embedMarkerPointSelected');
                $(map.getViewport()).removeClass('nkAddMarker');
            }
        },
        descriptions: {
            draw: function () {

                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    that = this,
                    shortDescExplanation,
                    longDescExplanation;


                $(panel).addClass('descriptions');
                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Map description';
                panel.appendChild(elements.heading);

                elements.recommendation = document.createElement('p');
                elements.recommendation.setAttribute('class', 'recommendation');
                elements.recommendation.innerHTML = 'To ensure a good user experience, we recommend you provide descriptions for your map. As a result, the embedded map will cater to people using assistive technology.';
                panel.appendChild(elements.recommendation);

                elements.shortDescLabel = document.createElement('label');
                elements.shortDescLabel.setAttribute('for', 'short-desc');
                elements.shortDescLabel.innerHTML = 'Short description:';
                panel.appendChild(elements.shortDescLabel);

                elements.shortDescExample = document.createElement('span');
                elements.shortDescExample.innerHTML = 'I.ex. <em>Stores in Hordaland</em>';
                panel.appendChild(elements.shortDescExample);

                elements.shortDescHelp = document.createElement('div');
                elements.shortDescHelp.setAttribute('id', 'short-desc-help');

                elements.shortDescWhy = document.createElement('a');
                elements.shortDescWhy.setAttribute('href', '#whyShortDescription');
                elements.shortDescWhy.innerHTML = 'Why?';

                shortDescExplanation = document.createElement('div');
                shortDescExplanation.setAttribute('id', 'short-desc-explanation');
                shortDescExplanation.innerHTML = '<h2 class="h">' + 'Why?' + '</h2>A short description is shown when the mouse cursor is held over the embedded map.';
                elements.shortDescExplanationClose = document.createElement('a');
                elements.shortDescExplanationClose.setAttribute('href', '#close-short-description-explanation');
                elements.shortDescExplanationClose.setAttribute('class', 'close');
                elements.shortDescExplanationClose.innerHTML = 'close';

                shortDescExplanation.appendChild(elements.shortDescExplanationClose);
                elements.shortDescHelp.appendChild(elements.shortDescWhy);
                elements.shortDescHelp.appendChild(shortDescExplanation);
                panel.appendChild(elements.shortDescHelp);

                elements.shortDescInput = document.createElement('input');
                elements.shortDescInput.setAttribute('id', 'short-desc');
                elements.shortDescInput.setAttribute('type', 'text');
                if (this.data.shortDesc) {
                    elements.shortDescInput.setAttribute('value', this.data.shortDesc);
                }
                panel.appendChild(elements.shortDescInput);


                elements.longDescLabel = document.createElement('label');
                elements.longDescLabel.setAttribute('for', 'long-desc');
                elements.longDescLabel.innerHTML = 'Long description:';
                panel.appendChild(elements.longDescLabel);

                elements.longDescHelp = document.createElement('div');
                elements.longDescHelp.setAttribute('id', 'long-desc-help');

                elements.longDescWhy = document.createElement('a');
                elements.longDescWhy.setAttribute('href', '#whylongDescription');
                elements.longDescWhy.innerHTML = 'Why?';

                longDescExplanation = document.createElement('div');
                longDescExplanation.setAttribute('id', 'long-desc-explanation');
                longDescExplanation.innerHTML = '<h2 class="h">' + 'Why?' + '</h2>A long description is used when there is an error, or when the user is unable to see the map.';
                elements.longDescExplanationClose = document.createElement('a');
                elements.longDescExplanationClose.setAttribute('href', '#close-long-description-explanation');
                elements.longDescExplanationClose.setAttribute('class', 'close');
                elements.longDescExplanationClose.innerHTML = 'close';

                longDescExplanation.appendChild(elements.longDescExplanationClose);
                elements.longDescHelp.appendChild(elements.longDescWhy);
                elements.longDescHelp.appendChild(longDescExplanation);
                panel.appendChild(elements.longDescHelp);

                elements.longDescInput = document.createElement('textarea');
                elements.longDescInput.setAttribute('id', 'long-desc');
                if (this.data.longDesc) {
                    elements.longDescInput.innerHTML = this.data.longDesc;
                }

                panel.appendChild(elements.longDescInput);
                setTimeout(function () {document.getElementById('short-desc').focus();}, 10);

                if (!this.div || !$(this.div).hasClass('active')) {
                    this.adjustWidgetPosition();
                }
            },
            validate: function () {
                //return this.data.longDesc && this.data.shortDesc;
                return true;
            },
            remove: function () {
                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements;

                $(panel).removeClass('descriptions');

                elements.longDescExplanationClose.parentNode.removeChild(elements.longDescExplanationClose);
                elements.longDescExplanationClose = null;
                delete elements.longDescExplanationClose;

                elements.shortDescWhy.parentNode.removeChild(elements.shortDescWhy);
                elements.shortDescWhy = null;
                delete elements.shortDescWhy;

                elements.shortDescExplanationClose.parentNode.removeChild(elements.shortDescExplanationClose);
                elements.shortDescExplanationClose = null;
                delete elements.shortDescExplanationClose;

                elements.longDescWhy.parentNode.removeChild(elements.longDescWhy);
                elements.longDescWhy = null;
                delete elements.longDescWhy;

                this.removeStepSpecificElements();
            }
        },
        preview: {
            draw: function () {

                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    that = this,
                    shortDesc = this.data.shortDesc || '',
                    longDesc  = this.data.longDesc || '',
                    url, 
                    hash, 
                    extraPath = '';

                $(panel).addClass('preview');
                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Generate map';
                panel.appendChild(elements.heading);

                elements.shortDesc = document.createElement('section');
                elements.shortDesc.innerHTML = '<h3 class="h">' + 'Short description:' + '</h3><span>' + shortDesc + '</span>';
                panel.appendChild(elements.shortDesc);

                elements.longDesc = document.createElement('section');
                elements.longDesc.innerHTML = '<h3 class="h">' + 'Long description:' + '</h3><span>' + longDesc + '</span>';
                panel.appendChild(elements.longDesc);

                elements.mapContainer = document.createElement('section');
                $(elements.mapContainer).addClass('map-container');

                elements.map = this.getIframe();

                elements.mapContainer.appendChild(elements.map);
                panel.appendChild(elements.mapContainer);

                this.nextButton.innerHTML = 'Generate code';

                var widget = document.getElementById('PMwidget');
                if (widget && $(widget).offset().top < 0) {
                    $(panel).addClass('limit-height');
                }

                if (!this.div || !$(this.div).hasClass('active')) {
                    this.adjustWidgetPosition();
                }

            },
            remove: function () {
                var panel = this.stepSpecificPanel;
                $(panel).removeClass('preview');
                this.removeStepSpecificElements();
                this.nextButton.innerHTML = 'Next';
            }
        },
        output: {
            draw: function () {
                var panel = this.stepSpecificPanel,
                    elements = this.stepSpecificElements,
                    that = this;

                $(panel).addClass('output');
                elements.heading = document.createElement('h2');
                elements.heading.setAttribute('class', 'h');
                elements.heading.innerHTML = 'Select code and copy';
                panel.appendChild(elements.heading);

                elements.embedCodeOutput = document.createElement('div');
                elements.embedCodeOutput.setAttribute('class', 'output-code');
                elements.embedCodeOutput.innerText = this.getIframe().outerHTML;
                panel.appendChild(elements.embedCodeOutput);
                this.nextButton.innerHTML = 'Quit';
            },
            remove: function () {
                var panel = this.stepSpecificPanel;
                $(panel).removeClass('output');
                this.removeStepSpecificElements();
                this.nextButton.innerHTML = 'Next';
            }
        }
};


goog.object.extend(options, {target:container});
NK.functions.addControlToContext(new NK.controls.Embed(options), context);

