<%include file="/3/styles/wfs.mako" />

% if not 'styles.dekning.historisk' in vars:  
NK.styles = NK.styles || {};
NK.styles.dekning = NK.styles.dekning || {};
NK.styles.dekning.historisk = NK.styles.dekning.historisk || NK.styles.wfs;

NK.styles.dekning.historisk.popupBuilder = function(object) { 
  var id      = object.RuteID;
  var serie   = id.split("_")[0];
  var link100 = 'http://www.kartverket.no/historiske/'+serie+'/jpg100dpi/'+id+'.jpg';
  var link300 = 'http://www.kartverket.no/historiske/'+serie+'/jpg300dpi/'+id+'.jpg';
  var link_tn = 'http://www.kartverket.no/historiske/'+serie+'/216px/'+id+'.jpg';


  var str='<table>';
  str += '<tr><td colspan=2><img src="'+link_tn+'"></td></tr>';
  str += '<tr><td>Kartserie:</td><td>'+serie+'</td></tr>';
  str += '<tr><td>Last ned:</td><td><a href="'+link100+'">100dpi (webkvalitet)</a><br/><a href="'+link300+'">300dpi (trykkkvalitet)</a></td></tr>';
  str += '</tr></table>';
  return str;
};

<% vars['styles.dekning.historisk']=True %>
% endif
