# isbn_13 support isn't ready in some browser even if they support BarcodeDetector.
# thus, we always use polyfill.
window.BarcodeDetector = barcodeDetectorPolyfill.BarcodeDetectorPolyfill

ldc.register \corecfg, <[locales]>, ({locales}) -> ->
  #auth: authpanel: {ns: \local, name: \authpanel}
  manager: new block.manager registry: ({ns, url, name, version, path, type}) ~>
    if url => return that
    # normalize options
    dec = "?dec=#{@global.version or ''}"
    path = path or if type == \block => \index.html
    else if type => "index.min.#type" else 'index.min.js'
    version = version or \main
    if ns == \chart or name == \base => return "/assets/chart/#name/0.0.1/#path"
    if ns == \local =>
      return if name in <[error cover]> => "/modules/#name/#path#dec"
      else "/modules/block/#name/#path#dec"
    # fallback
    version = \main
    return "/assets/lib/#name/#version/#path#dec"

({viewlocals, navtop, core}) <- ldc.register <[viewlocals core navtop]>, _
<- core.init!then _
# for debugging
if !core.global.production => console.log "[viewlocals]: ", viewlocals
