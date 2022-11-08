// Generated by LiveScript 1.6.0
(function(){
  var crypto, bcrypt, lderror, re2, curegex, reEmail, isEmail, userStore;
  crypto = require('crypto');
  bcrypt = require('bcrypt');
  lderror = require('lderror');
  re2 = require('re2');
  curegex = require('curegex');
  reEmail = curegex.tw.get('email', re2);
  isEmail = function(it){
    return reEmail.exec(it);
  };
  userStore = function(opt){
    opt == null && (opt = {});
    this.db = opt.db;
    return this;
  };
  userStore.prototype = import$(Object.create(Object.prototype), {
    serialize: function(u){
      u == null && (u = {});
      return Promise.resolve(u);
    },
    deserialize: function(v){
      v == null && (v = {});
      return Promise.resolve(v);
    },
    hashing: function(password, doMD5, doBcrypt){
      doMD5 == null && (doMD5 = true);
      doBcrypt == null && (doBcrypt = true);
      return new Promise(function(res, rej){
        var ret;
        ret = doMD5 ? crypto.createHash('md5').update(password).digest('hex') : password;
        if (doBcrypt) {
          return bcrypt.genSalt(12, function(e, salt){
            return bcrypt.hash(ret, salt, function(e, hash){
              return res(hash);
            });
          });
        } else {
          return res(ret);
        }
      });
    },
    compare: function(password, hash){
      password == null && (password = '');
      return new Promise(function(res, rej){
        var md5;
        md5 = crypto.createHash('md5').update(password).digest('hex');
        return bcrypt.compare(md5, hash, function(e, ret){
          if (ret) {
            return res();
          } else {
            return rej(new lderror(1012));
          }
        });
      });
    },
    get: function(arg$){
      var username, password, method, detail, create, this$ = this;
      username = arg$.username, password = arg$.password, method = arg$.method, detail = arg$.detail, create = arg$.create;
      username = username.toLowerCase();
      if (!isEmail(username)) {
        return Promise.reject(new lderror(1015));
      }
      return this.db.query("select * from users where username = $1", [username]).then(function(ret){
        var user;
        ret == null && (ret = {});
        if (!(user = (ret.rows || (ret.rows = []))[0]) && !create) {
          return Promise.reject(new lderror(1012));
        }
        if (!user) {
          return this$.create({
            username: username,
            password: password,
            method: method,
            detail: detail
          });
        }
        if (!(method === 'local' || user.method === 'local')) {
          delete user.password;
          return user;
        }
        return this$.compare(password, user.password).then(function(){
          return user;
        });
      }).then(function(user){
        var ref$;
        if (((ref$ = user.config || (user.config = {})).consent || (ref$.consent = {})).cookie) {
          return user;
        }
        user.config.consent.cookie = new Date().getTime();
        return this$.db.query("update users set config = $2 where key = $1", [user.key, user.config]).then(function(){
          return user;
        });
      }).then(function(user){
        delete user.password;
        return user;
      });
    },
    create: function(arg$){
      var username, password, method, detail, config, this$ = this;
      username = arg$.username, password = arg$.password, method = arg$.method, detail = arg$.detail, config = arg$.config;
      username = username.toLowerCase();
      if (!config) {
        config = {};
      }
      if (!isEmail(username)) {
        return Promise.reject(new lderror(1015));
      }
      return Promise.resolve().then(function(){
        if (method === 'local') {
          return this$.hashing(password);
        } else {
          return password;
        }
      }).then(function(password){
        var displayname, user;
        displayname = detail ? detail.displayname || detail.username : void 8;
        if (!displayname) {
          displayname = username.replace(/@[^@]+$/, "");
        }
        (config.consent || (config.consent = {})).cookie = new Date().getTime();
        user = {
          username: username,
          password: password,
          method: method,
          displayname: displayname,
          detail: detail,
          config: config,
          createdtime: new Date()
        };
        return this$.db.query("insert into users (username,password,method,displayname,createdtime,detail,config)\nvalues ($1,$2,$3,$4,$5,$6,$7)\nreturning key", [username, password, method, displayname, new Date().toUTCString(), detail, config]).then(function(r){
          r == null && (r = {});
          if (!(r = (r.rows || (r.rows = []))[0])) {
            return Promise.reject(500);
          }
          return user.key = r.key, user;
        });
      });
    }
  });
  module.exports = userStore;
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
