module.exports =
  pkg:
    dependencies: [
      * name: \@servebase/discuss, version: \main, path: 'index.min.js'
    ]
  init: ({root, ctx}) ->
    {discuss} = ctx
    ({core}) <- servebase.corectx _
    disc = new discuss {root, core, slug: 'test'}
    disc.init!
      .then -> disc.load!
      .then -> console.log "discuss loaded."
