({core}) <- servebase.corectx _

view = new ldview do
  root: document.body
core.manager.from {ns: \local, name: \multipler}, {root: view.get(\root)}
  .then (b) -> console.log b
