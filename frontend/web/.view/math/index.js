 (function() { function pug_attr(t,e,n,r){if(!1===e||null==e||!e&&("class"===t||"style"===t))return"";if(!0===e)return" "+(r?t:t+'="'+t+'"');var f=typeof e;return"object"!==f&&"function"!==f||"function"!=typeof e.toJSON||(e=e.toJSON()),"string"==typeof e||(e=JSON.stringify(e),n||-1===e.indexOf('"'))?(n&&(e=pug_escape(e))," "+t+'="'+e+'"'):" "+t+"='"+e.replace(/'/g,"&#39;")+"'"}
function pug_attrs(t,r){var a="";for(var s in t)if(pug_has_own_property.call(t,s)){var u=t[s];if("class"===s){u=pug_classes(u),a=pug_attr(s,u,!1,r)+a;continue}"style"===s&&(u=pug_style(u)),a+=pug_attr(s,u,!1,r)}return a}
function pug_classes(s,r){return Array.isArray(s)?pug_classes_array(s,r):s&&"object"==typeof s?pug_classes_object(s):s||""}
function pug_classes_array(r,a){for(var s,e="",u="",c=Array.isArray(a),g=0;g<r.length;g++)(s=pug_classes(r[g]))&&(c&&a[g]&&(s=pug_escape(s)),e=e+u+s,u=" ");return e}
function pug_classes_object(r){var a="",n="";for(var o in r)o&&r[o]&&pug_has_own_property.call(r,o)&&(a=a+n+o,n=" ");return a}
function pug_escape(e){var a=""+e,t=pug_match_html.exec(a);if(!t)return e;var r,c,n,s="";for(r=t.index,c=0;r<a.length;r++){switch(a.charCodeAt(r)){case 34:n="&quot;";break;case 38:n="&amp;";break;case 60:n="&lt;";break;case 62:n="&gt;";break;default:continue}c!==r&&(s+=a.substring(c,r)),c=r+1,s+=n}return c!==r?s+a.substring(c,r):s}
var pug_has_own_property=Object.prototype.hasOwnProperty;
var pug_match_html=/["&<>]/;
function pug_merge(e,r){if(1===arguments.length){for(var t=e[0],g=1;g<e.length;g++)t=pug_merge(t,e[g]);return t}for(var l in r)if("class"===l){var n=e[l]||[];e[l]=(Array.isArray(n)?n:[n]).concat(r[l]||[])}else if("style"===l){var n=pug_style(e[l]);n=n&&";"!==n[n.length-1]?n+";":n;var a=pug_style(r[l]);a=a&&";"!==a[a.length-1]?a+";":a,e[l]=n+a}else e[l]=r[l];return e}
function pug_style(r){if(!r)return"";if("object"==typeof r){var t="";for(var e in r)pug_has_own_property.call(r,e)&&(t=t+e+":"+r[e]+";");return t}return r+""}function template(locals) {var pug_html = "", pug_mixins = {}, pug_interp;;
    var locals_for_with = (locals || {});
    
    (function (Array, JSON, b64img, blockLoader, c, cssLoader, ctrl, decache, defer, escape, libLoader, parentName, prefix, scriptLoader, url, version) {
      pug_html = pug_html + "\u003C!DOCTYPE html\u003E";
if(!libLoader) {
  libLoader = {
    js: {url: {}},
    css: {url: {}},
    root: function(r) { libLoader._r = r; },
    _r: "/assets/lib",
    _v: "",
    version: function(v) { libLoader._v = (v ? "?v=" + v : ""); }
  }
  if(version) { libLoader.version(version); }
}

pug_mixins["script"] = pug_interp = function(os,cfg){
var block = (this && this.block), attributes = (this && this.attributes) || {};
if(!Array.isArray(os)) { os = [os]; }
// iterate os
;(function(){
  var $$obj = os;
  if ('number' == typeof $$obj.length) {
      for (var pug_index0 = 0, $$l = $$obj.length; pug_index0 < $$l; pug_index0++) {
        var o = $$obj[pug_index0];
c = o;
if(typeof(o) == "string") { url = o; c = cfg || {};}
else if(o.url) { url = o.url; }
else { url = libLoader._r + "/" + o.name + "/" + (o.version || 'main') + "/" + (o.path || "index.min.js"); }
if (!libLoader.js.url[url]) {
libLoader.js.url[url] = true;
defer = (typeof(c.defer) == "undefined" ? true : !!c.defer);
if (/^https?:\/\/./.exec(url)) {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url, true, true)+pug_attr("defer", defer, true, true)+pug_attr("async", !!c.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
else {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url + libLoader._v, true, true)+pug_attr("defer", defer, true, true)+pug_attr("async", !!c.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
}
      }
  } else {
    var $$l = 0;
    for (var pug_index0 in $$obj) {
      $$l++;
      var o = $$obj[pug_index0];
c = o;
if(typeof(o) == "string") { url = o; c = cfg || {};}
else if(o.url) { url = o.url; }
else { url = libLoader._r + "/" + o.name + "/" + (o.version || 'main') + "/" + (o.path || "index.min.js"); }
if (!libLoader.js.url[url]) {
libLoader.js.url[url] = true;
defer = (typeof(c.defer) == "undefined" ? true : !!c.defer);
if (/^https?:\/\/./.exec(url)) {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url, true, true)+pug_attr("defer", defer, true, true)+pug_attr("async", !!c.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
else {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url + libLoader._v, true, true)+pug_attr("defer", defer, true, true)+pug_attr("async", !!c.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
}
    }
  }
}).call(this);

};
pug_mixins["css"] = pug_interp = function(os,cfg){
var block = (this && this.block), attributes = (this && this.attributes) || {};
if(!Array.isArray(os)) { os = [os]; }
// iterate os
;(function(){
  var $$obj = os;
  if ('number' == typeof $$obj.length) {
      for (var pug_index1 = 0, $$l = $$obj.length; pug_index1 < $$l; pug_index1++) {
        var o = $$obj[pug_index1];
c = o;
if(typeof(o) == "string") { url = o; c = cfg || {};}
else if(o.url) { url = o.url; }
else { url = libLoader._r + "/" + o.name + "/" + (o.version || 'main') + "/" + (o.path || "index.min.css"); }
if (!libLoader.css.url[url]) {
libLoader.css.url[url] = true;
pug_html = pug_html + "\u003Clink" + (" rel=\"stylesheet\" type=\"text\u002Fcss\""+pug_attr("href", url + libLoader._v, true, true)) + "\u003E";
}
      }
  } else {
    var $$l = 0;
    for (var pug_index1 in $$obj) {
      $$l++;
      var o = $$obj[pug_index1];
c = o;
if(typeof(o) == "string") { url = o; c = cfg || {};}
else if(o.url) { url = o.url; }
else { url = libLoader._r + "/" + o.name + "/" + (o.version || 'main') + "/" + (o.path || "index.min.css"); }
if (!libLoader.css.url[url]) {
libLoader.css.url[url] = true;
pug_html = pug_html + "\u003Clink" + (" rel=\"stylesheet\" type=\"text\u002Fcss\""+pug_attr("href", url + libLoader._v, true, true)) + "\u003E";
}
    }
  }
}).call(this);

};
if (!(libLoader || scriptLoader)) {
if(!scriptLoader) { scriptLoader = {url: {}, config: {}}; }
if(!decache) { decache = (version? "?v=" + version : ""); }
pug_mixins["script"] = pug_interp = function(url,config){
var block = (this && this.block), attributes = (this && this.attributes) || {};
scriptLoader.config = (config ? config : {});
if (!scriptLoader.url[url]) {
scriptLoader.url[url] = true;
if (/^https?:\/\/./.exec(url)) {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url, true, true)+pug_attr("defer", !!scriptLoader.config.defer, true, true)+pug_attr("async", !!scriptLoader.config.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
else {
pug_html = pug_html + "\u003Cscript" + (" type=\"text\u002Fjavascript\""+pug_attr("src", url + decache, true, true)+pug_attr("defer", !!scriptLoader.config.defer, true, true)+pug_attr("async", !!scriptLoader.config.async, true, true)) + "\u003E\u003C\u002Fscript\u003E";
}
}
};
if(!cssLoader) { cssLoader = {url: {}}; }
pug_mixins["css"] = pug_interp = function(url,config){
var block = (this && this.block), attributes = (this && this.attributes) || {};
cssLoader.config = (config ? config : {});
if (!cssLoader.url[url]) {
cssLoader.url[url] = true;
pug_html = pug_html + "\u003Clink" + (" rel=\"stylesheet\" type=\"text\u002Fcss\""+pug_attr("href", url + decache, true, true)) + "\u003E";
}
};
if(!blockLoader) { blockLoader = {name: {}, config: {}}; }







}
var escjson = function(obj) { return 'JSON.parse(unescape("' + escape(JSON.stringify(obj)) + '"))'; };
var eschtml = (function() { var MAP = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&#34;', "'": '&#39;' }; var repl = function(c) { return MAP[c]; }; return function(s) { return s.replace(/[&<>'"]/g, repl); }; })();
function ellipsis(str, len) {
  return ((str || '').substring(0, len || 200) + (((str || '').length > (len || 200)) ? '...' : ''));
}

pug_mixins["nbr"] = pug_interp = function(count){
var block = (this && this.block), attributes = (this && this.attributes) || {};
for (var i = 0; i < count; i++)
{
pug_html = pug_html + "\u003Cbr\u003E";
}
};






var b64img = {};
b64img.px1 = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEAAAAALAAAAAABAAEAAAIA"
var loremtext = {
  zh: "料何緊許團人受間口語日是藝一選去，得系目、再驗現表爸示片球法中轉國想我樹我，色生早都沒方上情精一廣發！能生運想毒一生人一身德接地，說張在未安人、否臺重壓車亞是我！終力邊技的大因全見起？切問去火極性現中府會行多他千時，來管表前理不開走於展長因，現多上我，工行他眼。總務離子方區面人話同下，這國當非視後得父能民觀基作影輕印度民雖主他是一，星月死較以太就而開後現：國這作有，他你地象的則，引管戰照十都是與行求證來亞電上地言裡先保。大去形上樹。計太風何不先歡的送但假河線己綠？計像因在……初人快政爭連合多考超的得麼此是間不跟代光離制不主政重造的想高據的意臺月飛可成可有時情乎為灣臺我養家小，叫轉於可！錢因其他節，物如盡男府我西上事是似個過孩而過要海？更神施一關王野久沒玩動一趣庭顧倒足要集我民雲能信爸合以物頭容戰度系士我多學一、區作一，過業手：大不結獨星科表小黨上千法值之兒聲價女去大著把己。",
  en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
};













prefix = function(n) { return (!n?[]:(Array.isArray(n)?n:[n])).map(function(it){ return `${prefix.currentName}$${it}`; }).join(' ');}
pug_mixins["scope"] = pug_interp = function(name){
var block = (this && this.block), attributes = (this && this.attributes) || {};
var prentName = prefix.currentName;
prefix.currentName = name;
if (attributes.class && /naked-scope/.exec(attributes.class)) {
block && block();
}
else {
pug_html = pug_html + "\u003Cdiv" + (pug_attrs(pug_merge([{"ld-scope": pug_escape(name || '')},attributes]), true)) + "\u003E";
block && block();
pug_html = pug_html + "\u003C\u002Fdiv\u003E";
}
prefix.currentName = parentName;
};






pug_html = pug_html + "\u003Chtml\u003E\u003Chead\u003E\u003Cmeta charset=\"utf-8\"\u003E\u003Cmeta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"\u003E\u003Ctitle\u003EBAKAMO\u003C\u002Ftitle\u003E";
pug_mixins["css"]([
      {name: "bootstrap", path: "dist/css/bootstrap.min.css"},
      {name: "@loadingio/bootstrap.ext"},
      {name: "lddatetimepicker"},
      {name: "ldiconfont"},
      {name: "ldcover"},
      {url: "/css/index.min.css"}
    ]);
pug_html = pug_html + "\u003Cstyle type=\"text\u002Fcss\"\u003Ebody{font-weight:700;font-family:consolas,monospace}.question{font-size:5em}.blink{animation:blink .66s infinite}.num{width:1.5em;text-align:center}.elapsed{font-size:.5em}.result{font-family:'ldi';font-size:.85em;margin-left:.5em}.result.correct{color:#2d2}.result.correct:before{content:\"\\f00d\"}.result.wrong{color:#d22}.result.wrong:before{content:\"\\f065\"}@-moz-keyframes blink{0%{opacity:1}50%{opacity:1}50.1%{opacity:0}100%{opacity:0}}@-webkit-keyframes blink{0%{opacity:1}50%{opacity:1}50.1%{opacity:0}100%{opacity:0}}@-o-keyframes blink{0%{opacity:1}50%{opacity:1}50.1%{opacity:0}100%{opacity:0}}@keyframes blink{0%{opacity:1}50%{opacity:1}50.1%{opacity:0}100%{opacity:0}}\u003C\u002Fstyle\u003E\u003C\u002Fhead\u003E\u003Cbody\u003E";
if(!ctrl) { ctrl = {}; }
if(!ctrl.navtop) { ctrl.navtop = {}; }
pug_mixins["scope"].call({
block: function(){
pug_html = pug_html + "\u003Cdiv class=\"navbar navbar-expand-lg navbar-light fixed-top\" ld=\"root\"\u003E\u003Cdiv class=\"collapse navbar-collapse\"\u003E\u003Ca class=\"d-flex align-items-center\" href=\"\u002F\" style=\"font-size:24px;line-height:1em\"\u003E\u003Cdiv class=\"font-weight-bold text-sm text-dark\"\u003EBAKAMO\u003C\u002Fdiv\u003E\u003C\u002Fa\u003E\u003Cdiv class=\"ml-auto\"\u003E\u003Cul class=\"navbar-nav ml-4\"\u003E\u003Cli class=\"nav-item d-none\" ld=\"unauthed login\"\u003E\u003Ca class=\"nav-link\"\u003E登入\u003C\u002Fa\u003E\u003C\u002Fli\u003E\u003Cli class=\"nav-item d-none\" ld=\"unauthed signup\"\u003E\u003Ca class=\"nav-link\"\u003E註冊\u003C\u002Fa\u003E\u003C\u002Fli\u003E\u003Cli class=\"nav-item dropdown d-none\" ld=\"authed profile\"\u003E\u003Ca class=\"nav-link dropdown-toggle\" href=\"#\" data-toggle=\"dropdown\"\u003E\u003Ci class=\"i-user\"\u003E\u003C\u002Fi\u003E\u003C\u002Fa\u003E\u003Cdiv class=\"dropdown-menu dropdown-menu-right shadow-sm\"\u003E\u003Ca class=\"dropdown-item\" href=\"\u002Fme\u002Fsettings\u002F\"\u003E\u003Cdiv class=\"align-middle text-capitalize text-ellipsis\" ld=\"displayname\"\u003EGreeting!\u003C\u002Fdiv\u003E\u003Cdiv class=\"text-sm align-middle text-ellipsis\" ld=\"username\"\u003E...\u003C\u002Fdiv\u003E\u003C\u002Fa\u003E\u003Cdiv class=\"dropdown-divider\"\u003E\u003C\u002Fdiv\u003E\u003Ca class=\"dropdown-item\" href=\"\u002Fme\u002Fsettings\u002F\"\u003E設定\u003C\u002Fa\u003E\u003Cdiv class=\"dropdown-divider\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"dropdown-item text-danger\" ld=\"logout\"\u003E登出\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fli\u003E\u003C\u002Ful\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E";
}
}, "navtop");
if (ctrl.navtop.placeholder) {
pug_mixins["nbr"](2);
}
pug_html = pug_html + "\u003Cdiv class=\"w-100 h-100\"\u003E\u003Cdiv class=\"position-absolute\" style=\"left:1em;top:5em\"\u003E\u003Cdiv class=\"d-flex g-2\" ld-each=\"rank\"\u003E\u003Cdiv ld=\"rank\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv ld=\"user\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv ld=\"elapsed\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv ld=\"rate\"\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"d-flex align-items-center justify-content-center w-100 h-100\"\u003E\u003Cdiv\u003E\u003Cdiv\u003E\u003Cdiv class=\"d-flex question done align-items-center\" ld-each=\"q\"\u003E\u003Cdiv class=\"num\" ld=\"n1\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E+\u003C\u002Fdiv\u003E\u003Cdiv class=\"num\" ld=\"n2\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E-\u003C\u002Fdiv\u003E\u003Cdiv class=\"num\" ld=\"n3\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E=\u003C\u002Fdiv\u003E\u003Cdiv class=\"num\" ld=\"ans\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv class=\"result\" ld=\"result\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"elapsed\" ld=\"elapsed\"\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"d-flex question align-items-center\"\u003E\u003Cdiv class=\"num\" ld=\"n1\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E+\u003C\u002Fdiv\u003E\u003Cdiv class=\"num\" ld=\"n2\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E-\u003C\u002Fdiv\u003E\u003Cdiv class=\"num\" ld=\"n3\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv\u003E=\u003C\u002Fdiv\u003E\u003Cdiv class=\"num d-flex\"\u003E\u003Cdiv ld=\"ans\"\u003E0\u003C\u002Fdiv\u003E\u003Cdiv class=\"blink\"\u003E_\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"result\" ld=\"result\"\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E\u003Cdiv class=\"position-absolute mx-auto text-center\" style=\"bottom:2em;font-size:2em;font-weight:700;left:0;right:0;width:fit-content\"\u003E\u003Cdiv ld=\"tick\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv ld=\"avg\"\u003E\u003C\u002Fdiv\u003E\u003Cdiv\u003E正確率 \u003Cspan ld=\"rate\"\u003E\u003C\u002Fspan\u003E%\u003C\u002Fdiv\u003E\u003C\u002Fdiv\u003E";
pug_mixins["script"]([
      {name: "i18next", path: "dist/umd/i18next.min.js"},
      {name: "i18next-browser-languagedetector", path: "dist/umd/i18nextBrowserLanguageDetector.min.js"},
      {name: "bootstrap.native", path: "dist/bootstrap-native-v4.min.js"},
      {name: "proxise"},
      {name: "@loadingio/debounce.js"},
      {name: "@loadingio/ldquery"},
      {name: "@loadingio/ldc"},
      {name: "dayjs", path: "dayjs.min.js"},
      {name: "zmgr"},
      {name: "ldview"},
      {name: "ldcover"},
      {name: "ldnotify"},
      {name: "ldcvmgr"},
      {name: "lderror"},
      {name: "ldloader"},
      {name: "lddatetimepicker"},
      {name: "@plotdb/httputil"},
      {name: "@plotdb/semver"},
      {name: "@plotdb/rescope"},
      {name: "@plotdb/csscope"},
      {name: "@plotdb/block"},
      {name: "@servebase/auth"},
      {name: "@servebase/consent"},
      {name: "@servebase/captcha"},
      {name: "@servebase/erratum"},
      {name: "@servebase/core"},
      {name: "@servebase/connector"},
      {name: "@servebase/navtop"},
      {name: "@undecaf/zbar-wasm", path: "dist/index.js"},
      {name: "@undecaf/barcode-detector-polyfill", path: "dist/index.js"},
      {url: "/js/site.min.js"}
    ]);
pug_html = pug_html + "\u003Cscript type=\"module\"\u003Eservebase.corectx(function(n){var t,o,u,e,a,r,c;t=n.core;o={correct:new Audio(\"\u002Fassets\u002Fsfx\u002Fcorrect.mp3\"),wrong:new Audio(\"\u002Fassets\u002Fsfx\u002Fwrong.mp3\")};u={q:[],stat:{count:0,t:0}};e=function(){return ld$.fetch(\"\u002Fapi\u002Fscore\",{method:\"GET\"},{type:\"json\"}).then(function(n){return u.ranking=n.splice(0,15)})};a=new ldview({initRender:false,root:document.body,text:{n1:function(n){var t;t=n.node;return u.n1},n2:function(n){var t;t=n.node;return u.n2},n3:function(n){var t;t=n.node;return u.n3},ans:function(){return u.ans||\"\"},avg:function(){return(u.stat.t\u002F(1e3*(u.stat.count||1))).toFixed(1)+\"s\"},rate:function(){return(100*u.q.filter(function(n){return n.result===\"correct\"}).length\u002F(u.q.length||1)).toFixed(1)}},handler:{result:function(n){var t;t=n.node;return t.setAttribute(\"class\",\"result \"+(u.result||\"\"))},rank:{list:function(){return u.ranking.map(function(n,t){return n.rank=t+1,n})},key:function(n){return n.key},view:{text:{rank:function(n){var t;t=n.ctx;return t.rank},user:function(n){var t;t=n.ctx;return t.displayname},elapsed:function(n){var t;t=n.ctx;return t.elapsed.toFixed(2)+\"s\"},rate:function(n){var t;t=n.ctx;return(100*(t.correct||0)\u002F(t.correct+t.wrong||1)).toFixed(2)+\"%\"}}}},q:{list:function(){var n;return u.q.slice((n=u.q.length-2)\u003E0?n:0,u.q.length)},view:{text:{n1:function(n){var t,e;t=n.node,e=n.ctx;return e.n1},n2:function(n){var t,e;t=n.node,e=n.ctx;return e.n2},n3:function(n){var t,e;t=n.node,e=n.ctx;return e.n3},ans:function(n){var t;t=n.ctx;return t.ans||\"\"},elapsed:function(n){var t;t=n.ctx;return(t.elapsed\u002F1e3).toFixed(1)+\"s\"}},handler:{result:function(n){var t,e;t=n.node,e=n.ctx;return t.setAttribute(\"class\",\"result \"+(e.result||\"\"))}}}}}});r=function(n){var t;t=a.get(\"tick\");if(u.t==null){u.t=n}u.ct=n;t.textContent=((n-u.t)\u002F1e3).toFixed(1)+\"s\";return requestAnimationFrame(r)};requestAnimationFrame(function(n){return r(n)});document.addEventListener(\"keyup\",function(n){var t,e,r;if(n.keyCode\u003E=48&&n.keyCode\u003C=57){u.ans=(u.ans||\"\")+String.fromCharCode(n.keyCode);return a.render()}else if(n.keyCode===8){t=u.ans||\"\";u.ans=t.substring(0,(e=t.length-1)\u003E0?e:0);return a.render()}else if(n.keyCode===13){r={n1:u.n1,n2:u.n2,n3:u.n3,ans:u.ans};r.elapsed=u.ct-u.t;delete u.t;if(r.n1+r.n2-r.n3===+r.ans){u.stat.t+=r.elapsed;u.stat.count+=1;o.correct.play();r.result=\"correct\"}else{o.wrong.play();r.result=\"wrong\"}u.q.push(r);u.ans=\"\";return c()}});c=function(){var n,t;if(u.q.length\u003E=20){n={correct:u.q.filter(function(n){return n.result===\"correct\"}).length,wrong:u.q.filter(function(n){return n.result===\"wrong\"}).length,elapsed:u.stat.t\u002F(1e3*(u.q.length||1)),slug:\"math-add-sub-1\"};t=(100*(n.correct\u002F(u.q.length||1))).toFixed(2);alert(\"做答結束！你的正確率: \"+t+\"%, 平均費時: \"+n.elapsed.toFixed(2)+\"s\");ld$.fetch(\"\u002Fapi\u002Fscore\u002F\",{method:\"POST\"},{json:n}).then(function(){return window.location.reload(true)})}u.n1=Math.round(Math.random()*4)+6;u.n2=Math.round(Math.random()*6)+3;u.n3=Math.round(Math.random()*5)+1;return a.render()};return Promise.resolve().then(function(){return e()}).then(function(){return c()})});\u003C\u002Fscript\u003E\u003C\u002Fbody\u003E\u003C\u002Fhtml\u003E";
    }.call(this, "Array" in locals_for_with ?
        locals_for_with.Array :
        typeof Array !== 'undefined' ? Array : undefined, "JSON" in locals_for_with ?
        locals_for_with.JSON :
        typeof JSON !== 'undefined' ? JSON : undefined, "b64img" in locals_for_with ?
        locals_for_with.b64img :
        typeof b64img !== 'undefined' ? b64img : undefined, "blockLoader" in locals_for_with ?
        locals_for_with.blockLoader :
        typeof blockLoader !== 'undefined' ? blockLoader : undefined, "c" in locals_for_with ?
        locals_for_with.c :
        typeof c !== 'undefined' ? c : undefined, "cssLoader" in locals_for_with ?
        locals_for_with.cssLoader :
        typeof cssLoader !== 'undefined' ? cssLoader : undefined, "ctrl" in locals_for_with ?
        locals_for_with.ctrl :
        typeof ctrl !== 'undefined' ? ctrl : undefined, "decache" in locals_for_with ?
        locals_for_with.decache :
        typeof decache !== 'undefined' ? decache : undefined, "defer" in locals_for_with ?
        locals_for_with.defer :
        typeof defer !== 'undefined' ? defer : undefined, "escape" in locals_for_with ?
        locals_for_with.escape :
        typeof escape !== 'undefined' ? escape : undefined, "libLoader" in locals_for_with ?
        locals_for_with.libLoader :
        typeof libLoader !== 'undefined' ? libLoader : undefined, "parentName" in locals_for_with ?
        locals_for_with.parentName :
        typeof parentName !== 'undefined' ? parentName : undefined, "prefix" in locals_for_with ?
        locals_for_with.prefix :
        typeof prefix !== 'undefined' ? prefix : undefined, "scriptLoader" in locals_for_with ?
        locals_for_with.scriptLoader :
        typeof scriptLoader !== 'undefined' ? scriptLoader : undefined, "url" in locals_for_with ?
        locals_for_with.url :
        typeof url !== 'undefined' ? url : undefined, "version" in locals_for_with ?
        locals_for_with.version :
        typeof version !== 'undefined' ? version : undefined));
    ;;return pug_html;}; module.exports = template; })() 