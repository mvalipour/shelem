module Shelem
  class Bidding
    include Minifier

    PROPS = %i(bids current_bidder)

    BID_MIN = 100
    BID_MAX = 165
    BID_STEP = 5

    def initialize(bids: [0, 0, 0, 0], current_bidder: 0)
      @bids = bids
      @current_bidder = current_bidder
    end

    def data
      {
        bids: bids,
        current_bidder: current_bidder
      }
    end

    attr_reader :current_bidder, :bids

    def highest_bid
      bids.max
    end

    def bid(raise)
      raise 'INVALID_RAISE' unless (raise > 0 || (highest_bid.zero? && raise == 0)) && raise % BID_STEP == 0 && (highest_bid + raise) <= BID_MAX

      if highest_bid.zero?
        bids[current_bidder] = BID_MIN + raise
        move_next
      elsif (highest_bid + raise) == 165
        # pass everyone else
        @bids = ([-1] * 4).tap{ |arr| arr[current_bidder] = 165 }
      else
        bids[current_bidder] = (highest_bid + raise)
        move_next
      end
    end

    def pass
      bids[current_bidder] = -1
      move_next
    end

    def highest_bidder
      bids.each_with_index.max[1]
    end

    def active_bids
      bids.count(&:positive?)
    end

    def awaiting_bids
      bids.count(&:zero?)
    end

    def pass_bids
      bids.count(&:negative?)
    end

    def finished?
      active_bids == 1 && awaiting_bids == 0
    end

    def deadlock?
      pass_bids == 3 && active_bids == 0
    end

    private

    def move_next
      loop do
        @current_bidder = (current_bidder + 1) % bids.size
        break unless bids[current_bidder] < 0
      end
    end
  end
end
