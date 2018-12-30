module Playing
  class Card
    FACES = (2..10).to_a + %w(J Q K A)
    SCORES = %w(0 0 0 5 0 0 0 0 10 0 0 0 10).map(&:to_i)
    SUITS = %i(hearts spades diamonds clubs)

    class << self
      def all
        (0..51).map{ |n| new(n) }.flatten
      end

      def find(suit, face)
        new(SUITS.index(suit) * 13 + FACES.index(face))
      end
    end

    def initialize(unique_number)
      raise 'invalid card number' unless unique_number.between?(0, 51)

      @unique_number = unique_number
    end

    attr_reader :unique_number

    def rank
      unique_number % 13
    end

    def suit
      SUITS[unique_number / 13]
    end

    def face
      FACES[rank]
    end

    def score
      SCORES[rank]
    end

    def ==(other_card)
      other_card.unique_number == unique_number
    end
  end
end
