<-(->it.apply {}) _
({core}) <~ servebase.corectx _
<~ core.init!then _

get-book = ({isbn}) ->
  json = list: [isbn]
  ld$.fetch "/api/book", {method: \POST}, {type: \json, json}
    .then (ret) ->
      if !(ret and ret.0) => return
      book[ret.0.key] = ret.0
      mylist.push {key: Math.random!, book: ret.0.key}
      view.render!

book = {}
mylist = []
view = new ldview do
  root: document.body
  action:
    click:
      query: -> get-book {isbn: view.get(\isbn).value}
      scan: ->
        core.ldcvmgr.get ns: \local, name: \scanner
          .then (ret) -> get-book {isbn: ret}

  handler:
    read:
      list: -> mylist
      key: -> it.key
      view:
        text:
          name: ({ctx}) -> book[ctx.book].title
          date: -> Date.now!
