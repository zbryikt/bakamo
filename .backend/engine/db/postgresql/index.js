// Generated by LiveScript 1.6.0
(function(){
  var pg, lderror, sessionStore, userStore, database;
  pg = require('pg');
  lderror = require('lderror');
  sessionStore = require('./session-store');
  userStore = require('./user-store');
  pg.defaults.poolSize = 30;
  database = function(backend, opt){
    var config, log, ref$, user, password, host, database, port;
    opt == null && (opt = {});
    this.config = config = backend.config;
    this.log = log = backend.log.child({
      module: 'db'
    });
    ref$ = config.db.postgresql, user = ref$.user, password = ref$.password, host = ref$.host, database = ref$.database, port = ref$.port;
    this.uri = "postgres://" + user + ":" + password + "@" + host + (port ? ':' + port : '') + "/" + database;
    this.pool = new pg.Pool({
      connectionString: this.uri,
      max: config.db.postgresql.poolSize || 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000
    });
    this.pool.on('error', function(err, client){
      return log.error("db pool error".red);
    });
    this.sessionStore = new sessionStore({
      db: this,
      session: backend.config.session.maxAge,
      logger: log,
      queryOnly: opt.queryOnly
    });
    this.userStore = new userStore({
      db: this,
      config: config,
      logger: log
    });
    return this;
  };
  database.prototype = import$(Object.create(Object.prototype), {
    query: function(q, p){
      return this.pool.connect().then(function(client){
        return client.query(q, p).then(function(ret){
          client.release();
          return ret;
        });
      })['catch'](function(it){
        return Promise.reject(new lderror({
          err: it,
          id: 0,
          query: q,
          message: "database query error"
        }));
      });
    }
  });
  module.exports = database;
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
