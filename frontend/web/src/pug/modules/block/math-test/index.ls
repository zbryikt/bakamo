module.exports =
  pkg: {}
  init: ({root, pubsub}) ->
    pubsub.on \init, ({prompt}) -> mod {root, pubsub, mod: {prompt}}

mod = ({root, pubsub, mod}) ->
  audio =
    correct: new Audio \/assets/sfx/correct.mp3
    wrong: new Audio \/assets/sfx/wrong.mp3

  obj =
    result: []
    prompt: {}
    mode: \count
    stat: correct: 0, wrong: 0, total: 20, count: 0
    time: start: 0, limit: 30

  remains = -> (((obj.time.start + obj.time.limit * 1000) - Date.now!)/1000) >? 0
  tick = ->
    view.render \countdown
    if remains! > 0 => requestAnimationFrame (->tick!)
  view = new ldview do
    init-render: false
    root: root
    ctx: -> obj.prompt
    handler:
      countdown: ({node}) ->
        node.textContent = (remains!).toFixed(1)
      screen: ({node}) ->
        name = node.getAttribute \data-name
        hide = obj.stat.count == obj.stat.total
        hide = if name == \done => !hide else hide
        node.classList.toggle \d-none, hide
      result: ({node}) ->
        name = node.getAttribute \data-name
        node.style.width = "#{100 * obj.stat[name] / obj.stat.total}%"
      question: ({node, ctx}) -> node.textContent = ctx.question.content
      answer:
        list: ({ctx}) -> ctx.answers
        key: -> it.idx
        view:
          handler: "@": ({node, ctx}) -> node.textContent = ctx.value
          action: click: "@": ({node, ctx}) ->
            ret = if ctx.correct => \correct else \wrong
            audio[ret].play!
            obj.stat[ret] = (obj.stat[ret] or 0) + 1
            obj.stat.count++
            gen!

  gen = ->
    obj.prompt = mod.prompt!
    view.render!
  start = ->
    obj.time.start = Date.now!
    tick!

    gen!
  start!
