module Shelem
  class GameState
    STATUSES = %i(to_deal to_bid bidding to_trump to_play playing done)

    def initialize(status: :to_deal, dealing: nil, bidding: nil, game: nil)
      @status = status
      @dealing = Dealing.new(dealing) if dealing
      @bidding = Bidding.new(bidding) if bidding
      @game = Game.new(game.merge(dealing: dealing)) if game
    end

    def to_h
      {
        status: status,
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
