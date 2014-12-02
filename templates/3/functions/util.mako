NK.util = NK.util || {};

NK.util.getLayersBy = function(key, value) {
  return $.grep(map.getLayers().getArray(), function(l) {
    return l.get(key) == value;
  })
};

NK.util.getControlsByClass = function(cla) {
  return $.grep(map.getControls().getArray(), function(c) {
    return c instanceof cla;
  });
};

NK.util.createWidget = function( content, wCount, arrow ) {
    var widget = document.createElement('div'); 
    $(widget).addClass('widget');
    
    var wrapper = widget, count = ! wCount || isNaN(wCount) ? 0 : wCount;

    while (count-- > 0) {
		var w = document.createElement('div');    
		$(w).addClass('wrapper');
		wrapper.appendChild(w);
		wrapper = w;
    }
    
    var cnt = content || document.createElement('div');    

    if (!content) {
    	$(cnt).addClass('widgetCnt');    
    }

    wrapper.appendChild(cnt); 

    if (arrow) {
		var arrow1 = document.createElement('div');
		$(arrow1).addClass('arrow');

		var arrow2 = document.createElement('div');
		$(arrow2).addClass('arrow');
		arrow1.appendChild(arrow2); 
		
		wrapper.appendChild(arrow1);
    }
    return widget;
};
