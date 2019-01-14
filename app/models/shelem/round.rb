module Shelem
  class Round
    include Minifier
    include Enums

    PROPS = %i(lead suit_i cards)

    enum suit: Playing::Card::SUITS

    def initialize(lead: 0, suit_i: nil, cards: [])
      @lead = lead
      @suit_i = suit_i
      @cards = cards.map(&Playing::Card.method(:new))
    end

    attr_accessor *PROPS

    def data
      {
        lead: lead,
        suit_i: suit_i,
        cards: cards.map(&:to_i),
      }
    end

    def new?
      cards.empty?
    end

    def finished?
      cards.size == 4
    end

    def score
      cards.sum(&:score) + 5
    end

    def flat_cards
      # re-order round cards to align for team members
      cards.rotate(-lead)
    end
  end
end
