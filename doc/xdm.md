## XDM commands received by the client

set map zoom level and center

    {"cmd":"setCenter","x":57114,"y":6450905,"zoom":10}

set a layer as visible, while turning off all layers that are not marked as "data layer", i.e. base/modus layers

    {"cmd":"setBasemap","id":"sjo"}

just set a layer to visible, leaving the other ones untouched

    {"cmd":"setVisible","id":"sjo"}

add an external data source, loading new layers according to the GetCapabilities file

    {"cmd":"addDataSource","type":"wms","url":"http://openwms.statkart.no/skwms1/wms.abas"}

add marker
    
    {"cmd":"addMarker","x":57114,"y":6450905}

## XDM messages sent by the client

reply to setVisible or setBasemap

    {"type":"result","cmd":"setVisible","affected":1}

notify host that a new layer has been loaded

    {"type":"layerLoaded","title":"Kommunenummer","parent":"ABAS_WMS","url":"http://openwms.statkart.no/skwms1/wms.abas"}

notify host that the initialization is completed

    {"type":"mapInitialized","vectorLayers":[]}
