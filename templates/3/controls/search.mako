## -*- coding: utf-8 -*-
<%inherit file="/3/controls/controlcontext.mako" />

% if coordinates:
        options.coordinates = "${coordinates}";
% endif
% if searchUrl:
        options.searchUrl = "${searchUrl}";
% endif
% if streetAddressesSearchUrl:
        options.streetAddressesSearchUrl = "${streetAddressesSearchUrl}";
% endif
% if addressSearchUrl:
        options.addressSearchUrl = "${addressSearchUrl}";
% endif
% if propertySearchUrl:
        options.propertySearchUrl = "${propertySearchUrl}";
% endif


NK.controls = NK.controls || {};
NK.controls.Search = function(options) {
  options = options || {};
  var element, formElem, inputElem,
      inputResultsPerPage, inputResultPageNumber,
      submitBtn, searchFunction;

  goog.object.extend(this, options);

  goog.object.extend(this, {
    searchData: {
      ssr      : null,
      register : null,
      address  : null
    },
    searchRequests : {
        ssr       : null,
        register  : null,
        gbrnr     : null,
        address   : null
    },
    submitBtnId: "searchSubmit",
    searchUrl: '',
    streetAddressesSearchUrl: '',
    addressSearchUrl: '',
    propertySearchUrl: '',
    resultsPerPage: 15,
    markerLayer: null,
    menu : null,
    timer : null,
    searchTimer: null,
    lastPhrase : null,
  });


  element = document.createElement('div');
  element.className = 'searchDiv';

  formElem = document.createElement('form');
  formElem.setAttribute('action', options.searchUrl);

  formElem.onsubmit = function () {return false}; 

  inputElem = document.createElement('input');
  inputElem.setAttribute('name', 'searchInput');
  inputElem.setAttribute('id', 'searchInput');
  inputElem.setAttribute('type', 'search');
  inputElem.setAttribute('autocomplete', 'off');
  inputElem.setAttribute('autocorrect', 'off');
  inputElem.setAttribute('autocapitalize', 'off');
  inputElem.setAttribute('spellcheck', 'false');
  inputElem.setAttribute('placeholder', 'Find place, coordinates, address');
        
  inputResultsPerPage = document.createElement('input');
  inputResultsPerPage.setAttribute('name', 'searchResultsPerPage');
  inputResultsPerPage.setAttribute('id', 'searchResultsPerPageInput');
  inputResultsPerPage.setAttribute('value', options.resultsPerPage);
  inputResultsPerPage.setAttribute('type', 'hidden');

  inputResultPageNumber = document.createElement('input');
  inputResultPageNumber.setAttribute( 'name', 'searchResultsPageNumber' );
  inputResultPageNumber.setAttribute( 'id', 'searchResultsPageNumberInput' );
  inputResultPageNumber.setAttribute( 'value', '0' );
  inputResultPageNumber.setAttribute( 'type', 'hidden' );
        
  submitBtn = document.createElement( 'button' );
  submitBtn.setAttribute( 'type', 'submit' );
  submitBtn.setAttribute( 'id', this.submitBtnId );
  submitBtn.setAttribute('class', 'submit-button');
  submitBtn.innerHTML = '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="439px" height="438px" viewBox="0 0 439 438" class="icon search" preserveAspectRatio="xMidYMid meet"><path d="M432.155,368.606l-2.64-2.639l0.005-0.004l-105.53-105.539c14.662-25.259,23.18-54.54,23.379-85.837C347.985,78.772,270.817,0.612,175.01,0.01c-0.387-0.001-0.761-0.002-1.145-0.002C78.595,0.012,1.045,76.951,0.431,172.366c-0.605,95.81,76.561,173.967,172.359,174.579c0.379,0.002,0.751,0.004,1.133,0.004c31.845,0,61.686-8.627,87.357-23.63l105.439,105.45l0.009-0.01l2.638,2.636c7.973,7.975,20.897,7.967,28.871,0l33.918-33.917C440.124,389.511,440.128,376.578,432.155,368.606z M173.07,302.708c-71.252-0.456-128.852-58.802-128.401-130.059c0.456-70.798,58.414-128.399,129.198-128.403l0.864,0.002c34.518,0.216,66.884,13.863,91.137,38.426c24.251,24.564,37.485,57.105,37.262,91.63c-0.216,34.371-13.767,66.64-38.149,90.859c-24.376,24.212-56.715,37.545-91.058,37.545L173.07,302.708z"/></svg>' + '<span>Search</span>';
        
  formElem.appendChild(inputResultsPerPage);
  formElem.appendChild(inputResultPageNumber);
  formElem.appendChild(inputElem);
  formElem.appendChild(submitBtn);
  element.innerHTML = '';
  element.appendChild(formElem);

  var that = this;

  searchFunction = function(e) {
                var searchInput = $('#searchInput'),
                    resultsList = $('#searchResults'),
                    loadingNotice = $('#searchLoadingNotice'),
                    newValue    = searchInput.val().trim(),
                    searchTimer;

                if ( e.keyCode == 13 ) {
                   return false;
                }
                
                if (newValue.length < 2) {

                   resultsList.remove();
                   if (that.searchTimer) window.clearTimeout(searchTimer);
                   that.abortRequests();

                   var markerLayer = that.getMarkerLayer();
                   if (markerLayer) {
                       markerLayer.removeAllFeatures();
                       markerLayer.setVisibility(false);
                   }
                   return false;
                } else {
                    if (newValue === that.lastPhrase) {
                        // Same phrase as before, ignore key event
                        return false;
                    }
                    if (that.searchTimer) window.clearTimeout(searchTimer);
                    that.lastPhrase = newValue;
                }
                if ( resultsList.length === 0 ) {
                    resultsList = $( '<div/>', { 'id': 'searchResults', html : options.closeButtonHtml});
                    $('.searchDiv').after(resultsList);
                }

                resultsList.html(options.closeButtonHtml);
                if (loadingNotice.length === 0) {
                    loadingNotice = $('<div/>', {'id':'searchLoadingNotice', html: 'Searching...'});
                }
                resultsList.append(loadingNotice);
                resultsList.show();

                $('#searchResults a.close').on( "click", function(e){
                    $('#searchResults').remove();
                    if (that.searchTimer) window.clearTimeout(searchTimer);
                    that.abortRequests();
                    return false; 
                });

                that.searchTimer = setTimeout(function() {
                    // launch with delay
                    if ( that.lastPhrase == $('#searchInput').val() ) {
                        if (NK.functions && NK.functions.updateHistory) {
                            NK.functions.updateHistory();
                        }
                        $('#searchResultsPageNumberInput').val(0);
                        that.doSearch();
                    }
                }, 1000);
  };
          
  $(document).on("keyup",  '#searchInput', searchFunction); 
  $(document).on("search", '#searchInput', searchFunction); 
          
  $(document).on("click", '.search-place', function(){
            var center = [$(this).data("east"), $(this).data("north")]; 
            ol.proj.transform(center, 'EPSG:4326', map.getView().getProjection());
            
            var zoom, dzoom;
            dzoom = $(this).data("zoom");
            if ( dzoom > map.getZoom() ) {
                zoom = dzoom;
            } else {
                zoom = map.getZoom();
            }
            if ($(this).parent().parent().hasClass('addresses')) zoom = 15;
            
            map.setCenter(center, zoom );
            $('#searchResults').remove();
  });  

  $(element).click(this, this.onClick);
 
  ol.control.Control.call(this, {
    element: element,
    target: options.target
  });

}
ol.inherits(NK.controls.Search, ol.control.Control);

NK.controls.Search.prototype.doSearch = function (phraseParameter, page, pageLength) {

        // returning test data
        var phrase = phraseParameter || $('#searchInput').val(),
            resultsPageNumber = page || $('#searchResultsPageNumberInput').val(),
            resultsPerPage = pageLength ||$('#searchResultsPerPageInput').val(),
            params,
            self = this;

        phrase = phrase.trim(phrase);
        self.lastPhrase = phrase;

        /*
            Parallel register search for addresses
        */
        var registerSearch = {            
            url: this.streetAddressesSearchUrl,
            run: function(params, search){

                search.searchData.register = null;

                var request,
                    requestParams = encodeURIComponent(params.phrase);

                $.support.cors = true;

                request = $.ajax({
                    url: this.url,
                    data: requestParams,
                    dataType: 'JSON',
                    crossDomain: true
                });

                request.done(function(data){
                    search.searchData.register = data;
                    if (search.searchData.ssr !== null) {
                        search.drawResponse();
                    }
                });

                request.fail(function(xhr, status, exc){
                    search.searchData.register = null;
                    //console.log('Request failed: ' + status + ', ' + exc);
                });

                if (self.searchRequests.register !== null) {
                    self.searchRequests.register.abort();
                }
                self.searchRequests.register = request;
            }
        };
        var searchAddress = {
            url: this.addressSearchUrl,
            run: function(params, search){
                search.searchData.address = null;

                var request,
                    requestParams = encodeURIComponent(params.phrase);

                $.support.cors = true;

                request = $.ajax({
                    url: that.addressSearchUrl,
                    data: requestParams,
                    dataType: 'JSON',
                    crossDomain: true
                });

                request.done(function(data){
                    search.searchData.address = data;
                    if (search.searchData.ssr !== null) {
                        search.drawResponse();
                    }
                });

                request.fail(function(xhr, status, exc){
                    search.searchData.address = null;
                    //console.log('Request failed: ' + status + ', ' + exc);
                });

                if (self.searchRequests.address !== null) {
                    self.searchRequests.address.abort();
                }
                self.searchRequests.address = request;

            }// run
        };
        var searchEngine = {
            url: this.searchUrl,
            paramNames: {
                name: 'navn',
                fylkeKommuneListe: 'fylkeKommuneListe',
                maxResult: 'antPerSide',
                northLL: 'nordLL',
                eastLL: 'ostLL',
                northUR: 'nordUR',
                eastUR: 'ostUR',
                exactMatchesFirst: 'eksaktForst',
                page: 'side'
            },
        
            run: function (params, search) {

                search.searchData.ssr = null;

                var request,
                    requestParams = {};

                requestParams[this.paramNames.name] = params.phrase;
                requestParams[this.paramNames.exactMatchesFirst] = true;
                requestParams[this.paramNames.maxResult] = params.resultsPerPage;
                requestParams['epsgKode'] = '4326';
                requestParams[this.paramNames.page] = params.resultsPageNumber;

                $.support.cors = true;

                request = $.ajax({
                    url: this.url,
                    data: requestParams,
                    dataType: 'xml',
                    crossDomain: true
                }); // request

                request.done(function(data){
                    search.searchData.ssr = data;
                    if (search.searchData.register !== null) {
                        search.drawResponse();
                    }
                    //search.drawResponse(data);
                });// done

                request.fail(function(xhr, status, exc) {
                    search.searchData.ssr = null;
                    // console.log( "Request failed: " + status + ', ' + exc);
                });// fail

                if (self.searchRequests.ssr !== null) {
                    self.searchRequests.ssr.abort();
                }
                self.searchRequests.ssr = request;

            } // run
        }; // searchEngine
        var that = this;
        var gbrnrSearchEngine = {
            url: this.propertySearchUrl,

            run: function (params, search) {

                var request,
                    query = '';

                query += params.municipality + '-' + params.numbers.join('/');
                $.support.cors = true;

                that.lastParams = params;

                request = $.ajax({
                    url: this.url + '?' + encodeURIComponent(query),
                    crossDomain: true
                }); // request

                request.done(function(response){
                    var parsedResponse = $.parseJSON(response);
                    var place, key, keys, k, i, j;
                    if (parsedResponse && parsedResponse.length > 0) {
                      var places = [];
                      for (i = 0; i < parsedResponse.length; i++) {
                        var r = parsedResponse[i];
                        if (!r['LONGITUDE']) {
                          that.displaySearchNotice('Search results contain properties without known borders. We cannot display these, but you can repeat your search on <a href="http://www.seeiendom.no" target="_blank" style="color:#fff">seeiendom.no</a> to retrieve more information.');
                          continue; // TODO: Error message - property has no known geometries 
                        }
                        var point = [parseFloat(r['LONGITUDE']), parseFloat(r['LATITUDE'])];
                        ol.proj.transform(point, "EPSG:32632", "EPSG:4326");
                        var p = that.lastParams.numbers;
                        place = {
                            name: r['NAVN'],
                            address: r['VEGADRESSE'],
                            type: r['OBJEKTTYPE'],
                            municipality: r['KOMMUNENAVN'],
                            county: r['FYLKESNAVN'],
                            north: point.lat,
                            east: point.lon
                        };
                        places.push(place);
                        if (parsedResponse && (parsedResponse.length == 1)) {
                          ol.proj.transform(point,"EPSG:4326", map.getView().getProjection());
                          map.setCenter(point);
                        }
                      }
                      that.addMarkers(places);
                    }
                });// done

                request.fail(function(xhr, status, exc) {
                    // console.log( "Request failed: " + status + ', ' + exc);
                });// fail

                if (self.searchRequests.gbrnr !== null) {
                    self.searchRequests.gbrnr.abort();
                }
                self.searchRequests.gbrnr = request;

            } // run
        }; // searchEngine

        params = this.parseInput(phrase);

        if (params) {
            if (typeof params.phrase === 'string') {
                
                registerSearch.run(params, this);

                searchAddress.run(params, this);

                params.phrase = params.phrase + '*';
                params.resultsPageNumber = resultsPageNumber;
                params.resultsPerPage = resultsPerPage;
                
                searchEngine.run(params, this);

            } else if (params.north || params.x) {

                var inputEPSG = params.projectionHint || "4326",
                    inputName = "WGS84/Geografisk grader";

                if (params.north) {
                    var center = [params.east, params.north];          
                    var fromProj = proj[inputEPSG];
                } else {
                    var center = [params.x, params.y];
                    var inputProj = $.localStorage.get("inputCRS") || "23";
                    var inputEPSG = params.projectionHint || this.trf().getEPSGfromSOSI(inputProj);
                    if (!this.trf().isViewable(inputEPSG)) {
                      var inputProj = "23";
                      var inputEPSG = this.trf().getEPSGfromSOSI(inputProj);
                    }
                    if (!params.projectionHint) {
                      var searchInput = $('#searchInput');
                      var caretPos    = searchInput.caret();
                      searchInput.val(searchInput.val().split("@")[0] + "@" + inputEPSG);
                      searchInput.caret(caretPos);
                    }
                    var fromProj = proj[inputEPSG];
                    var pointToNorthEast = [params.x, params.y];
                    pointToNorthEast.transform(fromProj, proj["4326"]);
                    params.north = pointToNorthEast.lat;
                    params.east = pointToNorthEast.lon;
                }
                var inputName = this.trf().getCRSName(inputEPSG);
                var toProj   = map.getView().getProjection();
                center.transform(fromProj, toProj);
                this.map.setCenter(center);
                this.addMarkers([params]);

                if (inputEPSG != "4326") {
                  var coordinateSystemSelector = this.trf().generateCoordinateSystemsList('coordinate-system-selector', 'Coordinate system:', inputProj, true);
                  coordinateSystemSelector.select.setAttribute('onchange', "NK.util.getControlsByClass('NK.contros.Search')[0].changeProjection(this)");


                  var noticeElement = this.displaySearchNotice('Koordinatene tolkes som <a href="http://epsg.io/' + inputEPSG + '" target="_blank" style="color:#fff">' + inputName + '</a>.<br />Bytt projeksjon til ');

                  noticeElement.appendChild(coordinateSystemSelector.select); // huh, shouldn't there be a direct way to do this?
                }
            } else if (params.gnr) {
                this.displaySearchNotice('Search for properties as follows:<br/>Municipality-Gardsnr/Bruksnr/Feste/Seksjon<br/>e.g.: <b>Ringerike-38/98</b></br/> or by entering an address.');
                gbrnrSearchEngine.run(params, this);
            }
        } 
};

NK.controls.Search.prototype.parseInput = function (input) {
        var parsedInput = {},
            reResult,
            decimalPairComma,
            decimalPairDot,
            decimalCoordinatesNE,
            degMinNE,
            degMinEN,
            degMinSecNE,
            degMinSecEN,
            degMinSecEN2,
            gbrnr, gbrnr2, gbrnr3, gbrnr4, gbrnr5;

        // matches two numbers using either . or , as decimal mark. Numbers using . as decimal mark are separated by , or , plus blankspace. Numbers using , as decimal mark are separated by blankspace
        decimalPairComma = /^[ \t]*([0-9]+,[0-9]+|[0-9]+)[ \t]+([0-9]+,[0-9]+|[0-9]+)(?:@([0-9]+))?[ \t]*$/;
        decimalPairDot   = /^[ \t]*([0-9]+\.[0-9]+|[0-9]+)(?:[ \t]+,|,)[ \t]*([0-9]+\.[0-9]+|[0-9]+)(?:@([0-9]+))?[ \t]*$/; 
        decimalCoordinatesNE = /^[ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*[°]?[ \t]*[nN][ \t]*,?[ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*[°]?[ \t]*[eEøØoO][ \t]*$/;
        degMinNE = /^[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*[nN]?[ \t]*,?[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*[eEoOøØ]?[ \t]*?/;
        degMinEN = /^[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*[eEoOøØ][ \t]*,?[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*[nN][ \t]*?/;
        degMinSecNE = /^[ \t]*[nN]?[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*[nN]?[ \t]*,?[ \t]*[eEøØoO]?[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*[eEoOøØ]?[ \t]*?/;
        degMinSecEN = /^[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*[eEøØoO][ \t]*,?[ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*[nN][ \t]*?/;
        degMinSecEN2 = /^[ \t]*[eEøØoO][ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*,?[ \t]*[nN][ \t]*([0-9]+)[ \t]*[°][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*['′][ \t]*([0-9]+[,\.][0-9]+|[0-9]+)[ \t]*(?:"||''||′′)[ \t]*?/;
        gbrnr = /^[ \t]*([A-Za-zæøåÆØÅ ]+[A-Za-zæøåÆØÅ]|[\d]+)[ \t]*[-/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*$/;
        gbrnr2 = /^[ \t]*([A-Za-zæøåÆØÅ ]+[A-Za-zæøåÆØÅ]|[\d]+)[ \t]*[-/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*$/;
        gbrnr3 = /^[ \t]*([A-Za-zæøåÆØÅ ]+[A-Za-zæøåÆØÅ]|[\d]+)[ \t]*[-/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*$/;
        gbrnr4 = /^[ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*[ \t]*[,]([A-Za-zæøåÆØÅ ]*)$/;
        gbrnr5 = /^[ \t]*([\d]+)[ \t]*[/][ \t]*([\d]+)[ \t]*[ \t]*$/;

        var interpretAsNorthEastOrXY = function (obj) {
            if (obj && typeof obj.first === 'number' && typeof obj.second === 'number') {
                if (obj.first <= 180 && obj.first >= -180 && obj.second <= 180 && obj.second >= -180) {
                    obj.north = obj.first;
                    delete obj.first;

                    obj.east = obj.second;
                    delete obj.second;
                } else {
                    obj.x = obj.first;
                    delete obj.first;

                    obj.y = obj.second;
                    delete obj.second;
                }
            }
            return obj;
        };

        if (typeof input === 'string') {
            if (decimalPairComma.test(input)) {
                reResult = decimalPairComma.exec(input);
                parsedInput.first = parseFloat(reResult[1]);
                parsedInput.second = parseFloat(reResult[2]);
                if (!!reResult[3]) {
                  parsedInput.projectionHint = parseInt(reResult[3]);
                }
                interpretAsNorthEastOrXY(parsedInput);

            } else if (decimalPairDot.test(input)) {
                reResult = decimalPairDot.exec(input);
                parsedInput.first = parseFloat(reResult[1]);
                parsedInput.second = parseFloat(reResult[2]);
                if (!!reResult[3]) {
                  parsedInput.projectionHint = parseInt(reResult[3]);
                }
                interpretAsNorthEastOrXY(parsedInput);

            } else if (decimalCoordinatesNE.test(input)) {
                reResult = decimalCoordinatesNE.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.north.deg = parseFloat(reResult[1]);
                parsedInput.east.deg = parseFloat(reResult[2]);
            } else if (degMinNE.test(input)) {
                reResult = degMinNE.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.north.deg = parseFloat(reResult[1]);
                parsedInput.north.min = parseFloat(reResult[2]);
                parsedInput.east.deg = parseFloat(reResult[3]);
                parsedInput.east.min = parseFloat(reResult[4]);
            } else if (degMinEN.test(input)) {
                reResult = degMinEN.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.east.deg = parseFloat(reResult[1]);
                parsedInput.east.min = parseFloat(reResult[2]);
                parsedInput.north.deg = parseFloat(reResult[3]);
                parsedInput.north.min = parseFloat(reResult[4]);
            } else if (degMinSecNE.test(input)) {
                reResult = degMinSecNE.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.north.deg = parseFloat(reResult[1]);
                parsedInput.north.min = parseFloat(reResult[2]);
                parsedInput.north.sec = parseFloat(reResult[3]);
                parsedInput.east.deg = parseFloat(reResult[4]);
                parsedInput.east.min = parseFloat(reResult[5]);
                parsedInput.east.sec = parseFloat(reResult[6]);
            } else if (degMinSecEN.test(input)) {
                reResult = degMinSecEN.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.east.deg = parseFloat(reResult[1]);
                parsedInput.east.min = parseFloat(reResult[2]);
                parsedInput.east.sec = parseFloat(reResult[3]);
                parsedInput.north.deg = parseFloat(reResult[4]);
                parsedInput.north.min = parseFloat(reResult[5]);
                parsedInput.north.sec = parseFloat(reResult[6]);
            } else if (degMinSecEN2.test(input)) {
                reResult = degMinSecEN2.exec(input);
                parsedInput.north = {};
                parsedInput.east = {};
                parsedInput.east.deg = parseFloat(reResult[1]);
                parsedInput.east.min = parseFloat(reResult[2]);
                parsedInput.east.sec = parseFloat(reResult[3]);
                parsedInput.north.deg = parseFloat(reResult[4]);
                parsedInput.north.min = parseFloat(reResult[5]);
                parsedInput.north.sec = parseFloat(reResult[6]);
            } else  if (gbrnr.test(input)) {
                reResult = gbrnr.exec(input);
                parsedInput.municipality = reResult[1].trim();
                parsedInput.gnr = reResult[2];
                parsedInput.bnr = reResult[3];
                parsedInput.numbers = [parsedInput.gnr, parsedInput.bnr];
            } else  if (gbrnr2.test(input)) {
                reResult = gbrnr2.exec(input);
                parsedInput.municipality = reResult[1].trim();
                parsedInput.gnr = reResult[2];
                parsedInput.bnr = reResult[3];
                parsedInput.fnr = reResult[4];
                parsedInput.numbers = [parsedInput.gnr, parsedInput.bnr, parsedInput.fnr];
            } else  if (gbrnr3.test(input)) {
                reResult = gbrnr3.exec(input);
                parsedInput.municipality = reResult[1].trim();
                parsedInput.gnr = reResult[2];
                parsedInput.bnr = reResult[3];
                parsedInput.fnr = reResult[4];
                parsedInput.snr = reResult[5];
                parsedInput.numbers = [parsedInput.gnr, parsedInput.bnr, parsedInput.fnr]; // snr confuses search engine not to output coordinates
            } else  if (gbrnr4.test(input)) {
              reResult = gbrnr4.exec(input);
              parsedInput.gnr = reResult[1];
              parsedInput.bnr = reResult[2];
              parsedInput.municipality = reResult[3].trim();
              parsedInput.numbers = [parsedInput.gnr, parsedInput.bnr];
            } else  if (gbrnr5.test(input)) {
              reResult = gbrnr5.exec(input);
              parsedInput.gnr = reResult[1];
              parsedInput.bnr = reResult[2];
              parsedInput.municipality = '';
              parsedInput.numbers = [parsedInput.gnr, parsedInput.bnr];
            } else {
                parsedInput.phrase = input;
            }
            var degMinSec2Deg = function (dms) {
                if (typeof dms.sec === 'number') {
                    dms.min += dms.sec / 60;
                    delete dms.sec;
                }
                if (typeof dms.min === 'number') {
                    dms.deg += dms.min / 60;
                    delete dms.min;
                }
            };
            if (parsedInput.north) {
                degMinSec2Deg(parsedInput.north);
                if (typeof parsedInput.north.deg === 'number') {
                    parsedInput.north = parsedInput.north.deg;
                }
            }
            if (parsedInput.east) {
                degMinSec2Deg(parsedInput.east);
                if (typeof parsedInput.east.deg === 'number') {
                    parsedInput.east = parsedInput.east.deg;
                }
            }
            return parsedInput;
        }
        return null;
};   

NK.controls.Search.prototype.onClick = function (event) {
        
        /*
            Start bugfix: 43616-162
        */
        var targ, e = event;
        var that = event.data;
        if (e) {
            if (e.target) {
                targ = e.target;
            } else if (e.srcElement) {
                targ = e.srcElement;
            }
            if (targ.nodeType == 3) targ = targ.parentNode; // Safari quirk
        }
        if (targ.nodeName.toLowerCase() === 'select' || 
            targ.nodeName.toLowerCase() === 'option') {
            e.stopPropagation ? e.stopPropagation() : e.cancelBubble = true;
            return false;
        }
        /*
            End bugfix: 43616-162
        */

        if ((!!event.target && (event.target.id === this.submitBtnId || $(event.target).parents('#' + this.submitBtnId).length > 0)) || event.srcElement === this.submitBtnId) {
            that.doSearch();
            return false;
        }
}

goog.object.extend(options, {
  target: container,
});
NK.functions.addControlToContext(new NK.controls.Search(options), context);

