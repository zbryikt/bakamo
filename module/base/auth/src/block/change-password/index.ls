module.exports =
  pkg:
    i18n:
      en:
        title: "Change Password"
        old: "Old Password"
        nomatch: "Password not matched."
        forget: "Forget Password?"
        send: "Send Reset Link"
        new: "New Password"
        weak: "Password too weak"
        again: "New Password Again"
        update: "Update Password"
        len: "Length"
        bad: "Bad"
        ok: "Okay"
        good: "Good"
        fail: "Incorrect Old Password?"
        done: "Update Password Successfully"
        sent: "Link Sent"
        hint: [
          "A good password should be at least 10 characters long. Please do not use your name, phone number, or birthday as your password."
          [
            "You can check out the article"
            "to learn what makes a good password."
          ]
        ]
      "zh-TW":
        title: "變更密碼"
        old: "舊的密碼"
        nomatch: "密碼不符"
        forget: "忘記密碼嗎？"
        send: "寄發重設連結信"
        new: "新密碼"
        weak: "密碼太弱了"
        again: "再輸入一次新密碼"
        update: "更新密碼"
        len: "長度"
        bad: "不妙"
        ok: "還好"
        good: "不錯"
        fail: "舊的密碼有誤"
        done: "密碼更新完成"
        sent: "連結已寄出"
        hint: [
          "好的密碼至少要夠長 ( 至少十個字 )。請不要用姓名、電話或生日當您的密碼。"
          [
            "你可以查閱"
            "這篇文章來了解怎樣算是一個好密碼。"
          ]
        ]
    dependencies: [
      {name: "ldform"}
    ]
  init: ({root, ctx, t}) ->
    ({core}) <~ servebase.corectx _
    <~ core.init!then _
    {auth, captcha} = core
    {ldform} = ctx
    (g) <~ auth.ensure!then _
    view = new ldview do
      root: root
      init:
        'update-password': ({node, local}) -> local.ldld = new ldloader root: node
        'send-reset-link': ({node, local}) -> local.ldld = new ldloader root: node
      action: click:
        'send-reset-link': ({node, local}) ->
          if node.classList.contains \disabled => return
          ldld = local.ldld
          ldld.on!
          captcha
            .guard cb: (captcha) ->
              json = {email: core.user.username, captcha}
              ld$.fetch \/api/auth/passwd/reset, {method: \POST}, {json}
            .finally ->
              debounce 1000 .then -> ldld.off!
            .then ->
              node.innerHTML = t('sent') + ' <i class="i-check"></i>'
              node.classList.add \disabled
              ldnotify.send \success, t('sent')

        'update-password': ({local, node}) ->
          if node.classList.contains(\disabled) => return
          <- form.check-all!then _
          if !form.ready! => return
          ldld = local.ldld
          ldld.on!
          val = form.values!
          captcha
            .guard cb: (captcha) ->
              json = {o: val.oldpasswd, n: val.newpasswd1, captcha}
              ld$.fetch \/api/auth/passwd/, {
                method: \put
                headers: { 'Content-Type': 'application/json; charset=UTF-8' }
              }, {json}
            .finally -> ldld.off!
            .then -> auth.fetch renew: true
            .then ->
              ldnotify.send \success, t(\done)
              form.reset!
            .catch (e) ->
              id = lderror.id e
              ldnotify.send \danger, (
                if id == 1031 => t(\weak)
                else if id == 1030 => t(\nomatch)
                else t(\fail)
              )

    form = new ldform do
      root: root
      after-check: (s) ->
        [p1,p2] = [@fields.newpasswd1.value, @fields.newpasswd2.value]
        s.username = 0
        if s.newpasswd1 != 1 and p1.length < 6 => s <<< newpasswd1: 2, newpasswd2: 1
        if p1 != p2 and (s.newpasswd2 != 1 or p2 and s.newpasswd1 == 0) => s.newpasswd2 = 2
        passwd = ld$.find(@root, '[data-node]', 0)
        if s.newpasswd1 != 1 =>
          len = Math.round(p1.length)
          text = if len < 8 => \bad else if len < 10 => \ok else \good
          width = 100 * ( len <? 12 ) / 12
          color = if len < 8 => \danger else if len < 10 => \warning else \success
          ld$.find(passwd, 'label', 0).textContent = t(\len) + ": " + t(text)
          bar = ld$.find(passwd, '.progress-bar', 0)
          bar.style.width = "#{width}%"
          cls = bar.getAttribute \class
          cls = cls.replace(/bg-\S+/, '').trim! + " bg-#color"
          bar.setAttribute \class, cls
