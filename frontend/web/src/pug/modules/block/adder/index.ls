module.exports =
  pkg:
    extend: {ns: \local, name: \math-test, dom: true}
  init: ({pubsub}) ->
    prompt = ->
      a = Math.round(Math.random! * 10)
      b = Math.round(Math.random! * 10)
      c = a + b
      delta = Math.floor(Math.random! * 6)
      for i from 0 til 5
        d = Math.random!
      question: {content: "#a + #b = ?"}
      answers: [0 to 5].map (i) -> {value: (c - delta + i), idx: i, correct: (delta - i == 0)}

    pubsub.fire \init, {prompt}
