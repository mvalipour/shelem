class AdminChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_participants_#{params[:game_uid]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
