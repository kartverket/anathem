<%inherit file="/3/controls/controlcontext.mako" />

NK.controls = NK.controls || {};
NK.controls.OverlayGroupPanel = function(options) {
	options = options || {};

% if group:
    options.group = '${group}';
% endif
% if svgIcon:
    options.svgIcon = '${svgIcon}';
% endif
% if buttonText:
    options.buttonText = '${buttonText}';
% endif
	options.title = "${title}";
% if groupheaders:
    ${groupheaders}
% endif

	var self = this,
	cName = 'OverlayGroupPanel-button nkButton',
	mapped,
	btn,
	buttonContent = '',
	toolElement,
	panel,
	menu;

    goog.object.extend(this, options);
    if (options.group) {
        this.group = options.group;
    }
    if (options.svgIcon) {
        this.svgIcon = options.svgIcon;
    }
    if (options.buttonText) {
        this.buttonText = options.buttonText;
    }
    this.title = options.title;
    this.groupedLayers = {
        layers: [],
        groups: {}
    };
    this.layers = [];
    if (options.groupHeaders) {
        this.groupHeaders = options.groupHeaders;
    }
	if (this.target) {
		self.div = this.target;
	}

	this.buildLayerGroupStructure();

	mapped = 'OpenLayers_Control_OverlayGroupPanel' + map.getTarget();
	btn    = document.createElement('button');
	$(btn).click(this, this.toggle);
	btn.className = btn.className === "" ? cName : btn.className + " " + cName;

	var tmp = document.createElement('div')
	tmp.innerHTML = self.title;
	btn.title = tmp.textContent || tmp.innerText;

	if (this.svgIcon) {
		//buttonContent += OpenLayers.Util.hideFromOldIE(this.svgIcon);
		buttonContent += this.svgIcon;
	}
	if (this.buttonText) {
		buttonContent += '<span>' + this.buttonText + '</span>';
	}
	if (this.buttonText && this.svgIcon) {
        $(btn).addClass('button-text-with-icon');
	}

	btn.innerHTML = buttonContent;

	if (self.div == null) {
		self.div = btn;
	} else {
		if ($(self.div, 'panel')) {
			panel = self.div;
			toolElement = document.createElement('div');
            $(toolElement).addClass('tool');
            $(toolElement).addClass('overlay-group-panel');
			toolElement.appendChild(btn);
			panel.appendChild(toolElement);
			self.div = toolElement;
		} else {
			self.div.appendChild(btn);
		}
	}

	if (this.group) {
        $(this.div).addClass(this.group.replace(/\./g, '-'));
	}

	self.cnt = document.createElement("div");
    self.cnt.setAttribute('class', 'cnt');

	self.widget = NK.util.createWidget(self.cnt, 1);
	menu = this.drawMenu(this.groupedLayers);
	this.cnt.appendChild(menu);

	this.addEventListeners();
	this.updateStatus();

	self.div.appendChild(self.widget);

    ol.control.Control.call(this, {
        element: self.div,
        target: options.target
    });
};

ol.inherits(NK.controls.OverlayGroupPanel, ol.control.Control);

NK.controls.OverlayGroupPanel.prototype.toggle = function (event) {
	var self = event.data;
	$(self.div).toggleClass('active');
};

NK.controls.OverlayGroupPanel.prototype.buildLayerGroupStructure = function (event) {
	var i, j, k, l, layer,
	subGroup,
	groups,
	currentGroup,
	layerData;

	// populate groupedLayers
	var layers = map.getLayers().getArray();
	for (i = 0, j = layers.length; i < j; i += 1) {
		layer = layers[i];

		if (!layer.isBaseLayer) {
			if (layer['values_'].layerGroup && layer['values_'].layerGroup.indexOf(this.group) !== -1) {

				// add this layer to the group/layer hierarchy
				subGroup = layer['values_'].layerGroup.replace(this.group, '');
				if (subGroup.indexOf('.') === 0) {
					subGroup = subGroup.substring(1);
				}
				currentGroup = this.groupedLayers;

				if (subGroup.length > 0) {
					groups = subGroup.split('.');
					for (k = 0, l = groups.length; k < l; k += 1) {
						if (!currentGroup.groups[groups[k]]) {
							currentGroup.groups[groups[k]] = {
								layers: [],
								groups: {}
							};
						}
						currentGroup = currentGroup.groups[groups[k]];
					}
				}
				layerData = {
					'layer': layer
				};
				currentGroup.layers.push(layerData);
				this.layers.push(layerData);
			}
		}
	}
};
NK.controls.OverlayGroupPanel.prototype.drawMenu = function (group, className) {
    var i, j, subGroup, groupHeader, groupHeading, menu, menuItem, link,
        menuElementCount = 0;

    menu = document.createElement('ul');

    if (className) {
        $(menu).addClass(className);
    }

    for (subGroup in group.groups) {
        if (group.groups.hasOwnProperty(subGroup)) {
            menuItem = document.createElement('li');
            if (this.groupHeaders && this.groupHeaders[subGroup]) {
                groupHeader = document.createElement('header');

                if (this.groupHeaders[subGroup].heading) {
                    groupHeading = document.createElement('h1');
                    $(groupHeading).addClass('h');
                    groupHeading.innerHTML = this.groupHeaders[subGroup].heading;
                    groupHeader.appendChild(groupHeading);
                }
                groupHeader.setAttribute('tabindex', 0);
                menuItem.appendChild(groupHeader);
                this.groupHeaders[subGroup].headerElement = groupHeader;
            }
            menuItem.appendChild(this.drawMenu(group.groups[subGroup], subGroup));
            OpenLayers.Event.observe(menuItem, 'focusout', function (evt) {
				$(this).removeClass('focused');
            });
            OpenLayers.Event.observe(menuItem, 'focusin', function (evt) {
                $(this).addClass('focused');
            });
            menu.appendChild(menuItem);
            menuElementCount += 1;
        }
    }
    for (i = 0, j = group.layers.length; i < j; i +=1) {
        menuItem = document.createElement('li');
        link = document.createElement('a');
        link.setAttribute('href', '#/' + (group.layers[i].layer.getVisible() ? '-' : '+') + group.layers[i].layer['values_'].shortid);
        link.innerHTML = group.layers[i].layer['values_'].title;
        group.layers[i].link = link;
        menuItem.appendChild(link);
        group.layers[i].inputElem = menuItem;
        menu.appendChild(menuItem);
        menuElementCount += 1;
    }
    $(menu).addClass('containing-' + menuElementCount);

    return menu;
};

NK.controls.OverlayGroupPanel.prototype.addEventListeners = function () {
var i, j, group,
	that = this;

	for (i = 0, j = this.layers.length; i < j; i += 1) {
		$(this.layers[i].link).on('click', function (evt) {
			var i, j, layerData;

			evt.preventDefault ? evt.preventDefault() : evt.returnValue = false;

			for (i = 0, j = that.layers.length; i < j; i += 1) {
				if (that.layers[i].link === evt.target) {
					layerData = that.layers[i];
					break;
				}
			}
			if (layerData) {
				layerData.layer.setVisible(!!!layerData.layer.getVisible());
				that.updateLayer(layerData);
			}
		});
	}
	if (this.groupHeaders) {
		for (group in this.groupHeaders) {
			if (this.groupHeaders.hasOwnProperty(group) && this.groupHeaders[group].headerElement) {
				OpenLayers.Event.observe(this.groupHeaders[group].headerElement, 'click', function (evt) {
					var group, grp;
					evt.preventDefault ? evt.preventDefault() : evt.returnValue = false;

					for (grp in that.groupHeaders) {
						if (that.groupHeaders.hasOwnProperty(grp) && that.groupHeaders[grp].headerElement === evt.currentTarget) {
							group = that.groupHeaders[grp];
							break;
						}
					}
					if (group) {
						if (OpenLayers.Element.hasClass(group.headerElement, 'active')) {
                            $(group.headerElement).removeClass('active');
						} else {
                            $(group.headerElement).addClass('active');
						}
					}
				});
			}
		}
	}
};
NK.controls.OverlayGroupPanel.prototype.updateStatus = function () {
	var i, 	j;

	for (i = 0, j = this.layers.length; i < j; i += 1) {
		this.updateLayer(this.layers[i]);
	}
};
NK.controls.OverlayGroupPanel.prototype.updateLayer = function (layerData) {
    if (layerData.layer.getVisible()) {
        $(layerData.link).addClass('active');
    } else {
        $(layerData.link).removeClass('active');
    }
};

NK.functions.addControlToContext(new NK.controls.OverlayGroupPanel({target: container}), context);