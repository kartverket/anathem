% if not 'unlabeledMarkerStyle' in vars:

NK = NK || {};
NK.styles = NK.styles || {};

var iconStyle = new ol.style.Style({
	image: new ol.style.Icon(/** @type {olx.style.IconOptions} */ ({
		anchor: [0.5, 46],
		anchorXUnits: 'fraction',
		anchorYUnits: 'pixels',
		opacity: 0.75,
		fillOpacity: 1,
		pointRadius: 0,
		fontFamily: "Arial, Courier New, monospace",
		fontWeight: "bold",
		fillColor: "transparent",
		graphicWidth: 44,
		graphicHeight: 56,
		graphicYOffset: -55,
		graphicXOffset: -11,
		zIndex: 0,
		src: 'data:image/png;base64,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'
	}))
});

var select = new ol.style.Style({
	fillOpacity: 1
});

var temporary = new ol.style.Style({
	fillOpacity: 1
});

NK.styles.unlabeledMarker = {
	"default": function(feature, resolution) {
		return iconStyle;
	},
	"select": function(feature, resolution) {
		return select;
	},
	"temporary": function(feature, resolution) {
		return temporary;
	}
};

<% vars['unlabeledMarkerStyle']=True %>
% endif