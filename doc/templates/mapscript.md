### TEMPLATE: mapscript

The base javascript for the norgeskart.no and geoportal map client
Parameters:

* tokenServiceUrl: URL to retrieve a Gatekeeper token for WMS services
* projection: Base projection of the map (EPSG code)
* i18n: (TEMPLATE) code for internationalization
* functions: (TEMPLATE) a list of map functions to include before loading the main map
* language: language code to be used for i18n (nb, en, ...)
* center: (TEMPLATE) include code to set variables NK.defaultCenter and NK.defaultZoom
* styles: (TEMPLATE) list of style definitions to include for vector layers
* baselayers: (TEMPLATE) definition for the base layer of the map
* overlays: (TEMPLATE) list of definitions for overlay (not base) layers on the map
* controls: (TEMPLATE) list of OpenLayers controls to include in the client
