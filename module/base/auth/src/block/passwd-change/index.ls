module.exports =
  pkg:
    i18n:
      en:
        title: "Reset Your Password"
        desc: "Please be sure to choose a strong enough one."
        enter_new: "Enter new password"
        min8: "8 characters minimal"
        too_weak: "password too weak"
        enter_again: "Type it again"
        mismatch: "password not matched"
        setup: "Set Password"
        hint1: "Good password should be long enough ( at least 10 chars ). Prevent using your name, phone number or your birthday as password."
        hint2_1: "You can check how"
        hint2_2: "Password Strength"
        hint2_3: "is measured to know how safe your password is."
        done: "Password Updated"
        note1: "Your password has been updated. Please remember it and keep it properly somewhere, and try logging in again."
        note2_1: "If you still can't make it work after trying again, you can"
        letushelp: "and let us help you."
        contact: "contact us directly"
        "login_now": "Login Now"
        "homepage": "Home Page"
        "invalid_code": "Invalid Reset Code"
        "invalid_desc": "The reset link you use is invalid."
        "note3_1": "It's probably the the link you used expired. You can still go back to"
        "note3_2": "and send the password reset link again."
        "reset_page": "password reset page"
        "note4_1": "If this keeps on happening, you can"
        "send_again": "Send it Again"
      "zh-TW":
        title: "重設您的密碼"
        desc: "請務必選一個夠強的密碼。"
        enter_new: "輸入新的密碼"
        min8: "至少八個字元"
        too_weak: "密碼太弱了"
        enter_again: "再輸入一次"
        mismatch: "兩組密碼不相符"
        setup: "設定密碼"
        hint1: "好的密碼至少要夠長 ( 至少十個字 )。請不要用姓名、電話或生日當您的密碼。"
        hint2_1: "你可以查閱"
        hint2_2: "Password Strength"
        hint2_3: "這篇文章來了解怎樣算是一個好密碼。"
        done: "密碼重設完成"
        note1: "您的密碼已經重新設定為新的密碼了，請記住您現在的密碼並妥善保存，並嘗試再次登入。"
        note2_1: "若您持續無法成功重設您的密碼，您可以"
        letushelp: "，由我們為您重新設定。"
        contact: "直接聯絡我們"
        "login_now": "現在就登入"
        "homepage": "回首頁"
        "invalid_code": "無效的重設碼"
        "invalid_desc": "您所使用的密碼重設連結無效。"
        "note3_1": "你所使用的這個密碼重設連結應該是過期了。沒關係，您可以回到"
        "note3_2": "再次發送重設密碼信給自己。"
        "reset_page": "密碼重設頁"
        "note4_1": "如果這個問題一直發生，您也可以"
        "send_again": "再寄一次"
  init: ->
    ({core}) <~ servebase.corectx _
    <~ core.init!then _
    {auth, loader, ldcvmgr, captcha, error} = core
    ldcvmgr.init!
    if !document.querySelector(\#password-reset) => return
    view = new ldview do
      root: document.body
      action: click: submit: ~>
        if !pw-reset.ready! => return
        loader.on!
        captcha
          .guard cb: (captcha) ~>
            payload = {}
            payload = pw-reset.values!
            payload <<< {captcha}
            ld$.fetch "/api/auth/passwd/reset/#{@token}", {method: \POST}, {json: payload}
          .finally -> loader.off!
          .then -> ldcvmgr.get \done
          .then (v) ->
            if v != \login => return
            auth.ensure {lock: true} .then -> window.location.href = "/"
          .catch (e) ->
            console.log e
            error e

    pw-reset = new ldform do
      names: -> <[password confirm]>
      root: \#password-reset
      submit: "input[ld='submit']"
      after-check: (s, f) ->
        [p1,p2] = [@fields.password.value, @fields.confirm.value]
        if s.password != 1 and p1.length < 8 => s <<< password: 2, confirm: 1
        if p1 != p2 and (s.confirm != 1 or p2 and s.password == 0) => s.confirm = 2
    Promise.resolve!
      .then ~>
        token = (document.cookie or '').split(\;).filter(->/password-reset-token/.exec(it)).0
        @token = token = (token or '').split('=').1
        if !token => return ldcvmgr.get \invalid
        document.cookie = "password-reset-token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
