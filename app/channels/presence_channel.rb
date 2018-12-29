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

      participant.present = value
      game.save!
    end
  end

  def find_game
    Game.find_by(uid: game_uid)
  end

  def game_uid
    params[:game_uid]
  end
end
