class ShelemGame
  include RedisStore
  include Minifier
  include Enums

  PROPS = %i(admin_uid status_i players dealing bidding game)
  STATUSES = %i(to_name to_deal to_bid bidding to_trump to_play playing done)

  enum status: STATUSES

  def initialize(admin_uid: nil, status_i: 0, players: nil, dealing: nil, bidding: nil, game: nil)
    @admin_uid = admin_uid
    @status_i = status_i
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
    end
  end

  def start_bidding!
    ensure_status!(:to_bid) do
      @bidding = Shelem::Bidding.new
    end
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
  end

  def can_trump?(player_uid)
    return false unless (player_index = players.uids.find_index(player_uid))
    return false unless bidding&.highest_bidder == player_index

    bidding&.finished? && !dealing&.trumped?
  end

  def trump!(player_uid, cards_in, cards_out)
    ensure_status!(:to_trump, only_if: can_trump?(player_uid)) do
      dealing.trump(bidding.current_bidder, cards_in, cards_out)
    end
  end

  def can_start_game?
    dealing&.trumped?
  end

  def start_game!
    ensure_status!(:to_play, only_if: :can_start_game?) do
      @game = Shelem::Game.new(round_lead: bidding.highest_bidder)
    end
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
