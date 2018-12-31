module Shelem
  class Bidding
    def initialize(bid_starter)
      @current_bidder = bid_starter
      @bids = ([0] * 4).tap{ |b| b[bid_starter] = 100 }
      @bid_amount = 100
    end

    attr_reader :current_bidder, :bids, :bid_amount

    def bid(raise)
      raise 'INVALID_RAISE' unless raise > 0 && raise % 5 == 0 && (bid_amount + raise) <= 165

      bids[current_bidder] = (@bid_amount += raise)
      move_next
    end

    def pass
      bids[current_bidder] = nil
      move_next
    end

    def highest_bidder
      bids.each_with_index.max[1]
    end

    def finished?
      bids.compact.size == 1
    end

    private

    def move_next
      loop do
        @current_bidder = (current_bidder + 1) % 4
        break unless bids[current_bidder].nil?
      end
    end
  end
end
