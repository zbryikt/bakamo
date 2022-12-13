module.exports =
  pkg:
    dependencies: [
      * name: \ldcover, type: \js
      * name: \ldform, type: \js
    ]
  interface: -> @ldcv
  init: ({root, ctx}) ->
    ({core}) <~ servebase.corectx _
    @ldcv = new ldcover root: root, resident: true, zmgr: core.zmgr
    @ldcv.on \data, (d) ->
    {ldform} = ctx
    view = new ldview do
      root: root
      action: click:
        add: ({node}) ~>
          if !form.ready! => return
          {isbn} = form.values!
          if !(book = @isbn.find isbn) => return
          payload = list: [{book: book.key, date: new Date!}]
          ld$.fetch "/api/sudan/???", {method: \POST}, {json: payload}
            .then ~> @ldcv.set!
    @isbn =
      hash: {}
      key: {}
      find: (id) -> @key[id]
      check: (id) ->
        if typeof(@hash[id]) == \number => return @hash[id]
        if @hash[id] => return
        @_check id
      _check: debounce (id) -> 
        @hash[id] = proxise ->
        ld$.fetch "/api/book/", {method: \POST}, {json: {list: [id]}, type: \json}
          .then (ret) ~>
            if ret.length => @hash[id] = 0
            ret.map (b) ~> @key[b.isbn] = b
            form.check n: \isbn, now: true
    form = new ldform do
      root: root
      submit: view.get \add
      verify: (n,v,e) ~>
        if !v => return 2
        if n == \isbn => return @isbn.check v
        return 0
