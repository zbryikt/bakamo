ldc.register \locales, <[]>, ->
  "@servebase/navtop":
    en:
      login: "登入"
      signup: "註冊"
      settings: "Settings"
      logout: "Logout"
    "zh-TW":
      login: "登入"
      signup: "註冊"
      settings: "個人設定"
      logout: "登出"


ldc.register \corecfg, <[locales]>, ({locales}) -> ->
  # corecfg function will be run in `core` context.
  i18n: locales: locales
  manager: new block.manager registry: ({ns, name, version, path, type}) ~>
    # access @global.version in core context
    # only customized core will show following registry detail
    console.log "mgr (dec=#{@global.version}): ", {ns, name, version, path, type}
    path = path or if type == \block => \index.html
    else if type => "index.min.#type" else 'index.min.js'
    path = "#{path}?dec=#{@global.version or ''}"
    if ns == \local =>
      if name in <[error cover]> => return "/modules/#name/#path"
      return "/modules/block/#name/#path"
    "/assets/lib/#{name}/#{version or 'main'}/#path"
  auth: authpanel: {ns: \local, name: "authpanel"}
