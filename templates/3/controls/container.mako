(function (context, containerParam, collect) {
var parentContainer = document.body,
container;
% if className:
  var className = "${className} toolbar";
% else:
  var className = "toolbar";
% endif

// set parentContainer if divControllerContainer is set
if (containerParam) {
parentContainer = containerParam;
% if className:
  className = "${className}";
% else:
  className = "panel";
% endif
}

% if topnavbar:
  container = document.createElement('nav');
  container.id = "top-toolbar";
  container.className = className + ' navbar-inverse';

  var innerContainer = document.createElement('div');
  innerContainer.className = 'container-fluid';

  var header = document.createElement('div');
  header.className = 'navbar-header';

  header.innerHTML = '<button class="navbar-toggle collapsed" type="button" data-toggle="collapse" data-target="#navbar-collapse-1"><span class="sr-only">Toggle navigation</span><span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span></button>';
  header.innerHTML += ' <a class="navbar-brand" href="http://kartverket.no" target="_blank">${svgLogo}</a>';

  var collectDiv = document.createElement('div');
  collectDiv.className = 'collapse navbar-collapse';
  collectDiv.id = 'navbar-collapse-1';

  collect = document.createElement('ul');
  collect.className = 'nav navbar-nav';

  collectDiv.appendChild(collect);

  innerContainer.appendChild(header);
  innerContainer.appendChild(collectDiv);

  container.appendChild(innerContainer);
  parentContainer.appendChild(container);
% elif top:
  container = document.createElement("li");
  % if id:
    container.id = "${id}";
  % endif

  % if name:
	  % if toggleButton:
        var header = document.createElement("button");
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
  collect.appendChild(container);
% else:

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

  % if layerselector:
    var header = document.createElement("button");
    header.className = "panel-name";
	% if svgIcon:
      header.innerHTML = '${svgIcon}';
	%endif

    var div = document.createElement("div");
    div.setAttribute("id","map_chooser")
    div.setAttribute("class","widget")

    var wrapper = document.createElement("div");
    wrapper.setAttribute("class","wrapper")

    var cnt = document.createElement("div");
    cnt.setAttribute("class","cnt")
    cnt.setAttribute("id","layerswitcher")
    var h3 = document.createElement("h3");
    var text = document.createTextNode("Velgt kart type:");
    h3.appendChild(text);
    cnt.appendChild(h3);

    wrapper.appendChild(cnt);
    div.appendChild(wrapper);

    container.appendChild(header);
    container.appendChild(div);

  % endif

  container.className = className;
  parentContainer.appendChild(container);

  % if layerselector:
  $('#layerselector-panel').click(this, function(event) {
      $(this).toggleClass('active');
  });
  % endif

% endif


% if controls:
	${controls}
% endif
}(controlContext, container, collect));
