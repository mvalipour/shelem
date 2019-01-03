class ShelemGame
  include Minifier
  include Enums

  PROPS = %i(admin_uid status_i players dealing bidding game)
  STATUSES = %i(to_name to_deal to_bid to_trump to_start to_play done)

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

  def save!(uid)
    true
  end

  def create!
    SecureRandom.hex
  end

  def self.find!(uid)
    # look up in redis
    new
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

  def can_trump?
    bidding&.finished? && !dealing&.trumped?
  end

  def trump!(cards_in, cards_out)
    ensure_status!(:to_trump, only_if: :can_trump?) do
      dealing.trump(bidding.current_bidder, cards_in, cards_out)
    end
  end

  def can_start_game?
    dealing&.trumped?
  end

  def start_game!
    ensure_status!(:to_start, :can_start_game?) do
      @game = Shelem::Game.new
    end
  end

  def can_play?
    !game.finished?
  end

  def play!(card)
    ensure_status!(:to_play, only_if: :can_play?) do
      game.play(dealing.player_sets, card)
    end
  end

  def done?
    game&.finished?
  end

  def done!
    ensure_status!(:to_play, only_if: :done?)
  end

  def ensure_status!(status, only_if: true, proceed_if: true)
    raise 'INVALID_ACTION' unless status == status && (only_if == true || send(only_if))
    yield if block_given?
    @status_i += 1 if (proceed_if == true || send(proceed_if) )
  end
end
