class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_uid]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
