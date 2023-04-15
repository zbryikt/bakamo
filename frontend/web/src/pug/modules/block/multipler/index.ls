module.exports =
  pkg:
    extend: {ns: \local, name: \math-test, dom: true}
  init: ({pubsub}) ->
    prompt = ->
      a = Math.ceil(Math.random! * 9)
      b = Math.ceil(Math.random! * 9)
      c = a * b
      step = Math.ceil(Math.random! * 3)
      delta = Math.floor(Math.random! * 6) * step
      question: {content: "#a * #b = ?"}
      answers: [0 to 5].map (i) -> {value: (c - delta + i * step), idx: i, correct: (delta - i * step == 0)}

    pubsub.fire \init, {prompt}
