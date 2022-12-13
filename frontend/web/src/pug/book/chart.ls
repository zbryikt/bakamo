# chart preparation sample code
core.manager.from {ns: \chart, name: \pie}, {root: view.get('chart')}
  .then (ret) ->
    chart = ret.interface
    chart.parse!
    chart.bind!
    chart.resize!
    chart.render!

