const ready = require('./ready');
const meta = require('./meta');

const Vue = require('vue');

ready(() => {
  var data = meta('vue-data') || '{}'
  var app = new Vue({
    el: '#vue-app',
    data: JSON.parse(data)
  });
});
