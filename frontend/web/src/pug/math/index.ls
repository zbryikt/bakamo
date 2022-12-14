({core}) <- servebase.corectx _

audio =
  correct: new Audio \/assets/sfx/correct.mp3
  wrong: new Audio \/assets/sfx/wrong.mp3

obj =
  q: []
  stat: {count: 0, t: 0}
view = new ldview do
  root: document.body
  text:
    n1: ({node}) -> obj.n1
    n2: ({node}) -> obj.n2
    ans: -> obj.ans or ''
    avg: -> "#{(obj.stat.t / (1000 * (obj.stat.count or 1))).toFixed(1)}s"
  handler:
    result: ({node}) -> node.setAttribute \class, "result #{obj.result or ''}"
    q:
      list: -> obj.q
      view:
        text:
          n1: ({node, ctx}) -> ctx.n1
          n2: ({node, ctx}) -> ctx.n2
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
    q = obj{n1, n2, ans}
    q.elapsed = obj.ct - obj.t
    delete obj.t
    if q.n1 - q.n2 == +q.ans =>
      obj.stat.t += q.elapsed
      obj.stat.count += 1
      audio.correct.play!
      q.result = \correct
    else
      audio.wrong.play!
      q.result = \wrong
    #obj.q.push q
    obj.q = [ q ]
    obj.ans = ''
    gen!
gen = ->
  obj.n1 = Math.round(Math.random! * 5) + 5
  obj.n2 = Math.round(Math.random! * 5) + 1
  view.render!

gen!
