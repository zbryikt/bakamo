module.exports =
  pkg:
    extend: {name: '@servebase/auth', path: 'index.html'}
  interface: ->
    p = @parent.interface!
    f = (a,b) ~>
      Promise.resolve!
        .then -> p(a,b)
        .then (g) ~>
          if !(g and g.user.key) => return
          # @servebase/consent is under developmenet. may change any time
          @core.ldcvmgr.get {name: '@servebase/consent', path: 'cookie'}
  init: (o) ->
    ({core}) <~ servebase.corectx _
    @manager = o.manager
    @core = core
