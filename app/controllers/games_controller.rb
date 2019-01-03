class GamesController < ApplicationController
  ADMIN_ACTIONS = %i(start finish restart)
  before_action :ensure_user_uid
  before_action :ensure_admin!, only: ADMIN_ACTIONS

  after_action :publish_participant_event, only: [:join]
  after_action :publish_status_event, only: ADMIN_ACTIONS

  def show
    @game_uid = game_uid
    @game = game
    @view_data = view_data
  end

  def create
    game = ShelemGame.new(admin_uid: user_uid).tap do |game|
      game.add_player!(user_uid, user_name)
    end

    uid = game.create!
    redirect_to game_path(uid)
  end

  private

  def publish_status_event; publish_event(:status) end
  def publish_participant_event; publish_event(:participants) end
  def publish_event(type)
    ActionCable.server.broadcast(
      "game_#{type}_#{game.uid}",
      body: view_data.to_json
    )
  end

  def ensure_admin!
    render status: :unauthorized unless user_uid == game.admin_uid
  end

  def view_data
    game.data
  end

  def game_uid
    params[:game_id] || params.require(:id)
  end

  def game
    @_game ||= ShelemGame.find!(game_uid)
  end

  def ensure_user_uid
    unless [user_name, user_uid].all?(&:present?)
      redirect_to user_names_path(return_to: request.path)
    end
  end

  def create_params
    params.permit(:age)
  end
end
