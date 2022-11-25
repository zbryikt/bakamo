<-(->it.apply {}) _
({core}) <~ servebase.corectx _
<~ core.init!then _

view = new ldview do
  root: document.body
  text: output: ({node}) ~> @output or 'n/a'

core.ldcvmgr.get {ns: \local, name: 'scanner'}
  .then ~>
    @output = it
    view.render!
