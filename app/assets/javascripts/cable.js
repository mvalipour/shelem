const ready = require('./ready')
const meta = require('./meta')
const ActionCable = require('actioncable');

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(window);

function updateData(data) {
  window.VUE_APP.changeData(JSON.parse(data.body));
}

function reloadPage() {
  document.location.reload
}

ready(() => {
  const game_uid = meta('game-uid');
  const player_index = meta('player-index');
  if(!game_uid || !player_index) { return; }

  // App.cable.subscriptions.create({
  //   channel: "PresenceChannel",
  //   game_uid: game_uid
  // });

  App.cable.subscriptions.create(
    { channel: 'GameChannel', game_uid: game_uid, player_index: player_index },
    { received: updateData, disconnected: reloadPage }
  );
});
