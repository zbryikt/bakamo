require! <[fs lderror node-fetch]>
require! <[@servebase/backend/aux]>

(backend) <- (->module.exports = it)  _
<-(->it.apply backend) _

{db,route:{api,app},config} = @

api.post \/score, aux.signedin, (req, res, next) ->
  {correct, wrong, elapsed, slug} = req.body{correct, wrong, elapsed, slug}
  db.query "insert into score (owner, correct, wrong, elapsed, slug) values ($1,$2,$3,$4,$5)",[
    req.user.key, correct, wrong, elapsed, slug
  ]
    .then -> res.send!

api.get \/score, (req, res, next) ->
  db.query """
  select s.key, s.correct, s.wrong, s.elapsed, s.owner, u.displayname from score as s
  left join users as u on u.key = s.owner
  order by s.elapsed
  """
    .then (r={}) -> res.send r.[]rows
