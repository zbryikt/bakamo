<-(->it.apply {}) _
({core}) <~ servebase.corectx _

@words = []

view = new ldview do
  root: document
  init-render: false
  handler:
    word:
      list: ~> @words
      key: -> it.0
      view:
        text:
          eng: ({node, ctx}) -> ctx.0
          chi: ({node, ctx}) -> ctx.1

ld$.fetch "/assets/data/words.json", {method: \GET}, {type: \json}
  .then (data) ~>
    @words = data.filter -> it.0.length < 5
    view.render!
