const ready = require('./ready');
const meta = require('./meta');

const Vue = require('vue');
const axios = require('axios');

require('./components')

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

ready(() => {
  const app = new Vue({
    el: '#vue-app',
    data: {
      game: {},
      player: {},
      selectedCard: -1,
      selectedCards: [],
      selectedTrumpCards: [],
      bidAmount: 0,
      playerCardSetHidden: true,
      widowSetHidden: true,
      playedSetHidden: [true, true, true, true]
    },
    setters: {
      'game.current_round': function (value, newData) {
        if(this.game.current_round &&
          this.game.current_round.cards.length > 0 &&
          newData.game.last_round &&
          value.cards.length == 0) {
          setTimeout(() => this.game.current_round = value, 2000);
          Vue.set(this.game, 'current_round', newData.game.last_round);
        } else {
          Vue.set(this.game, 'current_round', value);
        }
      }
    },
    watch: {
      'player.cards': function(value) {
        if(!!value) {
          setTimeout(() => this.playerCardSetHidden = false, 300);
        }
      },
      'game.widow_set': function (value) {
        if(this.game.status == 'to_trump') {
          setTimeout(() => this.widowSetHidden = false, 300);
        }
      },
      'game.current_round.cards': function (value) {
        if(!value) { return; }

        setTimeout(() => {
          this.playedSetHidden = this.playedSetHidden.map((_, ix) => typeof value[ix] !== 'number');
        }, 50);
      }
    },
    methods: {
      cardEnabled(number) {
        if(!this.game.current_round) { return true; }
        if(typeof this.game.current_round.suit_i !== 'number') { return true; }
        return this.player.cards[this.game.current_round.suit_i].length > 0 ?
          Math.floor(number / 13) ==  this.game.current_round.suit_i :
          true;
      },
      changeData(newData) {
        ['game', 'player'].forEach(parentKey => this.changeDataParent(parentKey, newData));
      },
      changeDataParent(parentKey, newData) {
        const keys = Object.keys(newData[parentKey]);
        keys.forEach(key => this.changeDataKey(parentKey, key, newData));
      },
      changeDataKey(parentKey, key, newData) {
        let value = newData[parentKey][key];
        const setter = this.$options.setters[parentKey + '.' + key];
        if (setter) {
          setter.apply(this, [value, newData]);
        }
        else {
          Vue.set(this.$data[parentKey], key, value);
        }
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
      bidUp() { this.bidAmount += 5; },
      bidDown() { this.bidAmount -= 5; },
      bid() { this.action('bid', { raise: this.bidAmount }).then(() => this.bidAmount = 0) },
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
      play() {
        this.action('play', { card: this.selectedCard });
      },
      restart() { this.action('restart') },

      selectCard(n) {
        if(this.game.status == 'playing') {
          if(!this.cardEnabled(n)) { return; }
          if(this.selectedCard == n) {
            if(this.game.next_to_play == this.player.index) {
              this.play();
            }
            this.selectedCard = -1;
          } else {
            this.selectedCard = n
          }
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

  // load initial data
  const data = meta('vue-data');
  if(data) {
    app.changeData(JSON.parse(data));
  }

  window.VUE_APP = app;
});
