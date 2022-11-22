module.exports = do
  # verbose name for user, such as in mail title, etc.
  #  - if omitted, `hostname` below or `aux.hostname(req)` should be used instead.
  sitename: 'servebase'
  # optional domain name.
  #  - dev can still infer domain name in used by `aux.hostname(req)` if omitted,
  #    however this should be used if provided.
  domain: 'serve.base'
  port: 8901
  limit: '20mb'
  i18n:
    enabled: true
    lng: <[en zh-TW]>
    ns: <[default]>
  base: 'base'
  srcbuild: [] # value in `base` will be added by default
  redis:
    enabled: false
    url: \redis://localhost:6379
  db:
    postgresql:
      host: \localhost # host.docker.internal
      port: 15432
      database: \servebase
      user: \servebase
      password: \servebase
      poolSize: 20
  build:
    enabled: true
    watcher: do
      ignored: ['\/\..*\.swp$', '^static/assets/img']
  session:
    secret: 'this-is-a-sample-secret-please-update-it'
    max-age: 365 * 86400 * 1000
  captcha:
    recaptcha:
      sitekey: '...'
      secret: '...'
      enabled: false
    hcaptcha:
      sitekey: '...'
      secret: '...'
      enabled: false
  log:
    level: \info
    # when true, all errors handled in `@servebase/backend/error-handler` will be logged with `debug` level
    all-error: false
  auth:
    # GCP -> API & Services -> Credentials -> OAuth Client ID
    google:
      clientID: '...'
      clientSecret: '...'
    facebook:
      clientID: '...'
      clientSecret: '...'
    line:
      channelID: '...'
      channelSecret: '...'
    local:
      usernameField: \email
      passwordField: \passwd
  mail:
    mailgun: auth:
      domain: '...'
      api_key: '...'
  # additional information passing to client side via api/auth/info.
  # use `global.config` to access this object.
  client: {}
