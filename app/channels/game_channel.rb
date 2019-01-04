class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_#{params[:game_uid]}_#{params[:player_index]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
