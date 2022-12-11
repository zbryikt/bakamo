window.BarcodeDetector = barcodeDetectorPolyfill.BarcodeDetectorPolyfill;
ldc.register(['viewlocals', 'core', 'navtop'], function(arg$){
  var viewlocals, navtop, core;
  viewlocals = arg$.viewlocals, navtop = arg$.navtop, core = arg$.core;
  return core.init().then(function(){
    if (!core.global.production) {
      return console.log("[viewlocals]: ", viewlocals);
    }
  });
});