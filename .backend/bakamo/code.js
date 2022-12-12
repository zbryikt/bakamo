// Generated by LiveScript 1.6.0
(function(){
  var lderror, nodeFetch;
  lderror = require('lderror');
  nodeFetch = require('node-fetch');
  (function(it){
    return module.exports = it;
  })(function(backend){
    return function(it){
      return it.apply(backend);
    }(function(){
      var db, ref$, api, app, config, key;
      db = this.db, ref$ = this.route, api = ref$.api, app = ref$.app, config = this.config;
      key = config.google.key;
      return api.get('/code/:isbn', function(req, res){
        var isbn;
        isbn = req.params.isbn;
        if (!/^\d+$/.exec(isbn)) {
          return lderror.reject(400);
        }
        return nodeFetch("https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn + "&key=" + key, {
          method: 'GET',
          type: 'json'
        }).then(function(v){
          return !(v && v.ok)
            ? lderror.reject(404)
            : v.json();
        }).then(function(ret){
          return res.send(ret);
        });
      });
    });
  });
}).call(this);