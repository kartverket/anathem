NK.util = NK.util || {};

NK.util.getLayersBy = function(key, value) {
  return $.grep(map.getLayers().getArray(), function(l) {
    return l.get(key) == value;
  })
}
