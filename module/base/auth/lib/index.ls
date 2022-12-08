require! <[fs chokidar lderror jsonwebtoken express-session passport passport-local]>
require! <[passport-facebook]>
require! <[passport-google-oauth20]>
require! <[passport-line-auth]>
require! <[@servebase/backend/aux ./passwd ./mail]>

(backend) <- ((f) -> module.exports = -> f.call {}, it) _
{db,app,config,route} = backend

captcha = Object.fromEntries [[k,v] for k,v of config.captcha].map ->
  if it.0 == \enabled => [it.0, it.1] else [it.0, it.1{sitekey, enabled}]

limit-session-amount = false

get-user = ({username, password, method, detail, create, cb, req}) ->
  db.user-store.get {username, password, method, detail, create}
    .then (user) !->
      db.query "select count(ip) from session where owner = $1 group by ip", [user.key]
        .then (r={}) ->
          # by default disabled - session amount limitation
          if limit-session-amount and ((r.[]rows.0 or {}).count or 1) > 1 => cb lderror(1004), null, {message: ''}
          else cb null, (user <<< {ip: aux.ip(req)})
    .catch (e) ->
      e = if lderror.id(e) => e else lderror 500
      cb e, null, {message: ''}

strategy = do
  local: (opt) ->
    passport.use new passport-local.Strategy {
      usernameField: \username, passwordField: \password
      passReqToCallback: true
    }, (req, username,password,cb) ~>
      get-user {username, password, method: \local, detail: null, create: false, cb, req}

  google: (opt) ->
    passport.use new passport-google-oauth20.Strategy(
      do
        clientID: opt.clientID
        clientSecret: opt.clientSecret
        callbackURL: "/api/auth/google/callback"
        passReqToCallback: true
        userProfileURL: 'https://www.googleapis.com/oauth2/v3/userinfo'
        profileFields: ['id', 'displayName', 'link', 'emails']
      , (req, access-token, refresh-token, profile, cb) !->
        if !profile.emails => cb null, false, {}
        else get-user {
          username: profile.emails.0.value, password: null
          method: \google, detail: profile, create: true, cb, req
        }
    )

  facebook: (opt) ->
    passport.use new passport-facebook.Strategy(
      do
        clientID: opt.clientID
        clientSecret: opt.clientSecret
        passReqToCallback: true
        callbackURL: "/api/auth/facebook/callback"
        profileFields: ['id', 'displayName', 'link', 'emails']
      , (req, access-token, refresh-token, profile, cb) !->
        if !profile.emails => cb null, false, {}
        else get-user {
          username: profile.emails.0.value, password: null
          method: \facebook, detail: profile, create: true, cb, req
        }
    )

  line: (opt) ->
    passport.use new passport-line-auth.Strategy(
      do
        channelID: opt.channelID
        channelSecret: opt.channelSecret
        callbackURL: "/api/auth/line/callback"
        scope: <[profile openid email]>
        botPrompt: \normal
        passReqToCallback: true
        prompt: 'consent'
        uiLocales: \zh-TW
      , (req, access-token, refresh-token, params, profile, cb) !->
        try
          ret = jsonwebtoken.verify params.id_token, opt.channelSecret
          if !(ret and ret.email) => throw new Error('')
          get-user {
            username: ret.email, password: null
            method: \line, detail: profile, create: true, cb, req
          }
        catch e
          console.log e
          cb null, false, {}
    )

@version = 'na'
chokidar.watch <[.version]>
  .on \add, (~> @version = (fs.read-file-sync it .toString!) )
  .on \change, (~> @version = (fs.read-file-sync it .toString!) )


# =============== USER DATA, VIA AJAX
# Note: jsonp might lead to exploit since jsonp is not protected by CORS.
# * this cant be protected by CSRF, since it provides CSRF token.
# * this must be protected by CORS Policy, otherwise 3rd website can get user info easily.
# * this is passed via cookie too, but cookie won't be set if user doesn't get files served from express.
#   so, for the first time user we still have to do ajax.
#   cookie will be checked in frontend to see if ajax is needed.
# * user could still alter cookie's content, so it's necessary to force ajax call for important action
#   there is no way to prevent user from altering client side content,
#   so if we want to prevent user from editing our code, we have to go backend for the generation.
route.auth.get \/info, (req, res) ~>
  res.setHeader \content-type, \application/json
  payload = JSON.stringify({
    csrfToken: req.csrfToken!
    production: backend.production
    ip: aux.ip(req)
    user: if req.user => req.user{key, config, displayname, verified, username, staff} else {}
    captcha: captcha
    version: @version
    config: backend.config.client or {}
  })
  res.cookie 'global', payload, { path: '/', secure: true }
  res.send payload

<[local google facebook line]>.for-each (name) ->
  if !config{}auth[name] => return
  strategy[name](config.auth[name])
  route.auth
    ..post "/#name", passport.authenticate name, {scope: <[profile openid email]>}
    ..get "/#name/callback", passport.authenticate name, do
      successRedirect: \/auth?oauth-done
      failureRedirect: \/auth?oauth-failed

passport.serializeUser (u,done) !->
  db.user-store.serialize u .then (v) !-> done null, v
passport.deserializeUser (v,done) !->
  db.user-store.deserialize v .then (u = {}) !-> done null, u

# prevent dupsessionid which may block user from correctly login.
# see https://github.com/expressjs/session/issues/881
app.use (req, res, next) ->
  c = ((req.headers or {}).cookie or '')
  cs = c.split /;/ .filter -> /^connect.sid=/.exec(it.trim!)
  return if cs.length > 1 => next {code: \SESSIONCORRUPTED} else next!

app.use backend.session = express-session do
  secret: config.session.secret
  resave: true
  saveUninitialized: true
  store: db.session-store
  proxy: true
  cookie: do
    path: \/
    httpOnly: true
    maxAge: config.session.max-age
app.use passport.initialize!
app.use passport.session!

route.auth
  ..post \/signup, backend.middleware.captcha, (req, res, next) ~>
    {username,displayname,password,config} = req.body{username,displayname,password,config}
    if !username or !displayname or password.length < 8 => return next(lderror 400)
    db.user-store.create {username, password} <<< {
      method: \local, detail: {displayname}, config: (config or {})
    }
      .then (user) ~>
        @mail.verify {req, user}
          .catch (err) ~>
            # only log here so user can continue to login.
            backend.log-mail.error {err}, "send mail verification mail failed (#username)".red
      .then (user) !-> req.login user, !-> res.send!
      .catch !-> next(lderror 403)
  ..post \/login, backend.middleware.captcha, (req, res, next) ->
    ((err,user,info) <- passport.authenticate \local, _
    if err or !user => return next(err or lderror(1000))
    req.login user, (err) !-> if err => next(err) else res.send!
    )(req, res, next)
  ..post \/logout, (req, res) -> req.logout(!-> res.send!)

# identical to `/auth` but if it's more semantic clear.
app.get \/auth/reset, (req, res) ->
  aux.clear-cookie req, res
  <-! req.logout _
  # by rendering instead of redirecting, we can keep the URL as is.
  # in this case a reload after authenticaed will help refresh that page
  # frontend should determine current URL and redirect to landing page if necessary to prevent infinite loop
  res.render "auth/index.pug"

app.post \/api/auth/clear, aux.signedin, backend.middleware.captcha, (req, res) ->
  db.query "delete from session where owner = $1", [req.user.key]
    .then ->
      aux.clear-cookie req, res
      <-! req.logout _
      res.send!

app.post \/api/auth/clear/:uid, aux.is-admin, (req, res) ->
  db.query "delete from session where owner = $1", [req.params.uid] .then -> res.send!

# this must not be guarded by csrf since it's used to recover csrf token.
app.post \/api/auth/reset, (req, res) ->
  aux.clear-cookie req, res
  <-! req.logout _
  res.send!

@passwd = passwd backend
@mail = mail backend
@passwd.route!
@mail.route!

@
