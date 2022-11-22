// Generated by LiveScript 1.6.0
(function(){
  var redis, redisNode;
  redis = require('redis');
  redisNode = function(opt){
    var this$ = this;
    opt == null && (opt = {});
    this.opt = opt;
    this.evtHandler = {};
    this.redis = redis.createClient(opt);
    this.redis.on('error', function(err){
      return this$.fire('error', err);
    });
    return this;
  };
  redisNode.prototype = import$(Object.create(Object.prototype), {
    init: function(){
      return this.redis.connect();
    },
    on: function(n, cb){
      var ref$;
      return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
    },
    fire: function(n){
      var v, res$, i$, to$, ref$, len$, cb, results$ = [];
      res$ = [];
      for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      v = res$;
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    },
    set: function(){
      return this.redis.set.apply(this.redis, arguments);
    },
    get: function(){
      return this.redis.get.apply(this.redis, arguments);
    }
  });
  module.exports = redisNode;
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
