discuss = (o = {}) ->
  @root = if typeof(o.root) == \string => document.querySelector(o.root) else o.root
  @ <<<
    _evthdr: {}
    _loading: false
    _purify: (t) ->
      if DOMPurify? => return DOMPurify.sanitize t
      console.warn "[@servebase/discuss] DOMPurify is not found which is required for DOM sanitizing"
      return t
    _md: (t) ->
      if marked? => return marked.parse t
      console.warn "[@servebase/discuss] marked is not found which is required for markdown compiling"
      return t
    comments: [], discuss: {}
  @_uri = o.uri or window.location.pathname
  @_slug = o.slug or null
  @_core = o.core
  @_edit = {content: config: {}}
  @

discuss.prototype = Object.create(Object.prototype) <<<
  on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @_evthdr.[][n].push cb
  fire: (n, ...v) -> for cb in (@_evthdr[n] or []) => cb.apply @, v
  is-ready: -> true # TODO
  init: ->
    @view = @_view {root: @root}
    @_core.init!
      .then ~> @_core.auth.get!
      .then (g) ~> @g = g
  load: ->
    @_loading = true
    @view.render!
    @fire \loading
    payload = if @_slug => {slug: @_slug} else {uri: @_uri}
    ld$.fetch \/api/discuss, {method: \GET}, {params: payload, type: \json}
      .finally ~> @loading = false
      .then (r) ~>
        console.log "load: ", r
        @ <<< {comments: r.comments or [], discuss: r.discuss or {}}
        @fire \loaded
        @view.render!
  content-render: ({node, ctx}) ->
    obj = ctx.content or {}
    if !obj.{}config["renderer"] => node.innerText = obj.body
    else node.innerHTML = @_purify @_md obj.body
  _view: ({root}) ->
    set-cfg = (o = {}) ~> for k,v of o => @_edit.content.config[k] = v
    cfg = {}
    cfg.edit =
      action:
        input:
          "toggle-preview": ({node}) ~>
            @_edit.preview = !!node.checked
            #view.render!
          input: ({node}) ~>
            @_edit.content.body = node.value
            #view.render \submit
        click:
          submit: ({node}) ~>
            if node.classList.contains \running => return
            if node.classList.contains \disabled => return
            if !@is-ready! => return
            payload = {uri: @_uri, content: @_edit.content, slug: @_slug}
            #@data{uri, reply, content, slug, key, title}
            @_core.auth.ensure!
              .then ~>
                @ldld.on!
                @_core.captcha
                  .guard cb: (captcha) ->
                    payload <<< {captcha}
                    ld$.fetch(
                      \/api/discuss
                      {method: if payload.key => \PUT else \POST}
                      {type: \json, json: payload}
                    )
              .then (ret) -> debounce 1000 .then -> return ret
              .finally ~> @ldld.off!
              .then (ret) ~>
                @fire \new-comment, {
                  owner: @_core.user.key,
                  displayname: @_core.user.displayname
                  createdtime: Date.now!
                } <<< payload <<< ret{key, slug}
                @_edit.content.body = ''
                @_edit.preview = false
                #view.render!
      init: submit: ({node}) ~> @ldld = new ldloader root: node
      handler:
        "use-markdown":
          action:
            input: check: ({node, views}) ~>
              use-markdown = !!node.checked
              set-cfg renderer: if use-markdown => \markdown else ''
            click: label: ({node, views}) ~>
              input = views.0.get \check
              use-markdown = input.checked = !input.checked
              set-cfg renderer: if use-markdown => \markdown else ''
        avatar: ~> # site specific
        preview: ~>
          #revert = ("off" in node.getAttribute(\ld).split(" "))
          #state = !(@preview and @use-markdown) xor revert
          #node.classList.toggle \d-none, state
        #panel: ({node}) ~> if @preview => node.innerHTML = marked((@data.content.body or ''), @marked-options)
        #submit: ({node}) ~> node.classList.toggle \disabled, !@is-ready!
        #"edit-panel": ({node}) ~> node.classList.toggle \d-none, !!@preview
        #"if-markdown": ({node}) ~> node.classList.toggle \d-none, !@use-markdown
    cfg.discuss = text: "@": ~> (@discuss or {}).title or 'untitled'
    cfg.comments = handler:
      "no-comment": ({node}) ~> node.classList.toggle \d-none, @comments.length
      comment:
        list: ~> @comments
        key: -> it.key
        view: 
          text:
            date: ({ctx}) ->
              if isNaN(d = new Date(ctx.createdtime)) => return \-
              new Date(d.getTime! - (d.getTimezoneOffset!*60000)).toISOString!.slice(0,19).replace(\T,' ')
            author: ({ctx}) -> ctx.displayname
          handler:
            avatar: -> # site specified
            role:
              list: ({ctx}) -> (if Array.is(ctx.role) => ctx.role else [ctx.role]).filter(->it)
              key: -> it
              view: text: name: ({ctx}) -> ctx
            content: (o) ~> @content-render o{node, ctx}

    return new ldview do
      root: root
      init-render: false
      handler:
        loading: ({node,names}) ~> node.classList.toggle \d-none, !(@_loading xor ('off' in names))
        discuss: cfg.discuss
        edit: cfg.edit
        comments: cfg.comments

if module? => module.exports = discuss
else if window? => window.discuss = discuss
