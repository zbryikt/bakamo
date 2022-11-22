module.exports =
  pkg:
    i18n:
      en:
        or: "or"
        title: "Password Updated"
        letstry: "Let's try now"
        desc: "if you can login with your brand new password."
        still: "Still not be able to login?"
        tryagain: "Try reseting it again"
        contact: "contact us directly."
        logged: "You have logged in"
        redirect: "We will now redirect you to the homepage..."
      "zh-TW":
        or: "或"
        title: "密碼已更新"
        letstry: "現在就試試"
        desc: "您是否可以使用新的密碼登入吧。"
        still: "仍然無法登入嗎？"
        tryagain: "試試看重設一次"
        contact: "直接與我們聯繫"
        logged: "您已登入"
        redirect: "現在就將您重導至首頁..."
  init: ({root}) ->
    ({core}) <~ servebase.corectx _
    <~ core.init!then _
    {auth, ldcvmgr} = core
    ensure = ->
      auth.ensure!
        .then -> window.location.href= \/
        .catch -> ensure!
    auth.get!then ->
      if it.{}user.key =>
        lda.ldcvmgr.toggle("logged-in")
        debounce 2000 .then -> window.location.href = \/
      else debounce 2000 .then -> ensure! #lda.auth.is-on!then -> if !it => ensure!
    view = new ldview do
      root: root
      action: click: login: -> ensure!
