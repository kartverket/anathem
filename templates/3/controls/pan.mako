<%inherit file="/3/controls/controlcontext.mako" />
options.createControlMarkup = function(control) {
	var button, 
		span;

	button = document.createElement('button');

	if (control.text) {
		span = document.createElement('span');
		span.innerHTML = control.text;
		button.appendChild(span);
	}
	return button;
};

// TODO: 
// NK.functions.addControlToContext(new NK.control.PanPanel(options), context);
