class ShelemGame
  include RedisStore
  include Minifier
  include Enums

  PROPS = %i(admin_uid status_i total_scores total_games players dealing bidding game)
  STATUSES = %i(to_name to_deal bidding to_trump playing done)

  enum status: STATUSES

  def initialize(admin_uid: nil, status_i: 0, total_scores: [0, 0], total_games: 0, players: nil, dealing: nil, bidding: nil, game: nil)
    @admin_uid = admin_uid
    @status_i = status_i
    @total_scores = total_scores
    @total_games = total_games
    @players = Shelem::Players.new(players) if players.present?
    @dealing = Shelem::Dealing.parse(dealing) if dealing.present?
    @bidding = Shelem::Bidding.parse(bidding) if bidding.present?
    @game = Shelem::Game.parse(game) if game.present?
  end

  attr_reader *PROPS

  def data
    {
      admin_uid: admin_uid,
      status_i: status_i,
      total_scores: total_scores,
      total_games: total_games,
      players: players.to_h,
      dealing: dealing.to_h,
      bidding: bidding.to_h,
      game: game.to_h
    }
  end

  def can_add_player?
    !players || players.size < 4
  end

  def players_done?
    players&.size == 4
  end

  def add_player!(uid, name)
    ensure_status!(:to_name, only_if: :can_add_player?, proceed_if: :players_done?) do
      @players ||= Shelem::Players.new
      players.add(uid, name)
    end
  end

  def deal!
    ensure_status!(:to_deal) do
      @dealing = Shelem::Dealing.new.tap(&:deal)
      start_bidding!
    end
  end

  def start_bidding!
    @bidding = Shelem::Bidding.new(current_bidder: total_games % 4)
  end

  def bidding_done?
    bidding&.finished?
  end

  def can_bid(player_uid)
    return false unless (player_index = players.uids.find_index(player_uid))
    bidding&.current_bidder == player_index
  end

  def bid!(player_uid, raise)
    ensure_status!(:bidding, only_if: can_bid(player_uid), proceed_if: :bidding_done?) do
      bidding.bid(raise)
    end
  end

  def pass!(player_uid)
    ensure_status!(:bidding, only_if: can_bid(player_uid), proceed_if: :bidding_done?) do
      bidding.pass
    end

    if bidding.deadlock?
      do_restart!
    end
  end

  def can_trump?(player_uid)
    return false unless (player_index = players.uids.find_index(player_uid))
    return false unless bidding&.highest_bidder == player_index

    bidding&.finished? && !dealing&.trumped?
  end

  def trump!(player_uid, cards_in, cards_out)
    ensure_status!(:to_trump, only_if: can_trump?(player_uid)) do
      dealing.trump(bidding.current_bidder, cards_in, cards_out)
      start_game!
    end
  end

  def start_game!
    @game = Shelem::Game.new(
      current_round: [bidding.highest_bidder]
    )
  end

  def can_play?(player_uid)
    return false unless (player_index = players.uids.find_index(player_uid))
    return false unless game&.next_to_play == player_index

    !game.finished?
  end

  def done?
    game&.finished?
  end

  def play!(player_uid, card)
    ensure_status!(:playing, only_if: can_play?(player_uid), proceed_if: :done?) do
      game.play(dealing.player_sets, Playing::Card.new(card))
    end

    if done?
      @total_scores = total_scores.zip(current_game_score).map(&:sum)
      @total_games += 1
    end
  end

  def restart!
    ensure_status!(:done, proceed_if: false) do
      do_restart!
    end
  end

  private

  def current_game_score
    game.game_scores.clone.tap do |result|
      bidder_team = bidding.highest_bidder % 2
      bid = bidding.highest_bid
      if result[bidder_team] >= bid
        if bid == Shelem::Bidding::BID_MAX
          result[(bidder_team + 1) % 2] = -bid
        end
      else
        result[bidder_team] = -bid
      end
    end
  end

  def do_restart!
    self.status = :to_deal
    @bidding = nil
    @dealing = nil
    @game = nil
  end

  def ensure_status!(status, only_if: true, proceed_if: true)
    raise 'INVALID_ACTION' unless status == status && evaluate(only_if)
    yield if block_given?
    @status_i += 1 if evaluate(proceed_if)
  end

  def evaluate(predicate)
    predicate.is_a?(Symbol) ? send(predicate) : !!predicate
  end
end
