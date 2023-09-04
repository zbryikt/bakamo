module.exports =
  pkg:
    dependencies: [
      * name: \marked, version: \main, path: \marked.min.js
      * name: \dompurify, version: \main, path: \dist/purify.min.js
      * name: \@servebase/discuss, version: \main, path: \index.min.js
    ]
  init: ({root, ctx, data}) ->
    {marked,discuss} = ctx
    data = data or {}
    ({core}) <- servebase.corectx _
    disc = new discuss {root, core} <<< data{slug, host, uri, config}
    disc.init!
      .then -> disc.load!
      .then -> console.log "discuss loaded."
