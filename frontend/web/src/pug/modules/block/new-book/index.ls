module.exports =
  pkg:
    dependencies: [
      * name: \ldcover, type: \js
      * name: \ldform, type: \js
    ]
  interface: -> @ldcv
  init: ({root, ctx}) ->
    ({core}) <~ servebase.corectx _
    {ldform, ldcover} = ctx
    @ldcv = new ldcover root: root, resident: true, zmgr: core.zmgr
    @ldcv.on \data, (d) ->
      console.log d
      form.values d
      form.check n: \isbn, now: true
    view = new ldview do
      root: root
      action: click:
        add: ({node}) ->
          if !form.ready! => return
          /* TODO implement add book logic */
    isbn =
      hash: {}
      check: (id) ->
        if typeof(@hash[id]) == \number => return @hash[id]
        if @hash[id] => return
        @_check id
      _check: debounce (id) -> 
        @hash[id] = proxise ->
        ld$.fetch "/api/book/", {method: \POST}, {json: {list: [id]}, type: \json}
          .then (ret) ~>
            if ret.length => @hash[id] = 2
            form.check n: \isbn, now: true
    form = new ldform do
      root: root
      submit: view.get \add
      verify: (n,v,e) ->
        if !v => return 2
        if n == \isbn => return isbn.check v
        return 0
