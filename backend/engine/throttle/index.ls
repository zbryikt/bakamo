require! <[../aux]>

factory = (opt={}) ->
  # TODO we may want to support stores such as Redis by adopting its API directly in store.
  # however this can be abstracted so we won't touch this until we really want to use Redis.
  @store = if opt.store => that
  else if factory.global-store => that
  else factory.global-store = new throttle.store!
  @ <<< {
    span: 1000           # reset request count for every `span`. in ms
    max-count: 10        # return error after request count > `max-count` in each `span`
    delay-count: 5       # start to delay after request count in each span reaches `delay-count`
    delay: 200           # response delay multiplier. in ms
    max-delay: 19000     # maximal delay, in ms.
    key: key.ip          # key generator. by default by ip.
    error: {id: 1024, name: \lderror}
  } <<< opt
  @

factory.prototype = Object.create(Object.prototype) <<< do
  reset: -> @store.reset!
  handler: (req, res, next) ->
    [key, span] = [@key(req), @span]
    # this may be asynchronous. rewrite it if necessary
    [count, reset] = @store.inc key, span
    if count > @max-count => return next(new Error! <<< @error)
    delay = (if count > @delay-count => Math.ceil(((count - @delay-count) ** 1.5) * @delay) else 0) <? @max-delay
    if !res.headers-sent =>
      res.set-header \RateLimit-Limit, @max-count
      res.set-header \RateLimit-Remaining, (@max-count - count)
      res.set-header \RateLimit-Reset, reset
    if !delay => next!
    else setTimeout (->next!), delay

throttle = (opt) ->
  ret = new factory opt
  throttle.factories.push ret
  (req, res, next) -> ret.handler(req, res, next)

throttle.store = ->
  @store = {}
  @time = {}
  # periodically clean internal store to prevent memory consumption over time
  @handler = setInterval (~> @reset!), 86400 * 1000
  @handler.unref! # prevent from preventing process to terminate
  @

throttle.store.prototype = Object.create(Object.prototype) <<< do
  inc: (key, span, delta = 1) ->
    n = Date.now!
    if n - (@time[key] or 0) >= span =>
      @store[key] = 0
      @time[key] = n
    @store[key] = (@store[key] or 0) + delta
    return [@store[key], span - (n - (@time[key] or 0))]
  dec: (key, delta = 1) ->
    @store[key] = ((@store[key] or 0) - delta) >? 0
  reset: (key) !->
    if !(key?) => @ <<< store: {}, time: {}
    else
      @store[key] = 0
      @time[key] = 0

throttle.reset = -> for factory in throttle.factories => factory.reset!
throttle.factories = []

throttle.key = key =
  ip: (req) -> "#{aux.ip req}:#{req.baseUrl}#{req.path}"
  user: (req) -> "#{if req.user => req.user.key else 0}:#{req.baseUrl}#{req.path}"
  ip-user: (req) -> "#{aux.ip req}:#{if req.user => req.user.key else 0}:#{req.baseUrl}#{req.path}"

throttle.kit =
  signup:  throttle span: 10 * 60 * 1000, max-count: 10, delay-count:  5, delay: 400, key: key.ip
  login:   throttle span:  1 * 60 * 1000, max-count: 20, delay-count:  5, delay: 200, key: key.ip
  generic: throttle span:  1 * 60 * 1000, max-count: 30, delay-count: 15, delay: 200, key: key.user

module.exports = throttle
