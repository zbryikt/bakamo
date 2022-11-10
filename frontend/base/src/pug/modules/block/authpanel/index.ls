module.exports =
  pkg:
    extend: {name: '@servebase/auth', path: 'index.html'}
  interface: ->
    p = @parent.interface!
    f = (a,b) ~>
      Promise.resolve!
        .then -> console.log "blah"
        .then -> p(a,b)
        .then ~> @core.ldcvmgr.get {name: '@servebase/consent', path: 'cookie'}
  init: (o) ->
    ({core}) <~ servebase.corectx _
    @manager = o.manager
    @core = core

    console.log @_instance.obj
