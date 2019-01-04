class GamesController < ApplicationController
  ADMIN_ACTIONS = %i(deal start_bidding start_game restart)
  PLAYER_ACTIONS = %i(join bid pass trump play)
  
  before_action :ensure_user_uid
  before_action :ensure_admin!, only: ADMIN_ACTIONS
  after_action :publish_event, only: PLAYER_ACTIONS + ADMIN_ACTIONS

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
    change_game { |g| g.add_player!(user_uid, user_name) }
  end

  def deal
    change_game { |g| g.deal! }
  end

  def start_bidding
    change_game { |g| g.start_bidding! }
  end

  def bid
    change_game { |g| g.bid!(user_uid, params.require(:raise)) }
  end

  def pass
    change_game { |g| g.pass!(user_uid) }
  end

  def trump
    change_game { |g| g.trump!(user_uid, params.require(:cards_in), params.require(:cards_out)) }
  end

  def start_game
    change_game { |g| g.start_game! }
  end

  def play
    change_game { |g| g.play!(user_uid, params.require(:card)) }
  end

  def restart
    change_game { |g| g.restart! }
  end

  private

  def change_game
    yield(game)
    game.save!(game_uid)
    render json: view_data
  end

  def publish_event
    return unless game.players
    game.players.uids.each_with_index(&method(:publish_to_player))
  end

  def publish_to_player(uid, index)
    ActionCable.server.broadcast(
      "game_#{game_uid}_#{index}",
      body: view_data(uid).to_json
    )
  end

  def ensure_admin!
    render status: :unauthorized unless user_uid == game.admin_uid
  end

  def view_data(player_uid = user_uid)
    ShelemGameSerializer.new(game, game_uid, player_uid).to_h
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
