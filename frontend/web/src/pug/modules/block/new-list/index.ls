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
    {ldform} = ctx
    view = new ldview do
      root: root
      action: click:
        add: ({node}) ~>
          if !form.ready! => return
          payload = form.values!
          ld$.fetch "/api/readlist/", {method: \POST}, {json: payload}
            .then ~> @ldcv.set!
    form = new ldform do
      root: root
      submit: view.get \add
      verify: (n,v,e) ~>
        if n == \description => return 0
        if n == \title => form.check n: \description, now: true
        if !v => return 2
        return 0
