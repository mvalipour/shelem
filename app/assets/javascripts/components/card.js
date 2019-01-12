const Vue = require('vue');

Vue.component('card', {
  props: ['number'],
  template: `
    <div class='flip-container'>
      <div class='flipper'>
        <div class='front'>
          <div v-bind:class="['pc', typeof number === 'number' ? 'no-'+number : '']"></div>
        </div>
        <div class='back'>
          <div class='pc holder'></div>
        </div>
      </div>
    </div>
  `
})
