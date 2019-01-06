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

    def to_h
      (0..51).to_a.in_groups_of(13).map{ |g| g.select(&method(:include?)) }
    end
  end
end
