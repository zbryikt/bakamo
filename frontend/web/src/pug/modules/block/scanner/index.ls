module.exports =
  interface: ->
    get: ~>
      @itf.start!
      @ldcv.get!
    set: (v) ~>
      @itf.stop!
      @ldcv.set v
  init: ({root}) ->
    bd = new BarcodeDetector!
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
      action: click: get: ({node}) ~>
        @itf.stop!
        @ldcv.set @value
      handler: info: ({node}) ~> node.classList.toggle \d-none, !(@value)
    video = view.get \video

    @time = {_fps_delay: 200}

    @itf =
      stop: ~>
        <~ Promise.resolve!then _
        @running = false
        if !@mediastream => return
        if !(tracks = @mediastream.getTracks!) => return
        for i from 0 til tracks.length => tracks[i].stop!
      start: ~>
        <~ @itf.stop!then _
        @running = true
        <~ @itf.prepare!then _
        requestAnimationFrame (t) ~> @itf.handler t, true

      handler: (t, force = false) ~>
        if !@running => return
        @time.now = t
        delay = if @time.is-throttled => (@time._fps_delay >? 1000) else @time._fps_delay
        if force or (@time.now - @time.last) >= delay =>
          @time.last = t
          @itf.render!
        requestAnimationFrame (t) ~> @itf.handler t, false

      render: ~>
        if !@running => return
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
        #setTimeout (~> requestAnimationFrame (~> @itf.render!)), 200

      prepare: ->
        navigator.mediaDevices.getUserMedia {video: facingMode: \environment}
          .then (ms) ~> 
            @mediastream = ms
            (res, rej) <~ new Promise _
            video.addEventListener \loadedmetadata, -> if video.readyState == 4 => res!
            video.srcObject = ms
            video.autoplay = true
      prepare-mobile: ->
        # https://stackoverflow.com/questions/64553141/
        # facingMode constraint is incompletely implemented, especially in mobile devices.
        # some hairball workaround
        navigator.mediaDevices.getUserMedia {video: true}
          .then (tms) ->
            (devices) <- navigator.mediaDevices.enumerateDevices!then _
            id = {}
            if devices.length > 0 => id.front = id.back = devices.0.device-id
            Array.from(devices).for-each (device) ->
              if device.kind != \videoinput or !device.label => return
              if /後置|back/.exec(device.label.toLowerCase!) => id.back = device.device-id
              if /前置|front/.exec(device.label.toLowerCase!) => id.front = device.device-id
            if (tracks = tms.getTracks!) => for i from 0 til tracks.length => tracks[i].stop!
            navigator.mediaDevices.getUserMedia video: true, deviceId: exact: id.back
          .then (ms) ~>
            @mediastream = ms
            (res, rej) <~ new Promise _
            video.addEventListener \loadedmetadata, -> if video.readyState == 4 => res!
            video.srcObject = ms
            video.autoplay = true
