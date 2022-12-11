servebase =
  corectx: (cb) ->
    new Promise (res, rej) ->
      ret = ldc.register <[core]>, (o) ->
        o.core.init!
          .then -> cb.apply o.core, [o]
          .then res
          .catch rej
      ldc.init ret
  config: (o = {}) ->
    if @_inited =>
      console.warn """
      [@servebase/core] `servebase.config` is called after `@servebase/core` is initialized.
      [@servebase/core] This may lead to inconsistent behavior.
      """
    @_cfg = o
  _init: (o) ->
    # _init is usually called with provided context (the core context, instead of `servebase`),
    # so we have to access `servebase` directly with its name.
    servebase._inited = true
    if o? => servebase._cfg = o
    @_cfg = servebase._cfg or {}
    # similarly, corecfg will be called with `this` as its context
    # so it can access core context.
    if typeof(@_cfg) == \function => @_cfg = @_cfg!
    @ <<< global: {}, user: {}
    @ <<<
      zmgr: new zmgr!
      manager: @_cfg.manager or new block.manager do
        registry: ({ns, url, name, version, path, type}) ->
          if url => return that
          path = path or if type == \block => \index.html
          else if type => "index.min.#type" else 'index.min.js'
          if ns == \local =>
            if name in <[error cover]> => return "/modules/#name/#{path or 'index.html'}"
            return "/modules/block/#name/#{path or 'index.html'}"
          "/assets/lib/#{name}/#{version or 'main'}/#{path}"
    ldcover.zmgr @zmgr
    @ <<<
      loader: new ldloader class-name: "ldld full", auto-z: true, base-z: null, zmgr: @zmgr.scope zmgr.splash
      captcha: new captcha manager: @manager, zmgr: @zmgr.scope zmgr.splash
      ldcvmgr: new ldcvmgr(
        manager: @manager
        error-cover: {ns: \local, name: "error", path: "0.html"}
        zmgr: @zmgr
        base-z: zmgr.modal
      )
      # TODO we should at least provide a dummy i18n so i18n.t will work
      i18n: i18n = if @_cfg.{}i18n.driver => that else if i18next? => i18next else undefined

    ethr = t: 0, c: 0
    err = new lderror.handler handler: (n, e) ~>
      /*
      melt down mechanism - prevent infinite errors. errors limited to 4 in 500ms / 11 in 2s
      any unhandled error/rejection may trigger this handler again, which causes infinite errors
      e.g., Promise.reject(Promise.reject(new Error())) in @plotdb/block `_fetch`
      generate an additional rejection which is impossible to be caught.
      this bug in @plotdb/block is fixed, however in case of any possible bugs in the future -
      melt down mechanism is required.
      */
      t = Date.now!
      if ethr.t < t - 2000 => ethr <<< t: t, c: 0
      else if !ethr.t => ethr << t: t, c: 0
      else if ethr.t > t - 2000 and ethr.c > 10 or ethr.t > t - 500 and ethr.c > 3 =>
        return alert "something is wrong; please reload and try again"
      ethr.c = (ethr.c or 0) + 1
      @ldcvmgr.get {ns: \local, name: \error, path: "#n.html"}, e
    @error = (e) -> err e

    @ <<<
      erratum: new erratum handler: err
      auth: new auth do
        manager: @manager
        zmgr: @zmgr
        loader: @loader
        authpanel: if @_cfg.auth => @_cfg.auth.authpanel else null

    if ldc? => ldc.action \ldcvmgr, @ldcvmgr

    @update = (g) -> @ <<< {global: g, user: (g.user or {})}
    @auth.on \error, @error
    @auth.on \logout, -> window.location.replace '/'

    @manager.init!
      # to optimize, we may delay or completely ignore i18n
      # since not every service need i18n
      .then ~>
        if !i18n? => return
        i18ncfg = @_cfg.i18n.cfg or {
          supportedLng: <[en zh-TW]>, fallbackLng: \zh-TW, fallbackNS: '', defaultNS: ''
        }
        Promise.resolve!
          .then -> i18n.init i18ncfg
          .then -> if i18nextBrowserLanguageDetector? => i18n.use i18nextBrowserLanguageDetector
          .then ~>
            for k,v of (@_cfg.i18n.locales or {}) => i18n.add-resource-bundle k, '', v, true, true
            lng = (
              (if httputil? => (httputil.qs(\lng) or httputil.cookie(\lng)) else null) or
              navigator.language or navigator.userLanguage
            )
            if !(lng in i18ncfg.supportedLng) => lng = i18ncfg.fallbackLng or i18ncfg.supportedLng.0 or \en
            console.log "[@servebase/core][i18n] use language: ", lng
            i18n.changeLanguage lng
          .then ->
            i18n.on \languageChanged, (lng) ->
              if httputil? =>
                console.log "[@servebase/core][i18n] language changed to #lng / cookie updated"
                httputil.cookie \lng, lng, {path: \/}
              else
                console.log "[@servebase/core][i18n] language changed to #lng / no httputil, skip cookie update"
            block.i18n.use i18n
      .then ~>
        # PERF TODO block.i18n.use and manager.init are quite fast.
        # we may provide an anonymous initialization
        # to prevent fetching at loading time to speed up FCP.
        @auth.get!
      .then (g) ~>
        @global = g
        @user = g.user
        @captcha.init g.captcha
      .then ~>
        @auth.on \update, (g) ~> @update g
        # prepare authpanel. involving @plotdb/block creation.
        # should delay until we really have to trigger ui
        @

ldc.register \core, <[corecfg]>, ({corecfg}) ->
  if corecfg? => servebase.config corecfg
  init: proxise.once (o) -> servebase._init.apply @, [o]

if module? => module.exports = servebase
else if window? => window.servebase = servebase
