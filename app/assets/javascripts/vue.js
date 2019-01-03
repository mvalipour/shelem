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
      join() {
        axios.post(
          ['/games', this.uid, 'join'].join('/'),
          {},
          { headers: { 'X-CSRF-Token': meta('csrf-token') } }
        ).then(response => {
          console.log(response.data); this.changeData(response.data)
        })
      }
    }
  });
  window.VUE_APP = app;
});
