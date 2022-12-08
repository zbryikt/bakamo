require! <[lderror node-fetch]>
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
      v.json!then (ret) -> return {isbn, title: (ret.[]items.0 or {}).{}volumeInfo.title}

api.post \/book/, (req, res) ->
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
          insert into book (isbn,title)
          select * from jsonb_to_recordset($1::jsonb) as e (isbn text, title text)
          """, [JSON.stringify(ret)]
    .then ->
      db.query "select * from book where isbn = ANY($1)", [list]
    .then (r={}) -> res.send r.[]rows

api.post \/read/:key, aux.validate-key, aux.signedin, (req, res) ->
  # TODO we should make it possible to write read records to other account if they agree.
  if req.user.key != req.params.key => return lderror.reject 403
  list = (if Array.isArray(req.body.list) => req.body.list else [req.body.list]).filter(->it and it.book)
  # TODO we may add book here too with fields such as req.body.books
  # this requires additional fields in req.body.list to recognize books to be added
  db.query """
  insert into read (book,date)
  select * from jsonb_to_recordset($1::jsonb) as e (book int, date timestamp)
  """, [JSON.stringify list]
    .then (r={}) ->
      res.send!

api.get \/read/:key, aux.validate-key, aux.signedin, (req, res) ->
  db.query """select * from read where owner = $1""", [req.params.key]
    .then (r={}) -> res.send r.[]rows

/* TODO finish the query for update
api.put \/read/:key/, aux.validate-key, aux.signedin, (req, res) ->
  # TODO we should make it possible to update read records in other account if they agree.
  if req.user.key != req.params.key => return lderror.reject 403
  # TODO we may add book here too with fields such as req.body.books
  # this requires additional fields in req.body.list to recognize books to be added
  db.query """
  update read (book,date) values
  select * from jsonb_to_recordset($1::jsonb) as e (book int, date timestamp)
  """, [JSON.stringify list]
    .then (r={}) ->
      res.send!
*/

api.put \/read/:key/delete, aux.validate-key, aux.signedin, (req, res) ->
  # TODO we should make it possible to delete read records in other account if they agree.
  if req.user.key != req.params.key => return lderror.reject 403
  list = (if Array.isArray(req.body.list) => req.body.list else [req.body.list]).filter(->it and it.key)
  list = list.map -> it.key
  db.query """delete from read where owner = $1 and key in ANY($2)""", [req.user.key, list]
    .then (r={}) -> res.send r.[]rows
