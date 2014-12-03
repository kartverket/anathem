<%inherit file="/3/controls/controlcontext.mako" />
% if group:
        options.group = "${group}";
% endif

% if not 'NK.controls.LayerSelector' in vars:

NK.controls = NK.controls || {};
NK.controls.LayerSelector = function(options) {
  var wrapper, layerList, inputElem, labelSpan, li, trigger; 
  var i, len, layer, checked;
  var layers;
  options = options || {};

  this.group = options.group;
  this.dataLayers = [];

  wrapper = document.createElement("div");
  layers  = NK.util.getLayersBy('layerGroup', this.group);

  if (layers.length) {
    layerList = document.createElement('ul');
  }
  for (i = 0, len = layers.length; i < len; i++) {
    layer = layers[i];

    if ((this.group && this.group === layer.get('layerGroup')) || this.group === null) {
      if (!(layer.get('isBaseLayer') || layer.get('isHelper'))) {
        checked = layer.getVisible();
    
        // create input element
        inputElem = document.createElement("input");
        inputElem.type = "radio";
        inputElem.value = layer.get('title');
        inputElem.checked = checked;
        inputElem.defaultChecked = checked;
        inputElem.className = "olButton";
        if (checked) {
          $(inputElem).addClass("is-checked");
        }
        inputElem._layer = layer;
        inputElem._layerSwitcher = this;

        // create span
        labelSpan = document.createElement("label");
        labelSpan["for"] = inputElem.id;
        $(labelSpan).addClass("labelSpan olButton");
        if (checked) {
          $(labelSpan).addClass("for-checked");
        }
        labelSpan._layer = layer;
        labelSpan._layerSwitcher = this;
        labelSpan.innerHTML = layer.get('title');

        // create list item
        li = document.createElement("li");
        li.id = layer.get('shortid').replace(/\./g, '-') + '-selector';
        $(li).addClass('raster-layer-selector-item');

        if (layer.get('hideFromLayerSwitcher')) {
          $(li).addClass('hidden');
        }

        this.dataLayers.push({
          'layer': layer,
          'inputElem': inputElem,
          'labelSpan': labelSpan
        });

        trigger = document.createElement('span');
        $(trigger).addClass('layerTriggerTarget');
        $(labelSpan).click({
          selector: this,
          inputElem: inputElem,
          labelSpan: labelSpan,
          layer   : layer
        }, this.activate);

        labelSpan.appendChild( trigger );
        li.appendChild(inputElem);
        li.appendChild(labelSpan);
        layerList.appendChild(li);		
      }
    }
  }
  if (layerList) {
    layerList.className = "rasterLayerList";
    wrapper.appendChild(layerList);
  }

  ol.control.Control.call(this, {
    element: wrapper,
    target: options.target
  });
}
ol.inherits(NK.controls.LayerSelector, ol.control.Control);

NK.controls.LayerSelector.prototype.activate =  function(event) {
  var rasterControls, i;
  var self  = event.data.selector;
  var layer = event.data.layer;

  if (!self.disabled) {
    rasterControls = NK.util.getControlsByClass(NK.controls.LayerSelector);
    for (i = 0; i < rasterControls.length; i++) { 
      rasterControls[i].hideAll();
    }
    layer.setVisible(true);
    $(event.data.inputElem).addClass('is-checked');
    $(event.data.labelSpan).addClass('for-checked');
  }
};

NK.controls.LayerSelector.prototype.hideAll =  function() {
  for (var l in this.dataLayers) {
    this.dataLayers[l].layer.setVisible(false);
    $(this.dataLayers[l].inputElem).removeClass('is-checked');
    $(this.dataLayers[l].labelSpan).removeClass('for-checked');
  }
}

<% vars['NK.controls.LayerSelector']=True %>
%endif

goog.object.extend(options, {
  target: container
});
NK.functions.addControlToContext(new NK.controls.LayerSelector(options), context);
