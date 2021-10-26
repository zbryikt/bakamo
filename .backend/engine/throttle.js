// Generated by LiveScript 1.6.0
(function(){
  var expressRateLimit, expressSlowDown, aux, key, msg;
  expressRateLimit = require('express-rate-limit');
  expressSlowDown = require('express-slow-down');
  aux = require('./aux');
  key = {
    ip: function(req){
      return base.ip(req) + ":" + req.baseUrl + req.path;
    },
    user: function(req){
      return (req.user ? req.user.key : 0) + ":" + req.baseUrl + req.path;
    }
  };
  msg = '{"id": 1024, name: "lderror"}';
  module.exports = {
    rate: {
      signup: expressRateLimit({
        windowMs: 60 * 60 * 1000,
        max: 30,
        message: msg,
        statusCode: 490,
        headers: true,
        keyGenerator: key.ip
      }),
      login: expressRateLimit({
        windowMs: 60 * 1000,
        max: 30,
        message: msg,
        statusCode: 490,
        headers: true,
        keyGenerator: key.ip
      }),
      generic: expressRateLimit({
        windowMs: 60 * 1000,
        max: 30,
        message: msg,
        statusCode: 490,
        headers: true,
        keyGenerator: key.user
      })
    },
    slow: {
      signup: expressSlowDown({
        windowMs: 120 * 60 * 10,
        delayAfter: 15,
        delayMs: 1000,
        maxDelayMs: 20 * 1000,
        headers: true,
        keyGenerator: key.ip
      }),
      login: expressSlowDown({
        windowMs: 1 * 60 * 10,
        delayAfter: 5,
        delayMs: 1000,
        maxDelayMs: 20 * 1000,
        headers: true,
        keyGenerator: key.ip
      }),
      generic: expressSlowDown({
        windowMs: 60 * 1000,
        delayAfter: 15,
        delayMs: 1000,
        maxDelayMs: 15 * 1000,
        headers: true,
        keyGenerator: key.user
      })
    },
    key: key
  };
}).call(this);
