require! <[fs lderror node-fetch]>
require! <[@servebase/backend/aux]>

(backend) <- (->module.exports = it)  _
<-(->it.apply backend) _

{db,route:{api,app},config} = @

key = config.google.key

book-from-google = ({isbn}) ->
  if !/^\d+$/.exec(isbn) => return {isbn}
  node-fetch(
    "https://www.googleapis.com/books/v1/volumes?q=isbn:#isbn&key=#key",
    {method: \GET, type: \json}
  )
    .then (v) ->
      if !(v and v.ok) => return {isbn}
      v.json!then (ret) ->
        item = (ret.[]items.0 or {})
        title = item.{}volumeInfo.title
        author = item.volumeInfo.[]authors.0 or ''
        thumbnail = item.volumeInfo.{}imageLinks.thumbnail
        return {isbn, title, author, thumbnail, detail: {raw: item, source: 'google book api'}}

api.post \/book/, (req, res) ->
  # TODO also track non-existed isbn that we have tried with book-from-google
  #      reject codes that are not isbn
  list = (if Array.isArray(req.body.list) => req.body.list else [req.body.list]).filter(->it)
  db.query "select * from book where isbn = ANY($1)", [list]
    .then (r={}) ->
      ret = r.[]rows
      isbns = ret.map -> it.isbn
      ps = list
        .filter -> !(it in isbns)
        .map (isbn) -> book-from-google {isbn}
      Promise.all ps
        .then (ret) ->
          ret = ret.filter -> it.title
          db.query """
          insert into book (isbn,title,author,detail)
          select * from jsonb_to_recordset($1::jsonb) as e (isbn text, title text, author text, detail jsonb)
          """, [JSON.stringify(ret)]
    .then ->
      db.query "select * from book where isbn = ANY($1)", [list]
    .then (r={}) -> res.send r.[]rows

api.post \/sudan/:key, aux.validate-key, aux.signedin, (req, res) ->
  # TODO permission check
  sudan = req.params.key
  owner = req.user.key
  list = (if Array.isArray(req.body.list) => req.body.list else [req.body.list])
    .filter -> it and it.book
    .map -> it <<< {owner, sudan}
  # TODO we may add book here too with fields such as req.body.books
  # this requires additional fields in req.body.list to recognize books to be added
  db.query "select key from sudan where key = $1 and owner = $2", [sudan, owner]
    .then (r={}) ->
      if !r.[]rows.length => return lderror.reject 404
      db.query """
      insert into dusu (owner, book, enddate, sudan)
      select * from jsonb_to_recordset($1::jsonb) as e (owner int, book int, enddate timestamp, sudan int)
      """, [JSON.stringify list]
    .then (r={}) -> res.send {}

api.get \/sudan/:key, aux.validate-key, aux.signedin, (req, res) ->
  # TODO permission check
  sudan = req.params.key
  owner = req.user.key
  db.query """
  with merged as (
    select d as dusu, b as book from dusu as d
    left join book as b on b.key = d.book
    inner join sudan as s on s.key = d.sudan
    where d.sudan = $1 and s.owner = $2
  )
  select row_to_json(m.dusu) as dusu, row_to_json(m.book) as book from merged as m
  """, [sudan, owner]
    .then (r={}) -> res.send r.[]rows

api.get \/user/:key/sudan, aux.validate-key, aux.signedin, (req, res) ->
  # TODO permission check
  owner = req.user.key
  db.query """select * from sudan where owner = $1""", [owner]
    .then (r = {}) -> res.send r.[]rows

api.post \/user/:key/sudan, aux.validate-key, aux.signedin, (req, res) ->
  # TODO permission check
  if !req.body.title => return lderror.reject 400
  owner = req.user.key
  db.query """
  insert into sudan (title,description,owner) values ($1, $2, $3) returning key
  """, [req.body.title, (req.body.description or ''), owner]
    .then (r = {}) -> res.send (r.[]rows.0 or {})

