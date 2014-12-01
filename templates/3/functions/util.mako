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
