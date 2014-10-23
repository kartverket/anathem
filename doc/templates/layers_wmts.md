### TEMPLATE: layers/wmts

Template to include a WMTS layer in the map.
Parameters:

* url: Base URL of the WMTS
* layerGroup: include layer in this layer group (used by menus and layer selectors to display only layers belonging to the same group)
* epsg: use a projection code differing from the map base projection, e.g. for compatible WGS vs. ETRS codes (optional)
* extent: set the maximum bounding box for displaying this layer. The map client will not attempt to load tiles outside this bounding box, comma separated. (deprecated, OpenLayers parameter tileFullExtent)
* databbox: set the maximum bounding box for displaying this layer. The map client will not attempt to load tiles outside this bounding box, comma separated. (OpenLayers parameter maxExtent)
* dataURL: hint for the export tool where data or images from this layer can be downloaded via a supported download service (WMS/WFS)
* dataLayers: hint for the export tool which LAYERS (WMS) or TYPE (WFS) should be used when downloading data.
* dataType: hint for the export tool which service type to use for downloading data ["wms" or "wfs"]
* dataFormats: hint for the export tool which data formats are supported by the data service (comma separated list of MIME types)
* tileorigin: tile origin (top left corner) of the WMTS layer, comma separated (optional, sets OpenLayers parameter of the same name)
* isBaseLayer: 'true' if this layer is to be used as the map base layer
* id: short id to be used to identify this layer in the client URL
* name: Name of the layer to be displayed in menus etc.
* layer: WMTS layer name requested from the service
