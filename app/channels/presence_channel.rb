class PresenceChannel < ApplicationCable::Channel
  def subscribed
    set_presence(true)
  end

  def unsubscribed
    set_presence(false)
  end

  private

  def set_presence(value)
    find_game.tap do |game|
      return unless game
      return unless (participant = game.participants[current_user])
      return unless participant.present != value

      participant.present = value
      game.save!
      publish_event(game)
    end
  end

  def publish_event(game)
    ActionCable.server.broadcast(
      "game_participants_#{game.uid}",
      body: GameSerializer.new(game).to_json
    )
  end

  def find_game
    Game.find_by(uid: game_uid)
  end

  def game_uid
    params[:game_uid]
  end
end
