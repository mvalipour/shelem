class GamesController < ApplicationController
  ADMIN_ACTIONS = %i(start finish restart)
  before_action :ensure_user_uid
  before_action :ensure_admin!, only: ADMIN_ACTIONS

  after_action :publish_event, only: [:join] + ADMIN_ACTIONS

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

  def join
    game.add_player!(user_uid, user_name)
    game.save!(game_uid)
    render json: view_data
  end

  def deal
    game.deal!
    game.save!(game_uid)
    render json: view_data
  end

  private

  def publish_event
    ActionCable.server.broadcast(
      "game_#{game_uid}",
      body: view_data.to_json
    )
  end

  def ensure_admin!
    render status: :unauthorized unless user_uid == game.admin_uid
  end

  def view_data
    ShelemGameSerializer.new(game, game_uid, user_uid).to_h
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
