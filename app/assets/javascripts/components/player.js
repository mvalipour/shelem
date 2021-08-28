const Vue = require('vue');

Vue.component('player', {
  props: ['data', 'name'],
  template: `
    <span class='player-card' v-bind:title='data.name'>
      <img v-bind:src="['https://avatars.dicebear.com/api/human/', data.uid ,'.svg'].join('')" />
      <slot></slot>
    </span>
  `
})
