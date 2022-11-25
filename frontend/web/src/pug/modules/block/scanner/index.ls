module.exports =
  interface: -> @ldcv
  init: ({root}) ->
    bd = new BarcodeDetector format: <[code_39]>
    @ldcv = new ldcover root: root
    @cache = {}
    @info = {}
    view = new ldview do
      root: root
      text:
        isbn: ({node}) ~>
          ret = (@info or {}).isbn or ''
          return if !ret => ret else "ISBN: #ret"
        title: ({node}) ~> ((@info or {}).title or @value or '')
      action: click: get: ({node}) ~> @ldcv.set @value
      handler: info: ({node}) ~> node.classList.toggle \d-none, !(@value)

    video = view.get \video
    render = ~>
      bd.detect video .then (codes) ~>
        codes.for-each (code) ~> @value = code.rawValue
        if @value and /^\d+$/.exec("#{@value}") =>
          Promise.resolve!
            .then ~>
              if @cache[@value] => return @cache[@value]
              ((v) ~>
                return @cache[v] = Promise.resolve!then ~>
                  (ret = {}) <~ ld$.fetch("/api/code/#v", {method: \GET}, {type: \json}) .then _
                  @cache[v] = info = if !(o = ret.[]items.0) => {} else {title: o.volumeInfo.title, isbn: v}
                  if v != @value => return lderror.reject 999
                  return info
              )(@value)
            .then (info) ~>
              @info = info
              view.render <[isbn info title]>
            .catch (e) -> if lderror.id(e) == 999 => return else return Promise.reject e
        view.render <[isbn info title]>
      requestAnimationFrame render

    navigator.mediaDevices.getUserMedia {video: facingMode: \environment}
      .then (ms) -> 
        video.srcObject = ms
        video.autoplay = true
        setTimeout (-> render! ), 1000

