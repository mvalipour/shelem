module Shelem
  class GameState
    include Minifier
    include Enums

    PROPS = %i(players status_i dealing bidding game)
    STATUSES = %i(to_name to_deal to_bid to_trump to_start to_play done)

    enum status: STATUSES

    def initialize(
      status_i: 0,
      players: nil,
      dealing: nil,
      bidding: nil,
      game: nil
    )
      @status_i = status_i
      @players = Players.new(players) if players.present?
      @dealing = Dealing.parse(dealing) if dealing.present?
      @bidding = Bidding.parse(bidding) if bidding.present?
      @game = Game.parse(game) if game.present?
    end

    attr_reader *PROPS

    def data
      {
        players: players.to_h,
        status_i: status_i,
        dealing: dealing.to_h,
        bidding: bidding.to_h,
        game: game.to_h
      }
    end

    def set_players!(players)
      ensure_status!(:to_name) do
        @players = Players.new(players)
      end
    end

    def deal!
      ensure_status!(:to_deal) do
        @dealing = Dealing.new.tap(&:deal)
      end
    end

    def start_bidding!
      ensure_status!(:to_bid) do
        @bidding = Bidding.new
      end
    end

    def can_trump?
      bidding&.finished? && !dealing&.trumped?
    end

    def trump!(cards_in, cards_out)
      ensure_status!(:to_trump, if: :can_trump?) do
        dealing.trump(bidding.current_bidder, cards_in, cards_out)
      end
    end

    def can_start_game?
      dealing&.trumped?
    end

    def start_game!
      ensure_status!(:to_start, :can_start_game?) do
        @game = Game.new
      end
    end

    def can_play?
      !game.finished?
    end

    def play!(card)
      ensure_status!(:to_play, if: :can_play?) do
        game.play(dealing.player_sets, card)
      end
    end

    def done?
      game&.finished?
    end

    def done!
      ensure_status!(:to_play, if: :done?)
    end

    def ensure_status!(status, options = {})
      raise 'INVALID_ACTION' unless status == status && (!options.key?(:if) || send(options[:if]))
      yield if block_given?
      @status_i += 1
    end
  end
end
