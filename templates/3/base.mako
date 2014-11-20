<!doctype html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en" style="height:100%"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en" style="height:100%"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en" style="height:100%"> <![endif]-->
<!--[if IE 9]>    <html class="no-js lt-ie10" lang="en" style="height:100%"> <![endif]-->
% if manifestName:
<!--[if gt IE 9]><!--> <html class="no-js" lang="en" style="height:100%" manifest="${manifestName}.manifest"> <!--<![endif]-->
% else:
<!--[if gt IE 9]><!--> <html class="no-js" lang="en" style="height:100%"> <!--<![endif]-->
% endif

  <head>
    <!-- by kartverket / Thomas Hirsch 2012 - public domain -->
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <title>${title}</title>
    <meta name="description" content="" />
    <meta name="google" content="notranslate" />
    <meta name="viewport" content="width=device-width, user-scalable=no" />
    <meta name="apple-mobile-web-app-capable" content="yes" /> 
    <meta name="apple-touch-fullscreen" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="#333333" />
    <link rel="shortcut icon" type="image/x-icon" href="img/favicon.ico" />

    <link rel="stylesheet" type="text/css" href="/css/ol.css" />
    <link rel="stylesheet" type="text/css" href="/css/norgeskart-legacy.css" />
  </head>
  <body style="height: 100%; overflow: hidden;">
    <header>
    </header>
% if mapClass:
    <div id="map" role="main" class="${mapClass}" style="width:100%; height:100%"></div>
% else:
    <div id="map" role="main" style="width:100%; height:100%"></div>
% endif
    <footer>
    </footer>
    <script src="js/modernizr.min.js"></script>
    <script src="js/proj4.js"></script>
    <script src="js/ol-debug.js"></script>
    <script src="js/jquery.js"></script>
    <!--[if IE]>
    <script src="js/xdr.js"></script>
    <![endif]-->

% if includeXDM:
    <%include file="/easyXDM.html" />
% endif
    <script src="${mapscript}"></script>
  </body>
</html>
