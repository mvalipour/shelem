const ready = require('./ready')
const meta = require('./meta')
const ActionCable = require('actioncable');

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(window);

ready(() => {
  const game_uid = meta('game-uid');
  if(!game_uid) {
    return;
  }

  App.cable.subscriptions.create({
    channel: "PresenceChannel",
    game_uid: game_uid
  });
});
