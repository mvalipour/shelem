const ready = require('./ready');
const meta = require('./meta');

const Vue = require('vue');
const axios = require('axios');

function toggleElement(array, el) {
  array = array || []
  if(array.indexOf(el) >= 0) {
    return array.filter(x => x != el)
  }
  else {
    if(array.length == 4) {
      array.shift();
    }
    array.push(el)
    return array
  }
}

default_data = {
  selectedCard: -1,
  selectedCards: [],
  selectedTrumpCards: []
}

ready(() => {
  const data = meta('vue-data') || '{}'
  const app = new Vue({
    el: '#vue-app',
    data: Object.assign(JSON.parse(data), default_data),
    methods: {
      changeData(newdata) {
        Object.keys(this.$data).forEach(key => this.$data[key] = null);
        Object.entries(Object.assign(newdata, default_data)).forEach(entry => Vue.set(this.$data, entry[0], entry[1]));
      },
      action(type, data = {}) {
        return axios.post(
          ['/games', this.game.uid, type].join('/'),
          data,
          { headers: { 'X-CSRF-Token': meta('csrf-token') } }
        ).then(response => {
          this.changeData(response.data)
        })
      },
      join() { this.action('join').then(() => document.location.reload()) },
      deal() { this.action('deal') },
      start_bidding() { this.action('start_bidding') },
      bid(r) { this.action('bid', { raise: r }) },
      pass() { this.action('pass') },
      trump() {
        console.log(this.selectedTrumpCards);
        console.log(this.selectedCards);
        if(this.selectedTrumpCards.length != this.selectedCards.length) {
          return;
          // todo: alert user
        }

        this.action('trump', {
          cards_in: this.selectedTrumpCards,
          cards_out: this.selectedCards
        })
      },
      start_game() { this.action('start_game') },
      play() { this.action('play', { card: this.selectedCard }) },
      restart() { this.action('restart') },

      selectCard(n) {
        if(this.game.status == 'playing') {
          this.selectedCard = this.selectedCard == n ? -1 : n;
        }
        else if(this.game.status == 'to_trump') {
          this.selectedCards = toggleElement(this.selectedCards, n)
        }
      },
      selectTrumpCard(n) {
        if(this.game.status == 'to_trump') {
          this.selectedTrumpCards = toggleElement(this.selectedTrumpCards, n)
        }
      },
    }
  });
  window.VUE_APP = app;
});
