module Playing
  class CardSet
    def self.build(*cards)
      new.tap { |s| cards.each(&s.method(:add)) }
    end

    def initialize(bits = 0)
      @bits = bits
    end

    def to_i
      @bits
    end

    def empty?
      @bits == 0
    end

    def clear
      @bits = 0
    end

    def include?(card)
      (@bits & (1 << card.to_i)) > 0
    end

    def include_suit?(suit)
      return false unless (suit_ix = Card::SUITS.find_index(suit))
      (0..12).any?{ |ix| include?(suit_ix * 13 + ix) }
    end

    def delete(card)
      @bits &= ~(1 << card.to_i)
    end

    def add(card)
      @bits |= (1 << card.to_i)
    end

    def cards
      [
        (13..25).select(&method(:include?)), # hearts
        (0..12).select(&method(:include?)), #  spades
        (26..38).select(&method(:include?)), # diamonds
        (39..51).select(&method(:include?)) # clubs
      ].flatten.map(&Card.method(:new))
    end

    def to_h
      cards.group_by(&:suit).map{ |_, c| c.map(&:to_i) }
    end
  end
end
