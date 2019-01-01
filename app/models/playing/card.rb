module Playing
  class Card
    FACES = (2..10).to_a + %w(J Q K A)
    SCORES = %w(0 0 0 5 0 0 0 0 10 0 0 0 10).map(&:to_i)
    SUITS = %i(hearts spades diamonds clubs)

    class << self
      def all
        (0..51).map(&method(:new))
      end

      def build(suit, face)
        new(SUITS.index(suit) * 13 + FACES.index(face))
      end
    end

    def initialize(value)
      raise 'invalid card number' unless value.between?(0, 51)

      @value = value
    end

    def rank
      @value % 13
    end

    def suit
      SUITS[@value / 13]
    end

    def face
      FACES[rank]
    end

    def score
      SCORES[rank]
    end

    def to_i
      @value
    end

    def ==(other_card)
      other_card.to_i == to_i
    end
  end
end
