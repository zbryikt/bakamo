module.exports =
  pkg:
    dependencies: [
      * name: \marked, version: \main, path: \marked.min.js
      * name: \dompurify, version: \main, path: \dist/purify.min.js
      * name: \@servebase/discuss, version: \main, path: \index.min.js
    ]
  init: ({root, ctx, data}) ->
    {marked,discuss} = ctx
    ({core}) <- servebase.corectx _
    disc = new discuss {root, core, slug: 'test', host: (data or {}).host}
    disc.init!
      .then -> disc.load!
      .then -> console.log "discuss loaded."
