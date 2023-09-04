require! <[lderror @plotdb/suuid]>
require! <[@servebase/backend/throttle @servebase/backend/aux]>

({api, route, backend}) <- (->module.exports = it) _
api = api or {}
route = route or {}
db = backend.db

all-thread = (req, res) ->
  limit = if isNaN(req.query.limit) => 20 else +req.query.limit <? 100
  offset = if isNaN(req.query.offset) => 0 else +req.query.offset
  db.query """
  select d.title, d.slug, d.createdtime, d.modifiedtime, json_agg(distinct c.owner) as users
  from discuss as d
  left join comment as c on d.key = c.discuss
  group by d.key
  limit $1 offset $2
  """, [limit, offset]
    .then (r={}) -> res.send r.[]rows

crud =
  get: (req, res) ->
    lc = {}
    {slug,uri} = req.query{slug, uri}
    # TODO consider user scneario for get without slug or uri
    if !(slug or uri) => return all-thread req, res
    # fallback to '/' if no slug and no uri
    if !uri => uri = \/
    limit = if isNaN(req.query.limit) => 20 else +req.query.limit <? 100
    offset = if isNaN(req.query.offset) => 0 else +req.query.offset
    promise = if slug => db.query "select key,title,slug from discuss where slug = $1 limit 1", [slug]
    else db.query "select key,title,slug from discuss where uri = $1 limit 1", [uri or \/]
    promise
      .then (r={}) ->
        lc.discuss = discuss = r.[]rows.0
        if !discuss => return res.send({})
        db.query """
        with obj as (
          select
            c as comment,
            to_json(( select d from ( select u.key, u.displayname ) d)) as "user"
          from comment as c
          left join users as u
            on u.key = c.owner
          where
            c.discuss = $1 and
            c.deleted is not true and
            c.state = 'active'
          order by distance limit $2 offset $3
        ) select row_to_json(o) as ret from obj as o
        """, [discuss.key, limit, offset]
          .then (r={}) ->
            lc.comments = r.[]rows.map -> it.ret.comment <<< {_user: it.ret.user}
            api.role {discuss, users: lc.comments.map(->it.owner)}
          .then (r={}) ->
            lc.roles = r
            res.send lc{discuss, comments, roles}

  post: (req, res) ->
    lc = {}
    Promise.resolve!
      .then ->
        if !req.body => return lderror.reject 400
        lc <<< req.body{uri, slug, reply, content, title}
        lc.content = (lc.content or {}){body, config}
        # fallback to '/' if no slug and no uri
        if !lc.uri => lc.uri = \/
        if lc.slug => db.query "select key, slug from discuss where slug = $1", [lc.slug]
        else db.query "select key, slug from discuss where uri = $1", [lc.uri]
      .then (r = {}) ->
        if r.[]rows.length => return Promise.resolve(r)
        # new discuss. Since it's new, user should not know its slug.
        if !lc.slug => lc.slug = suuid!
        db.query """
        insert into discuss (slug, uri, title) values ($1,$2,$3) returning key
        """, [lc.slug, (if lc.slug => null else lc.uri), (lc.title or '')]
      .then (r={}) ->
        lc.discuss = (r.[]rows.0 or {})
        if !lc.discuss.key => return aux.reject 400
        if !lc.discuss.slug => lc.discuss.slug = lc.slug
        return if lc.reply =>
          db.query """
          select c.* from comment as c
          where key = $1 and c.deleted is not true and c.state = 'active'
          """, [lc.reply]
        else
          db.query """
          select count(c.key) as distance, d.key as discuss
          from comment as c, discuss as d
          where c.reply is null and d.key = $1 and d.key = c.discuss
          group by d.key
          """, [lc.discuss.key]
      .then (r={}) ->
        ret = (r.[]rows.0 or {})
        distance = (if isNaN(+ret.distance) => 0 else +ret.distance)
        lc <<< distance: (distance + 1), state: \active
        db.query """
        insert into comment
        (owner,discuss,distance,content,state,reply) values ($1,$2,$3,$4,$5,$6)
        returning key
        """, [req.user.key, lc.discuss.key, lc.distance, lc.content, lc.state, lc.reply]
      .then (r={}) ->
        lc.ret = r.[]rows.0 or {}
        lc.ret <<< {slug: lc.discuss.slug}
        db.query "update discuss set modifiedtime = now()"
      .then -> res.send lc.ret
  put: (req, res) ->
    if !req.user => return aux.r404 res
    lc = {}
    Promise.resolve!
      .then ->
        lc.content = req.body.content{body, config}
        db.query "update comment set (content) = ($1)", [lc.content]
      .then -> res.send!
      .catch aux.error-handler res
  delete: (req, res) ->
    if !req.user => return aux.r404 res
    if isNaN(key = +req.params.id) => return aux.r404 res
    db.query "update comment set deleted = true where key = $1 and owner = $2", [key, req.user.key]
      .then -> res.send!

if route.api =>
  route.api
    ..get \/discuss/, crud.get
    ..put \/discuss, aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud.put
    ..post \/discuss/, aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud.post
    ..delete \/discuss/:id, aux.signedin, throttle.kit.generic, backend.middleware.captcha, crud.delete

return {crud}
