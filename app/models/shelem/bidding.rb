module Shelem
  class Bidding
    BID_MIN = 100
    BID_MAX = 165
    BID_STEP = 5

    def initialize(bids: [BID_MIN] * 4, current_bidder: 0)
      @bids = bids
      @current_bidder = current_bidder
    end

    def to_h
      {
        bids: bids,
        current_bidder: current_bidder
      }
    end

    attr_reader :current_bidder, :bids

    def bid_amount
      bids.max
    end

    def bid(raise)
      raise 'INVALID_RAISE' unless raise > 0 && raise % BID_STEP == 0 && (bid_amount + raise) <= BID_MAX

      bids[current_bidder] = (bid_amount + raise)
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
        @current_bidder = (current_bidder + 1) % bids.size
        break unless bids[current_bidder].nil?
      end
    end
  end
end
