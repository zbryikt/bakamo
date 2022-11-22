provider = (o = {}) -> @ <<< o
provider.prototype = Object.create(Object.prototype) <<<
  create: (o = {}) -> new @factory o
  cfg: (o) -> if o? => @{}_cfg <<< o else (@_cfg or {})

captcha =
  _p: {} # providers
  _order: null
  cfg: {}
  zmgr: -> @_zmgr = it
  init: (o={}) ->
    @cfg = o.cfg
    @_zmgr = o.zmgr
    for k,v of @_p => v.cfg({} <<< @cfg[k])
  register: (n, o = {}) ->
    @_p[n] = p = new provider o
    itf = p.interface or {}
    p.factory = f = (o={}) ->
      @opt = o
      @init = proxise.once -> @_provider.init!then ~> @_init!
      @
    f.prototype = {_provider: p} <<< Object.create(Object.prototype) <<< itf <<<
      priority: 99
      _init: itf.init
  get: (n) -> return @_p[n]
  order: (ns = []) ->
    list = [[k,v] for k,v of @_p]
    list.sort (a,b) -> (a.1.priority or 99) - (b.1.priority or 99)
    list = list.map -> it.0
    @_order = ns.filter(-> it in list) ++ list.filter(->!(it in ns))
    @_order = @_order.filter ~> @cfg[it] and @cfg[it].enabled and @cfg[it].sitekey
  guard: (opt = {}) ->
    if !@_order => @order!
    if !@_order.length => return Promise.resolve!then -> opt.cb {captcha: {}}
    _ = (idx = 0) ~>
      if idx >= @_order.length => return lderror.reject 1010
      @verify({name: @_order[idx]} <<< opt)
        .then (ret) -> opt.cb ret
        .catch (e) ->
          if lderror.id(e) in [1009 1010] => debounce(1000).then -> _ idx + 1
          else return Promise.reject e
    Promise.resolve!
      .then ~> @ldld.on!
      .then ~> _!
      .finally ~> @ldld.off!

  prepare: ->
    @root = it
    @ldld = new ldloader className: 'ldld full', auto-z: true, base-z: null, zmgr: @_zmgr
  verify: ({name}) ->
    provider = @get(name)
    if !@{}obj[name] =>
      if provider.headless =>
        p = Promise.resolve!
        ldcv = null
      else
        node = @root.querySelector('.ldcv').cloneNode(true)
        root = node.querySelector('[ld=box]')
        @root.appendChild node
        ldcv = new ldcover root: node, zmgr: @_zmgr
        p = ldcv.get!

      @obj[name] =
        obj: @get(name).create {root}
        ldcv: ldcv
        provider: provider
    else 
      if @obj[name].provider.headless => p = Promise.resolve!
      else p = @obj[name].ldcv.get!
    @obj[name].obj.init!
      .then ~> @obj[name].obj.render!
      .then -> p
      .then ~>
        lc = {}
        ret = @obj[name].obj.get!then ->
          lc.done = it
          if lc.deb => lc.deb.now!
          lc.done
        if provider.headless => return ret
        lc.deb = debounce(5000, ->)!
        lc.deb
          .then ->
            lc.deb = null
            return if lc.done => that else lderror.reject 1006
          .catch -> return Promise.reject it
      .catch (e) ->
        console.log e
        return {}

  examine: ->
    root = @root
    v = new ldview do
      root: root
      action: click: ok: ~>
        capobj.get!then ~>
          console.log \result, it
          @ldcv.toggle false
    inner = root.querySelector('[ld=box]')
    @ldcv = new ldcover root: root.querySelector('.ldcv'), zmgr: @_zmgr
    @ldcv.toggle!
    capobj = captcha.get \recaptcha_v2_checkbox .create {root: inner}
    capobj = capobj
    capobj.init!
      .then ->
        capobj.render!
        console.log "capobj inited"

captcha.register \hcaptcha, do
  priority: 3
  init: proxise.once ->
    (res, rej) <~ new Promise _
    @_script = s = document.createElement \script
    s.onerror = ~> rej it
    s.onload = ~>
      @inited = true
      res!
    s.setAttribute \type, \text/javascript
    s.setAttribute \src, "https://js.hcaptcha.com/1/api.js?recaptchacompat=off"
    document.body.appendChild s
  interface:
    init: ->
      @root = if typeof(@opt.root) == \string => document.querySelector(@opt.root) else @opt.root
      @_tag = document.createElement \div
      @root.appendChild @_tag
    reset: -> hcaptcha.reset @id
    render: ->
      if !(@id?) => @id = hcaptcha.render @_tag, @_provider.cfg!{theme, size, sitekey}
      else @reset!
    get: ->
      p = if (ret = hcaptcha.getResponse @id) => Promise.resolve ret
      else
        @render!
        hcaptcha.execute @id, async: true
          .then ({response, key}) ~> response
      p.then -> {token: it, name: \hcaptcha}

captcha.register \recaptcha_v3, do
  priority: 1
  headless: true
  init: proxise.once ->
    Promise.resolve!then ~> 
      (res, rej) <~ new Promise _
      @_script = s = document.createElement("script")
      s.onerror = ~> rej it
      s.onload = ~> grecaptcha.ready ~> res @inited = true
      s.setAttribute \type, \text/javascript
      s.setAttribute \src, "https://www.google.com/recaptcha/api.js?render=#{@_cfg.sitekey}"
      document.body.appendChild s
  interface:
    init: ->
    get: ->
      cfg = @_provider.cfg!
      if !(cfg.sitekey and cfg.enabled) => return lderror.reject 998
      grecaptcha.execute cfg.sitekey, {action: 'generic'} # TODO: action
        .then (token) -> return {token, name: \recaptcha_v3}
    reset: ->
    render: ->

captcha.register \recaptcha_v2_checkbox, do
  priority: 2
  init: proxise.once ->
    (res, rej) <~ new Promise _
    @_script = s = document.createElement("script")
    s.onerror = ~> rej it
    s.onload = ~> grecaptcha.ready ~> res @inited = true
    s.setAttribute \type, \text/javascript
    s.setAttribute \src, \https://www.google.com/recaptcha/api.js
    document.body.appendChild s

  interface:
    init: ->
      @root = if typeof(@opt.root) == \string => document.querySelector(@opt.root) else @opt.root
      @_tag = document.createElement \div
      @root.appendChild @_tag
    get: ->
      Promise.resolve!
        .then ~>
          ret = grecaptcha.getResponse @id
          {token: ret, name: \recaptcha_v2_checkbox}
    reset: ->
    render: -> if !(@id?) => @id = grecaptcha.render @_tag, @_provider.cfg!{theme, size, sitekey}

if module? => module.exports =
  init: ({root}) -> captcha.prepare root
  interface: -> captcha
else if window => window.captcha = captcha
