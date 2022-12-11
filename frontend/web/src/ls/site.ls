# isbn_13 support isn't ready in some browser even if they support BarcodeDetector.
# thus, we always use polyfill.
window.BarcodeDetector = barcodeDetectorPolyfill.BarcodeDetectorPolyfill

({viewlocals, navtop, core}) <- ldc.register <[viewlocals core navtop]>, _
<- core.init!then _
# for debugging
if !core.global.production => console.log "[viewlocals]: ", viewlocals
