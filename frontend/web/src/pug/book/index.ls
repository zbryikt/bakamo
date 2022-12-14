<-(->it.apply {}) _
({core}) <~ servebase.corectx _
<~ core.init!then _
<- core.auth.ensure!then _

sudans =
  _: all: [], loading: true, cur: null, detail: {}
  get: -> if @_.loading => [] else (@_.all or [])
  cur: -> @_.cur
  is-loading: -> !!@_.loading
  update: -> @fetch!then -> view.render!
  toggle: (sudan = {}) ->
    sudan = @_.all.filter(-> it.key == (sudan.key or sudan)).0
    @_.cur = sudan
    @_.loading = true
    view.render!
    @fetch-sudan!
      .finally ~> @_.loading = false
      .then -> view.render!

  fetch-sudan: ->
    if !@_.cur => return
    key = @_.cur.key
    console.log key, @_.cur
    ld$.fetch "/api/sudan/#key", {method: \GET}, {type: \json}
      .then (ret) ~> @_.detail[key] = ret.map -> it.dusu <<< {book: it.book}

  fetch: ->
    @_.loading = true
    debounce 350
      .then ~> ld$.fetch "/api/user/#{core.user.key}/sudan", {method: \GET}, {type: \json}
      .then (ret) ~>
        @_.all = ret
        if !@_.cur => @_.cur = ret.0
        @fetch-sudan!
      .finally ~> @_.loading = false
  dusu:
    get: -> sudans._.detail[(sudans.cur! or {}).key] or []
    add: (payload) ->
      core.loader.on!
      ld$.fetch "/api/sudan/#{sudans.cur!key}", {method: \POST}, {json: payload}
        .finally -> core.loader.off!
        .then ~> sudans.update!


view = new ldview do
  root: document.body
  init-render: false
  action:
    click:
      scan: ->
        core.ldcvmgr.get {ns: \local, name: \scanner}, {data: sudans.cur!}
          .then (book = {}) ->
            if !book.key => return
            payload = list: [{book: book.key, enddate: new Date!}]
            sudans.dusu.add payload
      "new-sudan": ->
        core.ldcvmgr.get {ns: \local, name: \new-sudan}, {data: sudans.cur!}
          .then ->
      "new-dusu": ->
        core.ldcvmgr.get {ns: \local, name: \new-dusu}, {data: sudans.cur!}
          .then -> sudans.update!
      "new-book": -> core.ldcvmgr.get ns: \local, name: \new-book

  handler:
    "sudan-loading": ({node}) -> node.classList.toggle \d-none, !sudans.is-loading!
    "no-dusu": ({node}) ->
      node.classList.toggle \d-none, (sudans.is-loading! or sudans.dusu.get!length)
    sudan:
      list: -> sudans.get!
      key: -> it.key
      view:
        action: click: "@": ({ctx}) -> sudans.toggle ctx
        text:
          title: ({node, ctx}) -> ctx.title or '未命名'
          description: ({node, ctx}) -> ctx.description or ''
          createdtime: ({node, ctx}) ->
            if !ctx.createdtime => 'n/a'
            else dayjs(ctx.createdtime).format('YYYY/MM/DD hh:mm:ss')
    dusu:
      list: -> sudans.dusu.get!
      key: -> it.key
      view:
        init:
          startdate: ({node, ctx}) ->
            lddtp = new lddatetimepicker host: node
            lddtp.on \change, ->
              console.log it
              ctx.startdate = it
              view.render!
        action: click: startdate: ->
        text:
          title: ({node, ctx}) -> ctx.book.title
          isbn: ({node, ctx}) -> ctx.book.isbn
          startdate: ({node, ctx}) ->
            if !ctx.startdate => 'n/a'
            else dayjs(ctx.startdate).format('YYYY/MM/DD hh:mm:ss')
          enddate: ({node, ctx}) ->
            if !ctx.enddate => 'n/a'
            else dayjs(ctx.enddate).format('YYYY/MM/DD hh:mm:ss')

Promise.resolve!
  .then -> view.render!
  .then -> sudans.fetch!
  .then -> view.render!
