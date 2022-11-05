// Generated by LiveScript 1.6.0
(function(){
  var fs, path, lderror, suuid, throttle, aux;
  fs = require('fs');
  path = require('path');
  lderror = require('lderror');
  suuid = require('@plotdb/suuid');
  throttle = require('@servebase/backend/throttle');
  aux = require('@servebase/backend/aux');
  (function(it){
    return module.exports = it;
  })(function(backend){
    return function(it){
      return it.apply(backend);
    }(function(){
      var db, config, ref$, api, app, session, allThread;
      db = this.db, config = this.config, ref$ = this.route, api = ref$.api, app = ref$.app, session = this.session;
      allThread = function(req, res){
        var limit, ref$, offset;
        limit = isNaN(req.query.limit)
          ? 20
          : (ref$ = +req.query.limit) < 100 ? ref$ : 100;
        offset = isNaN(req.query.offset)
          ? 0
          : +req.query.offset;
        return db.query("select d.title, d.slug, d.createdtime, d.modifiedtime, json_agg(distinct c.owner) as users\nfrom discuss as d\nleft join comment as c on d.key = c.discuss\ngroup by d.key\nlimit $1 offset $2", [limit, offset]).then(function(r){
          r == null && (r = {});
          return res.send(r.rows || (r.rows = []));
        });
      };
      api.get('/discuss/', function(req, res){
        var lc, ref$, slug, uri, limit, offset, promise;
        lc = {};
        ref$ = {
          slug: (ref$ = req.query).slug,
          uri: ref$.uri
        }, slug = ref$.slug, uri = ref$.uri;
        if (!(slug || uri)) {
          return allThread(req, res);
        }
        limit = isNaN(req.query.limit)
          ? 20
          : (ref$ = +req.query.limit) < 100 ? ref$ : 100;
        offset = isNaN(req.query.offset)
          ? 0
          : +req.query.offset;
        promise = slug
          ? db.query("select key,title from discuss where slug = $1 limit 1", [slug])
          : db.query("select key,title from discuss where uri = $1 limit 1", [uri]);
        return promise.then(function(r){
          var discuss;
          r == null && (r = {});
          lc.discuss = discuss = (r.rows || (r.rows = []))[0];
          if (!discuss) {
            return res.send({});
          }
          return db.query("select c.*, u.displayname\nfrom comment as c, users as u\nwhere c.discuss = $1 and c.owner = u.key\nand c.deleted is not true\nand c.state = 'active'\norder by distance limit $2 offset $3", [discuss.key, limit, offset]).then(function(r){
            r == null && (r = {});
            return res.send({
              discuss: lc.discuss,
              comments: r.rows || (r.rows = [])
            });
          });
        });
      });
      api.post('/discuss/', aux.signedin, throttle.kit.generic, backend.middleware.captcha, function(req, res){
        var lc;
        lc = {};
        return Promise.resolve().then(function(){
          var ref$, ref1$;
          if (!req.body) {
            return lderror.reject(400);
          }
          lc.uri = (ref$ = req.body).uri;
          lc.slug = ref$.slug;
          lc.reply = ref$.reply;
          lc.content = ref$.content;
          lc.title = ref$.title;
          lc.content = {
            body: (ref1$ = lc.content || {}).body,
            config: ref1$.config
          };
          if (lc.slug) {
            return db.query("select key, slug from discuss where slug = $1", [lc.slug]);
          } else if (lc.uri) {
            return db.query("select key, slug from discuss where uri = $1", [lc.uri]);
          } else {
            return {};
          }
        }).then(function(r){
          r == null && (r = {});
          if ((r.rows || (r.rows = [])).length) {
            return Promise.resolve(r);
          }
          lc.slug = suuid();
          return db.query("insert into discuss (slug, uri, title) values ($1,$2,$3) returning key", [
            lc.slug, lc.slug
              ? null
              : lc.uri, lc.title || ''
          ]);
        }).then(function(r){
          r == null && (r = {});
          lc.discuss = (r.rows || (r.rows = []))[0] || {};
          if (!lc.discuss.key) {
            return aux.reject(400);
          }
          if (!lc.discuss.slug) {
            lc.discuss.slug = lc.slug;
          }
          return lc.reply
            ? db.query("select c.* from comment as c\nwhere key = $1 and c.deleted is not true and c.state = 'active'", [lc.reply])
            : db.query("select count(c.key) as distance, d.key as discuss\nfrom comment as c, discuss as d \nwhere c.reply is null and d.key = $1 and d.key = c.discuss\ngroup by d.key", [lc.discuss.key]);
        }).then(function(r){
          var ret, distance;
          r == null && (r = {});
          ret = (r.rows || (r.rows = []))[0] || {};
          distance = isNaN(+ret.distance)
            ? 0
            : +ret.distance;
          lc.distance = distance + 1;
          lc.state = 'active';
          return db.query("insert into comment\n(owner,discuss,distance,content,state,reply) values ($1,$2,$3,$4,$5,$6)\nreturning key", [req.user.key, lc.discuss.key, lc.distance, lc.content, lc.state, lc.reply]);
        }).then(function(r){
          r == null && (r = {});
          lc.ret = (r.rows || (r.rows = []))[0] || {};
          lc.ret.slug = lc.discuss.slug;
          return db.query("update discuss set modifiedtime = now()");
        }).then(function(){
          return res.send(lc.ret);
        });
      });
      /*
      api.put \/discuss, (req, res) ->
        if !req.user => return aux.r404 res
        lc = {}
        Promise.resolve!
          .then ->
            lc.content = req.body.content{body, config}
            db.query "update comment set (content) = ($1)", [lc.content]
          .then -> res.send!
          .catch aux.error-handler res
      */
      return api['delete']('/discuss/:id', aux.signedin, throttle.kit.generic, backend.middleware.captcha, function(req, res){
        var key;
        if (!req.user) {
          return aux.r404(res);
        }
        if (isNaN(key = +req.params.id)) {
          return aux.r404(res);
        }
        return db.query("update comment set deleted = true where key = $1 and owner = $2", [key, req.user.key]).then(function(){
          return res.send();
        });
      });
    });
  });
}).call(this);
