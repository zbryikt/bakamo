<-(->it.apply {}) _
({core}) <~ servebase.corectx _
<~ core.init!then _
<- core.auth.ensure!then _

readlist =
  loading: true
  is-loading: -> !!@loading
  get: -> if @loading => [] else (@list or [])
  update: -> @fetch!then -> view.render!
  fetch: ->
    @loading = true
    debounce 350
      .then ~>
        ld$.fetch "/api/read/#{core.user.key}", {method: \GET}, {type: \json}
      .then (ret) ~> @list = ret.map -> it.read <<< {book: it.book}
      .finally ~> @loading = false

view = new ldview do
  root: document.body
  init-render: false
  action:
    click:
      scan: ->
        core.ldcvmgr.get ns: \local, name: \scanner
          .then (book = {}) ->
            if !book.key => return
            core.loader.on!
            payload = list: [{book: book.key, enddate: new Date!}]
            ld$.fetch "/api/read/", {method: \POST}, {json: payload}
              .finally -> core.loader.off!
              .then ~> readlist.update!

      "new-read": ->
        core.ldcvmgr.get ns: \local, name: \new-read
          .then -> readlist.update!
      "new-book": -> core.ldcvmgr.get ns: \local, name: \new-book

  handler:
    "read-loading": ({node}) -> node.classList.toggle \d-none, !readlist.is-loading!
    "no-read": ({node}) ->
      node.classList.toggle \d-none, (readlist.is-loading! or readlist.get!length)
    read:
      list: -> readlist.get!
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
  .then -> readlist.fetch!
  .then -> view.render!
