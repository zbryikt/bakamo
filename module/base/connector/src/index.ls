connector = (opt = {}) ->
  @ <<< ws: null, _running: false, _tag: "[@servebase/connector]"
  @_init = opt.init
  @_ldcv = opt.ldcv or (->)
  @_reconnect = opt.reconnect
  @_path = opt.path or \/ws
  @hub = {}
  @

connector.prototype = Object.create(Object.prototype) <<<
  open: ->
    console.log "#{@_tag} ws reconnect ..."
    @ws.connect!
      .then ~> console.log "#{@_tag} object reconnect ..."
      .then ~> if @_reconnect => @_reconnect!
      .then ~> console.log "#{@_tag} connected."
      .catch (e) ~>
        # this may be caused by customized reconnect, which contains initialization code.
        # we should stop and hint user otherwise it may lead to unexpected result.
        # original code, which ignore error if ws connected: /* if @ws.status! == 2 => return */
        Promise.reject e
  reopen: ->
    if @_running => return
    @_running = true
    if @_ldcv.toggle => @_ldcv.toggle(true) else @_ldcv(true)
    debounce 1000
      .then ~> @open!
      .then -> debounce 350
      .then ~> if @_ldcv.toggle => @_ldcv.toggle(false) else @_ldcv(false)
      .then ~> @_running = false
  init: ->
    @ws = new ews {path: @_path}
    @ws.on \close, ~> @reopen!
    if @_init => @_init!
    @open!


if module? => module.connector = connector
else if window? => window.connector = connector
