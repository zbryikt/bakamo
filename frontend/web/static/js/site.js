window.BarcodeDetector = barcodeDetectorPolyfill.BarcodeDetectorPolyfill;
ldc.register('corecfg', ['locales'], function(arg$){
  var locales;
  locales = arg$.locales;
  return function(){
    var this$ = this;
    return {
      manager: new block.manager({
        registry: function(arg$){
          var ns, url, name, version, path, type, that, dec;
          ns = arg$.ns, url = arg$.url, name = arg$.name, version = arg$.version, path = arg$.path, type = arg$.type;
          if (that = url) {
            return that;
          }
          dec = "?dec=" + (this$.global.version || '');
          path = path || (type === 'block'
            ? 'index.html'
            : type ? "index.min." + type : 'index.min.js');
          version = version || 'main';
          if (ns === 'chart' || name === 'base') {
            return "/assets/chart/" + name + "/0.0.1/" + path;
          }
          if (ns === 'local') {
            return name === 'error' || name === 'cover'
              ? "/modules/" + name + "/" + path + dec
              : "/modules/block/" + name + "/" + path + dec;
          }
          version = 'main';
          return "/assets/lib/" + name + "/" + version + "/" + path + dec;
        }
      })
    };
  };
});
ldc.register(['viewlocals', 'core', 'navtop'], function(arg$){
  var viewlocals, navtop, core;
  viewlocals = arg$.viewlocals, navtop = arg$.navtop, core = arg$.core;
  return core.init().then(function(){
    if (!core.global.production) {
      return console.log("[viewlocals]: ", viewlocals);
    }
  });
});