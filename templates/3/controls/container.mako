(function (context, containerParam) {
	var parentContainer = document.body,
		className = "toolbar",
		container;
% if className:
	className = "${className} toolbar";
% endif	

	// set parentContainer if divControllerContainer is set
	if (containerParam) {
		parentContainer = containerParam;
		className = "panel";
% if className:
	className = "${className} panel";
% endif	

	}
	
	container = document.createElement("div");

	% if id:
	container.id = "${id}";
	% endif


	% if name:
		% if toggleButton:
			var header = document.createElement("button");
                        $(header).click(container, function(event) {
                          $(event.data).toggleClass("minified");
                        });
		% else:
			var header = document.createElement("div");
		% endif

		header.className = "panel-name";
		var name = document.createElement('span');
		name.innerHTML = "${name}";

		% if svgIcon:
			header.innerHTML = '${svgIcon}';
		%endif

		header.appendChild(name);
		container.appendChild(header);
	% endif


	container.className = className;
	parentContainer.appendChild(container); 

	% if controls:
	${controls}
	% endif
}(controlContext, container));
