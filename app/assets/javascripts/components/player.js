const Vue = require('vue');

Vue.component('player', {
  props: ['data', 'name'],
  template: `
    <span class='player-card'>
      <img v-bind:src="['https://api.adorable.io/avatars/64/', data.uid ,'.png'].join('')" />
      {{ name == false ? '' : data.name }}
    </span>
  `
})