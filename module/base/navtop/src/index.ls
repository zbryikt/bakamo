({core}) <- ldc.register \navtop, <[core]>, _

i18n-res =
  en:
    navtop:
      home: "Home"
      language: "Language"
      login: "Login"
      signup: "Sign Up"
      personal: "Personal"
      settings: "My Settings"
      projects: "My Projects"
      advanced: "Advanced"
      logout: "Logout"
      judge: "Judge Panel"
      admin: "Admin Panel"
  "zh-TW":
    navtop:
      home: "首頁"
      language: "語言"
      login: "登入"
      signup: "註冊"
      personal: "個人功能"
      settings: "我的設定"
      projects: "我的專案"
      advanced: "進階功能"
      logout: "登出"
      judge: "評審頁面"
      admin: "管理頁面"

obj =
  toggled: true
  toggle: (v) ->
    @toggled = !!v
    if @view => @view.render!

core.init!then ->
  <-(->it.apply obj) _
  if core.i18n? =>
    for lng,v of i18n-res =>
      core.i18n.addResourceBundle lng, \navtop, v

  auth = core.auth
  @ <<< core{user, global}

  if !(navtop = ld$.find('[ld-scope=navtop]',0)) => return

  @update = (g) ~>
    p = if g => Promise.resolve(g) else auth.get!
    p.then (g) ~>
      @ <<< {global: g, user: g.user or {}}
      view.render!

  auth.on \update, (g) ~> @update g

  @view = view = new ldview do
    root: navtop
    action:
      click:
        signup: ~> auth.prompt {tab: \signup} .then ~> @update!
        login: ~> auth.prompt {tab: \login} .then ~> @update!
        logout: ~> auth.logout!then ~> @update!
        "set-lng": ({node, views}) ~>
          core.i18n.changeLanguage node.getAttribute \data-name
          views.0.render \lng
    text:
      displayname: ~> @user.displayname or 'User'
      username: ~> @user.username or 'n/a'
      lng: ->
        if !core.i18n => return
        lng = core.i18n.language
        view.getAll(\set-lng)
          .filter (n) -> lng == n.getAttribute(\data-name)
          .map (n) -> n.getAttribute(\data-alias) or n.innerText.trim!
          .0 or lng
    init: t: ({node}) -> if !node.getAttribute(\t) => node.setAttribute(\t, node.textContent)
    handler:
      "@": ({node}) ~> node.style.display = if @toggled => \block else \none
      t: ({node}) -> if core.i18n => node.innerText = core.i18n.t("navtop:#{node.getAttribute(\t)}")
      admin: ({node}) ~> node.classList.toggle \d-none, !@user.staff
      unauthed: ({node}) ~> node.classList.toggle \d-none, !!@user.key
      authed: ({node}) ~> node.classList.toggle \d-none, !@user.key
      avatar: ({node}) ~> node.style.backgroundImage = "url(/assets/avatar/#{@user.key})"

  if core.i18n => core.i18n.on \languageChanged, -> view.render \lng, \t

  bar = view.get \root
  dotst = (bar.getAttribute(\data-classes) or "").split(';').map(->it.split(' ').filter(->it))
  tst-tgt = if bar.getAttribute(\data-pivot) => ld$.find(document, that, 0) else null
  if !(dotst.length and tst-tgt) => return
  (new IntersectionObserver (->
    if !(n = it.0) => return
    dotst.0.map (c) -> bar.classList.toggle c, n.isIntersecting
    if dotst.1 => dotst.1.map (c) -> bar.classList.toggle c, !n.isIntersecting
  ), {threshold: 0.1}).observe tst-tgt

  return {}
return obj
