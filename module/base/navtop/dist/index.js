// Generated by LiveScript 1.6.0
(function(){
  ldc.register('navtop', ['core'], function(arg$){
    var core;
    core = arg$.core;
    return core.init().then(function(){
      return function(it){
        return it.apply({});
      }(function(){
        var auth, navtop, view, bar, dotst, tstTgt, that, this$ = this;
        auth = core.auth;
        this.user = core.user;
        this.global = core.global;
        if (!(navtop = ld$.find('[ld-scope=navtop]', 0))) {
          return;
        }
        this.update = function(g){
          var p;
          p = g
            ? Promise.resolve(g)
            : auth.get();
          return p.then(function(g){
            this$.global = g;
            this$.user = g.user || {};
            return view.render();
          });
        };
        auth.on('update', function(g){
          return this$.update(g);
        });
        view = new ldview({
          root: navtop,
          action: {
            click: {
              signup: function(){
                return auth.prompt({
                  tab: 'signup'
                }).then(function(){
                  return this$.update();
                });
              },
              login: function(){
                return auth.prompt({
                  tab: 'login'
                }).then(function(){
                  return this$.update();
                });
              },
              logout: function(){
                return auth.logout().then(function(){
                  return this$.update();
                });
              },
              "set-lng": function(arg$){
                var node, views;
                node = arg$.node, views = arg$.views;
                core.i18n.changeLanguage(node.getAttribute('data-name'));
                return views[0].render('lng');
              }
            }
          },
          text: {
            displayname: function(){
              return this$.user.displayname || 'User';
            },
            username: function(){
              return this$.user.username || 'n/a';
            },
            lng: function(){
              var lng;
              if (!core.i18n) {
                return;
              }
              lng = core.i18n.language;
              return view.getAll('set-lng').filter(function(n){
                return lng === n.getAttribute('data-name');
              }).map(function(n){
                return n.getAttribute('data-alias') || n.innerText.trim();
              })[0] || lng;
            }
          },
          handler: {
            t: function(arg$){
              var node;
              node = arg$.node;
              if (core.i18n) {
                return node.innerText = core.i18n.t(node.textContent);
              }
            },
            admin: function(arg$){
              var node;
              node = arg$.node;
              return node.classList.toggle('d-none', !this$.user.staff);
            },
            unauthed: function(arg$){
              var node;
              node = arg$.node;
              return node.classList.toggle('d-none', !!this$.user.key);
            },
            authed: function(arg$){
              var node;
              node = arg$.node;
              return node.classList.toggle('d-none', !this$.user.key);
            },
            avatar: function(arg$){
              var node;
              node = arg$.node;
              return node.style.backgroundImage = "url(/assets/avatar/" + this$.user.key + ")";
            }
          }
        });
        if (core.i18n) {
          core.i18n.on('languageChanged', function(){
            return view.render('lng');
          });
        }
        bar = view.get('root');
        dotst = (bar.getAttribute('data-classes') || "").split(';').map(function(it){
          return it.split(' ').filter(function(it){
            return it;
          });
        });
        tstTgt = (that = bar.getAttribute('data-pivot')) ? ld$.find(document, that, 0) : null;
        if (!(dotst.length && tstTgt)) {
          return;
        }
        new IntersectionObserver(function(it){
          var n;
          if (!(n = it[0])) {
            return;
          }
          dotst[0].map(function(c){
            return bar.classList.toggle(c, n.isIntersecting);
          });
          if (dotst[1]) {
            return dotst[1].map(function(c){
              return bar.classList.toggle(c, !n.isIntersecting);
            });
          }
        }, {
          threshold: 0.1
        }).observe(tstTgt);
        return {};
      });
    });
  });
}).call(this);
