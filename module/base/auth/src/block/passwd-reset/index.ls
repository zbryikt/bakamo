module.exports =
  pkg:
    dependencies: [
      {name: "ldform"},
      {name: "curegex", path: "curegex.min.js"}
    ]
    i18n:
      "en": 
        "forgot": "Forgot Password?"
        "enter": "Please input the email address associated with your account to receive the password reset mail:"
        "invalid": "invalid email address"
        "send": "Send Reset Link"
        "note1": "You won't receive the password reset mail if it's not the email you used to sign up before."
        "note2_1": "If you don't remember the email address you used, please"
        "letushelp": " and let us help you."
        "contact": "contact us directly"
        "contact-alt": "contact us"
        "close": "close window"
        "help": "Need help? Please"
        "404": "Email Not Found"
        "404-desc": "We can't find the account associated with the email address you provided."
        "cause": "Possible reasons:"
        "cause_1": "You used another email to sign up before."
        "cause_2": "There are typos in the email you provided."
        "cause_3": "There are typos when you signed up."
        "sent": "Password Reset Link Sent"
        "sent_desc": "It will be arrived soon. Please check your inbox later"
        "toolong_1": "Sometimes mail just went directly into spam folder so please don't forget to check the "
        "spam": "Spam Folder"
        "toolong_2": ". Or, you can also:"
        "again": "Send it again"

      "zh-TW":
        "forgot": "忘記密碼？"
        "enter": "請輸入您帳號所用的電子郵件地址，我們將發送密碼重設連結給您："
        "invalid": "無效的電子郵件"
        "send": "發送重設連結"
        "note1": "您若不是使用這個電子郵件註冊的話，就不會收到密碼重設信。"
        "note2_1": "若您已不記得您使用了哪組電子郵件註冊的話，請"
        "letushelp": "，讓我們來協助您。"
        "contact": "直接與我們聯繫"
        "contact-alt": "聯繫我們"
        "close": "關閉視窗"
        "help": "需要協助嗎？請"
        "404": "找不到電子郵件"
        "404_desc": "我們無法找到這個電子郵件對應的帳號。"
        "cause": "這可能是因為："
        "cause_1": "您之前用的是另一組電子郵件。"
        "cause_2": "您剛剛有打錯字。"
        "cause_3": "您之前註冊時有打錯字。"
        "sent": "重設密碼連結已寄出"
        "sent_desc": "請檢查您的電子郵件信箱，應該不久就會收到重設密碼信囉。"
        "toolong_1": "等不到信嗎？有時信件會被分類到垃圾信件匣，請別忘了查看您的"
        "spam": "垃圾信件匣"
        "toolong_2": "。或者，您亦可以："
        "again": "再寄一次"

  init: ({ctx}) ->
    {curegex, ldform} = ctx
    ({core}) <~ servebase.corectx _
    <~ core.init!then _
    @ldcv = {}
    {loader, error, captcha} = core
    view = new ldview do
      root: '[ld-scope=password-reset]'
      init:
        "sent": ({node}) ~> @ldcv.sent = new ldcover root: node, lock: true
        "not-found": ({node}) ~> @ldcv.not-found = new ldcover root: node
        "email": ({node}) ~> node.focus!
      action: click: do
        submit: ({node}) ~>
          if !pw-reset-mail.ready! => return
          loader.on!
          captcha.guard cb: (captcha) ~>
            ld$.fetch '/api/auth/passwd/reset', {method: \POST}, {json: {email: view.get(\email).value, captcha}}
              .finally ~> loader.off!
              .then ~> @ldcv.sent.get!
              .catch (e) ~>
                if lderror.id(e) == 404 => @ldcv.not-found.toggle!
                else error e
    pw-reset-mail = new ldform do
      names: -> <[email]>
      submit: '.btn[ld=submit]'
      root: view.root
      after-check: (s, f) ->
        if s.email != 1 and !curegex.get('email').exec(f.email.value) => s.email = 2

