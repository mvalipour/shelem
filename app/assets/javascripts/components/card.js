const Vue = require('vue');

Vue.component('card', {
  props: {
    number: { type: Number, default: 0 },
    back: { type: String, default: 'holder' }
  },
  template: `
    <div class='flip-container'>
      <div class='flipper'>
        <div class='front'>
          <div v-bind:class="['pc', typeof number === 'number' ? 'no-'+number : '']"></div>
        </div>
        <div class='back'>
          <div v-bind:class="['pc', back]"></div>
        </div>
      </div>
    </div>
  `
})
