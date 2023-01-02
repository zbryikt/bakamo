({core}) <- servebase.corectx _

audio =
  correct: new Audio \/assets/sfx/correct.mp3
  wrong: new Audio \/assets/sfx/wrong.mp3


obj =
  q: []
  stat: {count: 0, t: 0}
fetch-score = ->
  ld$.fetch "/api/score", {method: \GET}, {type: \json}
    .then (ret) -> obj.ranking = ret.splice(0, 15)

view = new ldview do
  init-render: false
  root: document.body
  text:
    n1: ({node}) -> obj.n1
    n2: ({node}) -> obj.n2
    n3: ({node}) -> obj.n3
    ans: -> obj.ans or ''
    avg: -> "#{(obj.stat.t / (1000 * (obj.stat.count or 1))).toFixed(1)}s"
    rate: -> (100 * obj.q.filter(->it.result == \correct).length / (obj.q.length or 1)).toFixed(1)
  handler:
    result: ({node}) -> node.setAttribute \class, "result #{obj.result or ''}"
    rank:
      list: -> obj.ranking.map (d,i) -> d <<< {rank: (i + 1)}
      key: -> it.key
      view:
        text:
          rank: ({ctx}) -> ctx.rank
          user: ({ctx}) -> ctx.displayname
          elapsed: ({ctx}) -> "#{(ctx.elapsed).toFixed(2)}s"
          rate: ({ctx}) -> "#{(100 * (ctx.correct or 0) / ((ctx.correct + ctx.wrong) or 1)).toFixed(2)}%"
    q:
      list: -> obj.q.slice(obj.q.length - 2 >? 0, obj.q.length)
      view:
        text:
          n1: ({node, ctx}) -> ctx.n1
          n2: ({node, ctx}) -> ctx.n2
          n3: ({node, ctx}) -> ctx.n3
          ans: ({ctx}) -> ctx.ans or ''
          elapsed: ({ctx}) -> "#{(ctx.elapsed / 1000).toFixed(1)}s"
        handler:
          result: ({node, ctx}) -> node.setAttribute \class, "result #{ctx.result or ''}"

ticking = (t) ->
  node = view.get('tick')
  if !obj.t? => obj.t = t
  obj.ct = t
  node.textContent = "#{((t - obj.t) / 1000).toFixed(1)}s"
  requestAnimationFrame ticking

requestAnimationFrame ((t) -> ticking t)

document.addEventListener \keyup, (e) ->
  if e.keyCode >= 48 and e.keyCode <= 57 =>
    obj.ans = (obj.ans or "") + String.fromCharCode(e.keyCode)
    view.render!
  else if e.keyCode == 8 =>
    ans = obj.ans or ''
    obj.ans = ans.substring(0, (ans.length - 1 >? 0))
    view.render!
  else if e.keyCode == 13 =>
    q = obj{n1, n2, n3, ans}
    q.elapsed = obj.ct - obj.t
    delete obj.t
    if q.n1 + q.n2 - q.n3 == +q.ans =>
      obj.stat.t += q.elapsed
      obj.stat.count += 1
      audio.correct.play!
      q.result = \correct
    else
      audio.wrong.play!
      q.result = \wrong
    obj.q.push q
    #obj.q = [ q ]
    obj.ans = ''
    gen!

gen = ->
  if obj.q.length >= 20 =>
    payload =
      correct: obj.q.filter(-> it.result == \correct).length
      wrong: obj.q.filter(-> it.result == \wrong).length
      elapsed: (obj.stat.t / (1000 * (obj.q.length or 1)))
      slug: "math-add-sub-1"
    rate = (100 * (payload.correct / (obj.q.length or 1))).toFixed(2)
    alert "做答結束！你的正確率: #{rate}%, 平均費時: #{(payload.elapsed).toFixed(2)}s"
    ld$.fetch "/api/score/", {method: \POST}, {json: payload}
      .then -> window.location.reload(true)

  obj.n1 = Math.round(Math.random! * 4) + 6
  obj.n2 = Math.round(Math.random! * 6) + 3
  obj.n3 = Math.round(Math.random! * 5) + 1
  view.render!

Promise.resolve!
  .then ->
    fetch-score!
  .then ->
    gen!
