const ready = require('./ready');
const meta = require('./meta');

const Vue = require('vue');
const axios = require('axios');

ready(() => {
  const data = meta('vue-data') || '{}'
  const app = new Vue({
    el: '#vue-app',
    data: JSON.parse(data),
    methods: {
      changeData(newdata) {
        Object.keys(this.$data).forEach(key => this.$data[key] = null);
        Object.entries(newdata).forEach(entry => Vue.set(this.$data, entry[0], entry[1]));
      },
      action(type, data = {}) {
        axios.post(
          ['/games', this.game.uid, type].join('/'),
          data,
          { headers: { 'X-CSRF-Token': meta('csrf-token') } }
        ).then(response => {
          console.log(response.data); this.changeData(response.data)
        })
      },
      join() { this.action('join') },
      deal() { this.action('deal') },
      start_bidding() { this.action('start_bidding') },
      bid() { this.action('bid', { raise: 5 }) },
      pass() { this.action('pass') },
    }
  });
  window.VUE_APP = app;
});
