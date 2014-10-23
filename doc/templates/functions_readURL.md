### TEMPLATE: functions/readURL

this utility function reads the hash state from the URL and loads/enables map layers accordingly. 
current URL syntax is:
   #zoom/x/y/parameter/parameter
* zoom is the map zoom level 
* x is the x coordinate of the map
* y is the y coordinate of the map
optional parameters map include
* +layer sets a layer visibility
* -layer removes a layer visibility if it is turned on by the default configuration
* !feature highlights a feature on the map 
* m/x/y/text adds a marker with a popup on the map
* w/url=... adds a WMS layer to the map (deprecated)
* l/type/[url] adds an overlay to the map. Valid types include 'wms', 'wfs', 'geojson' and 'drawing'

