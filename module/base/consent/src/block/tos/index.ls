module.exports =
  pkg:
    i18n:
      "en":
        "continue": "Before you continue"
        "make sure": "Please make sure that you agree with our term of use"
        "yes": "Yes, I've read and agree with the term of use."
        "no": "No, I don't agree"
        "open": "Open document in new window"
      "zh-TW":
        "continue": "在繼續之前"
        "make sure": "請先確認您同意我們的使用條款"
        "yes": "是，我已詳讀並同意此使用條款"
        "no": "不，我不同意"
        "open": "於新視窗開啟文件"
  init: ({root}) ->
    @link = "about:blank"
    @view = view = new ldview do
      root: ld$.find(root, '.ldcv', 0)
      init-render: false
      init:
        link: ({node}) ~>
          node.addEventListener \load, ->
            node.setAttribute \scrolling, \no
            node.style.height = "#{node.contentDocument.body.parentNode.scrollHeight}px"
      handler:
        link: ({node}) ~>
          n = node.nodeName.toLowerCase!
          is-html = /\.html/.exec(@link)
          if n in <[object embed]> => node.classList.toggle \d-none, is-html
          if n in <[iframe]> => node.classList.toggle \d-none, !is-html
          if n == "a" => node.setAttribute \href, @link
          else if n == "object" => node.setAttribute \data, @link
          else node.setAttribute \src, @link

    @ldcv = new ldcover {
      root: root.querySelector('.ldcv')
      lock: true
      resident: true
      escape: false
    }

  interface: ->
    get: (opt = {}) ~>
      ret = @ldcv.get!
      @link = opt.link or '/privacy/embed.html'
      @view.render!
      ret


