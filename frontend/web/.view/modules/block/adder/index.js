 (function() { function template(locals) {var pug_html = "", pug_mixins = {}, pug_interp;pug_html = pug_html + "\u003Cdiv\u003E\u003Cscript type=\"module\"\u003Emodule.exports={pkg:{extend:{ns:\"local\",name:\"math-test\",dom:true}},init:function(t){var n,r;n=t.pubsub;r=function(){var t,n,r,o,a,e,u;t=Math.round(Math.random()*10);n=Math.round(Math.random()*10);r=t+n;o=Math.floor(Math.random()*6);for(a=0;a\u003C5;++a){e=a;u=Math.random()}return{question:{content:t+\" + \"+n+\" = ?\"},answers:[0,1,2,3,4,5].map(function(t){return{value:r-o+t,idx:t,correct:o-t===0}})}};return n.fire(\"init\",{prompt:r})}};\u003C\u002Fscript\u003E\u003C\u002Fdiv\u003E";;return pug_html;}; module.exports = template; })() 