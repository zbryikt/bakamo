// Generated by LiveScript 1.6.0
(function(){
  var lderror, suuid, throttle, aux;
  lderror = require('lderror');
  suuid = require('@plotdb/suuid');
  throttle = require('@servebase/backend/throttle');
  aux = require('@servebase/backend/aux');
  (function(it){
    return module.exports = it;
  })(function(arg$){
    var api, route, backend, db, allThread, crud, x$;
    api = arg$.api, route = arg$.route, backend = arg$.backend;
    api = api || {};
    route = route || {};
    db = backend.db;
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
    crud = {
      get: function(req, res){
        var lc, ref$, slug, uri, limit, offset, promise;
        lc = {};
        ref$ = {
          slug: (ref$ = req.query).slug,
          uri: ref$.uri
        }, slug = ref$.slug, uri = ref$.uri;
        if (!(slug || uri)) {
          return allThread(req, res);
        }
        if (!uri) {
          uri = '/';
        }
        limit = isNaN(req.query.limit)
          ? 20
          : (ref$ = +req.query.limit) < 100 ? ref$ : 100;
        offset = isNaN(req.query.offset)
          ? 0
          : +req.query.offset;
        promise = slug
          ? db.query("select key,title from discuss where slug = $1 limit 1", [slug])
          : db.query("select key,title from discuss where uri = $1 limit 1", [uri || '/']);
        return promise.then(function(r){
          var discuss;
          r == null && (r = {});
          lc.discuss = discuss = (r.rows || (r.rows = []))[0];
          if (!discuss) {
            return res.send({});
          }
          return db.query("with obj as (\n  select\n    c as comment,\n    to_json(( select d from ( select u.key, u.displayname ) d)) as \"user\"\n  from comment as c\n  left join users as u\n    on u.key = c.owner\n  where\n    c.discuss = $1 and\n    c.deleted is not true and\n    c.state = 'active'\n  order by distance limit $2 offset $3\n) select row_to_json(o) as ret from obj as o", [discuss.key, limit, offset]).then(function(r){
            r == null && (r = {});
            lc.comments = (r.rows || (r.rows = [])).map(function(it){
              var ref$;
              return ref$ = it.ret.comment, ref$._user = it.ret.user, ref$;
            });
            return api.role({
              users: lc.comments.map(function(it){
                return it.owner;
              })
            });
          }).then(function(r){
            r == null && (r = {});
            lc.roles = r;
            return res.send({
              discuss: lc.discuss,
              comments: lc.comments,
              roles: lc.roles
            });
          });
        });
      },
      post: function(req, res){
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
          if (!lc.uri) {
            lc.uri = '/';
          }
          if (lc.slug) {
            return db.query("select key, slug from discuss where slug = $1", [lc.slug]);
          } else {
            return db.query("select key, slug from discuss where uri = $1", [lc.uri]);
          }
        }).then(function(r){
          r == null && (r = {});
          if ((r.rows || (r.rows = [])).length) {
            return Promise.resolve(r);
          }
          if (!lc.slug) {
            lc.slug = suuid();
          }
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
            : db.query("select count(c.key) as distance, d.key as discuss\nfrom comment as c, discuss as d\nwhere c.reply is null and d.key = $1 and d.key = c.discuss\ngroup by d.key", [lc.discuss.key]);
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
      },
      put: function(req, res){
        var lc;
        if (!req.user) {
          return aux.r404(res);
        }
        lc = {};
        return Promise.resolve().then(function(){
          var ref$;
          lc.content = {
            body: (ref$ = req.body.content).body,
            config: ref$.config
          };
          return db.query("update comment set (content) = ($1)", [lc.content]);
        }).then(function(){
          return res.send();
        })['catch'](aux.errorHandler(res));
      },
      'delete': function(req, res){
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
      }
    };
    if (route.api) {
      x$ = route.api;
      x$.get('/discuss/', crud.get);
      x$.put('/discuss', aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud.put);
      x$.post('/discuss/', aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud.post);
      x$['delete']('/discuss/:id', aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud['delete']);
    }
    return {
      crud: crud
    };
  });
}).call(this);
