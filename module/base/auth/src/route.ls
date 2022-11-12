route = (o = {}) ->
  supported-actions = <[
    auth
    mail-expire mail-verified
    oauth-done oauth-failed
    passwd-change passwd-expire passwd-done passwd-reset
  ]>

  if !(n = [k for k of httputil.qs!].filter(->it in supported-actions).0) => n = \auth
  @_manager.from(
    ({name: "@servebase/auth"} <<< (o.bid or {}) <<< {path: n})
    {root: o.root or document.body}
  )

if auth? => auth.prototype.route = route
