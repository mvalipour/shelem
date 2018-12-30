class GamesController < ApplicationController
  ADMIN_ACTIONS = %i(start finish restart)
  before_action :ensure_user_uid
  before_action :ensure_admin!, only: ADMIN_ACTIONS

  after_action :publish_participant_event, only: [:join]
  after_action :publish_status_event, only: ADMIN_ACTIONS

  def show
    @game = game
    @participant = participant
    @view_data = view_data
  end

  def create
    game = Game.new.tap do |game|
      game.add_participant(user_uid, user_name, admin: true)
      game.save!
    end

    redirect_to game_path(game.uid)
  end

  def join
    game.add_participant!(user_uid, user_name)
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

  def restart
    game.not_started!
    redirect_to game_path(game.uid)
  end

  private

  def publish_status_event; publish_event(:status) end
  def publish_participant_event; publish_event(:participants) end
  def publish_event(type)
    ActionCable.server.broadcast(
      "game_#{type}_#{game.uid}",
      body: view_data
    )
  end

  def ensure_admin!
    render status: :unauthorized unless participant.admin
  end

  def view_data
    GameSerializer.new(game).to_h.tap do |hash|
      if participant
        hash[:my_role] = participant.role
        hash[:my_role_t] = I18n.t("roles.#{participant.role}")
      end
    end.to_json
  end

  def game
    @_game ||= Game.find_by!(uid: params[:game_id] || params.require(:id))
  end

  def participant
    @_participant ||= game.participants[user_uid]
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
