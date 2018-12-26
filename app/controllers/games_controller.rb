class GamesController < ApplicationController
  before_action :ensure_user_uid
  before_action :ensure_admin!, only: [:start, :finish]

  def show
    game.tap do |game|
      game.add_participant(user_uid, user_name)
      game.save!

      @game = game
      @is_admin = (game.admin_uid == user_uid)
      @participant = game.participants[user_uid]
    end
  end

  def create
    game = Game.new(admin_uid: user_uid).tap do |game|
      game.add_participant(user_uid, user_name)
      game.save!
    end

    redirect_to game_path(game.uid)
  end

  def start
    game.started!
    redirect_to game_path(game.uid)
  end

  def finish
    game.finished!
    redirect_to game_path(game.uid)
  end

  private

  def ensure_admin!
    if game.admin_uid != user_uid
      render status: :unauthorized
    end
  end

  def game
    @_game ||= Game.find_by!(uid: params[:game_id] || params.require(:id))
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
