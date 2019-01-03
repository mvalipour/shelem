module Shelem
  class GameState
    include Minifier
    include Enums

    PROPS = %i(status_i dealing bidding game)

    enum status: %i(to_deal to_bid bidding to_trump to_play playing done)

    def initialize(status_i: 0, dealing: nil, bidding: nil, game: nil)
      @status_i = status_i
      @dealing = Dealing.new(dealing) if dealing.present?
      @bidding = Bidding.new(bidding) if bidding.present?
      @game = Game.new(game.merge(dealing: dealing)) if game.present?
    end

    attr_reader *PROPS

    def data
      {
        status_i: status_i,
        dealing: dealing.to_h,
        bidding: bidding.to_h,
        game: game.to_h
      }
    end

    def deal
      raise 'INVALID_ACTION' unless status == :to_deal
      @dealing = Dealing.new.tap(&:deal)
    end

    def start_bidding
      raise 'INVALID_ACTION' unless status == :to_bid
      @bidding = Bidding.new
    end

    def start_playing
      raise 'INVALID_ACTION' unless status == :to_play
      @game = Game.new
    end
  end
end
