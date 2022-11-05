require! <[fs path lderror @servebase/backend/throttle @servebase/backend/aux]>
require! <[@servebase/discuss]>

(backend, {api, app}) <- (->module.exports = it)  _
{db,config} = backend

discuss backend
