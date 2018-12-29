class ParticipantChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_status_#{params[:game_uid]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
