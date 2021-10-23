// Generated by LiveScript 1.6.0
(function(){
  var lderror;
  lderror = require('lderror');
  module.exports = {
    'delete': function(arg$){
      var db, key;
      db = arg$.db, key = arg$.key;
      return db.query("delete from session where owner = $1", [key]);
    },
    login: function(arg$){
      var db, key, req;
      db = arg$.db, key = arg$.key, req = arg$.req;
      return db.query("select * from users where key = $1", [key]).then(function(r){
        var user;
        r == null && (r = {});
        if (!(user = (r.rows || (r.rows = []))[0])) {
          return lderror.reject(404);
        }
        return new Promise(function(res, rej){
          return req.login(user, function(e){
            if (e) {
              return rej(e);
            } else {
              return res();
            }
          });
        });
      });
    }
  };
}).call(this);
