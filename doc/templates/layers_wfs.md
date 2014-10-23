### TEMPLATE: layers/wfs

include a WFS layer in the base map
Parameters:

* layerGroup: include layer in this layer group (used by menus and layer selectors to display only layers belonging to the same group)
* visible: Set visibility of the layer
* hidefromlayerswitcher: if set, the layer will not appear in any menu or layer switcher
* styleName: style definition to be used for this layer
* styleNameSLD: SLD to be used as a style for this layer
* popup: (TEMPLATE) a popup definition to be used to display metadata for this layer
* version: WFS version parameter
* name: Name of the layer to be displayed in menus etc.
* id: short id to be used to identify this layer in the client URL
* url: Base URL of the WMTS
* namespace: namespace of data in the WFS service
* namespacePrefix: prefix for the namespace of data in the WFS service
* featuretype: featuretype to be requested from the WFS service
