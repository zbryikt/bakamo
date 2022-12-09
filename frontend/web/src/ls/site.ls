if !window.BarcodeDetector? => window.BarcodeDetector = barcodeDetectorPolyfill.BarcodeDetectorPolyfill
#window.BarcodeDetector2 = barcodeDetectorPolyfill.BarcodeDetectorPolyfill

({viewlocals, navtop, core}) <- ldc.register <[viewlocals core navtop]>, _
<- core.init!then _
# for debugging
if !core.global.production => console.log "[viewlocals]: ", viewlocals
