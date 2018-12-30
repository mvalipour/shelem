module Playing
  class Deck
    def initialize
      @cards = Card.all
    end

    attr_reader :cards
    delegate :shuffle!, to: :cards

    def draw(count = 1)
      cards.shift(count)
    end
  end
end
