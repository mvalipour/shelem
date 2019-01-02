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

    def delete(card)
      @bits &= ~(1 << card.to_i)
    end

    def add(card)
      @bits |= (1 << card.to_i)
    end
  end
end
