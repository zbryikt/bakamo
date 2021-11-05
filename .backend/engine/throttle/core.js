// Generated by LiveScript 1.6.0
(function(){
  var factory, throttle;
  factory = function(opt){
    var that;
    opt == null && (opt = {});
    this.store = (that = opt.store)
      ? that
      : (that = factory.globalStore)
        ? that
        : factory.globalStore = new throttle.store();
    import$((this.span = 1000, this.maxCount = 10, this.delayCount = 5, this.delay = 200, this.maxDelay = 19000, this.key = function(req){
      return req.ip || req.socket.remoteAddress || 'unknown-ip';
    }, this.error = {
      id: 1024,
      name: 'lderror'
    }, this), opt);
    return this;
  };
  factory.prototype = import$(Object.create(Object.prototype), {
    reset: function(){
      return this.store.reset();
    },
    handler: function(req, res, next){
      var ref$, key, span, count, reset, delay, ref1$;
      ref$ = [this.key(req), this.span], key = ref$[0], span = ref$[1];
      ref$ = this.store.inc(key, span), count = ref$[0], reset = ref$[1];
      if (count > this.maxCount) {
        return next(import$(new Error(), this.error));
      }
      delay = (ref$ = count > this.delayCount ? Math.ceil(Math.pow(count - this.delayCount, 1.5) * this.delay) : 0) < (ref1$ = this.maxDelay) ? ref$ : ref1$;
      if (!res.headersSent) {
        res.setHeader('RateLimit-Limit', this.maxCount);
        res.setHeader('RateLimit-Remaining', this.maxCount - count);
        res.setHeader('RateLimit-Reset', reset);
      }
      if (!delay) {
        return next();
      } else {
        return setTimeout(function(){
          return next();
        }, delay);
      }
    }
  });
  throttle = function(opt){
    var ret;
    ret = new factory(opt);
    throttle.factories.push(ret);
    return function(req, res, next){
      return ret.handler(req, res, next);
    };
  };
  throttle.store = function(opt){
    var this$ = this;
    opt == null && (opt = {});
    this.store = {};
    this.time = {};
    this.handler = setInterval(function(){
      return this$.reset();
    }, 86400 * 1000);
    this.handler.unref();
    return this;
  };
  throttle.store.prototype = import$(Object.create(Object.prototype), {
    inc: function(key, span, delta){
      var n;
      delta == null && (delta = 1);
      n = Date.now();
      if (n - (this.time[key] || 0) >= span) {
        this.store[key] = 0;
        this.time[key] = n;
      }
      this.store[key] = (this.store[key] || 0) + delta;
      return [this.store[key], span - (n - (this.time[key] || 0))];
    },
    dec: function(key, delta){
      var ref$;
      delta == null && (delta = 1);
      return this.store[key] = (ref$ = (this.store[key] || 0) - delta) > 0 ? ref$ : 0;
    },
    reset: function(key){
      if (!(key != null)) {
        return this.store = {}, this.time = {}, this;
      } else {
        this.store[key] = 0;
        return this.time[key] = 0;
      }
    }
  });
  throttle.reset = function(){
    var i$, ref$, len$, factory, results$ = [];
    for (i$ = 0, len$ = (ref$ = throttle.factories).length; i$ < len$; ++i$) {
      factory = ref$[i$];
      results$.push(factory.reset());
    }
    return results$;
  };
  throttle.factories = [];
  module.exports = throttle;
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);