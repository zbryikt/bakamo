require! <[lderror node-fetch]>

(backend) <- (->module.exports = it)  _
<-(->it.apply backend) _

{db,route:{api,app},config} = @

key = config.google.key

api.get \/code/:isbn, (req, res) ->
  isbn = req.params.isbn
  if !/^\d+$/.exec(isbn) => return lderror.reject 400
  node-fetch(
    "https://www.googleapis.com/books/v1/volumes?q=isbn:#isbn&key=#key",
    {method: \GET, type: \json}
  )
    .then (v) ->
      return if !(v and v.ok) => lderror.reject 404 else v.json!
    .then (ret) -> res.send ret



