route = (o = {}) ->
  supported-actions = <[
    auth
    mail-expire mail-verified
    oauth-done oauth-failed
    passwd-change passwd-expire passwd-done passwd-reset
  ]>

  hash = {}
  (window.location.search or "")
    .replace(/^\?/,'')
    .split(\&)
    .map -> decodeURIComponent(it).split('=')
    .map -> hash[it.0] = it.1

  if !(n = [k for k of hash].filter(->it in supported-actions).0) => n = \auth
  @_manager.from(
    ({name: "@servebase/auth"} <<< (o.bid or {}) <<< {path: n})
    {root: o.root or document.body}
  )

if auth? => auth.prototype.route = route
