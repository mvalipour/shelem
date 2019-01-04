module Shelem
  class Dealing
    include Minifier

    PROPS = %i(player_sets widow_set)

    def initialize(player_sets: [0, 0, 0, 0], widow_set: 0)
      @player_sets = player_sets.map(&Playing::CardSet.method(:new))
      @widow_set = Playing::CardSet.new(widow_set)
    end

    attr_reader :player_sets, :widow_set

    def data
      {
        player_sets: player_sets.map(&:to_i),
        widow_set: widow_set&.to_i
      }
    end

    def trumped?
      widow_set.empty?
    end

    def deal
      Playing::Deck.new.tap do |deck|
        deck.shuffle! # TODO: don't do perfect shuffle
        @player_sets = 4.times.map { deck.draw(12) }
        @widow_set = deck.draw(4)
      end
    end

    def trump(player_index, cards_in, cards_out)
      unless cards_in.size == cards_out.size
        raise 'CARDS_IN AND CARDS_OUT MUST BE SAME SIZE'
      end

      set = player_sets[player_index]
      unless cards_out.all?(&set.method(:include?))
        raise 'CARDS_OUT MUST BE IN CARD SET'
      end

      unless cards_in.all?(&widow_set.method(:include?))
        raise 'CARDS_IN MUST BE IN WIDOW SET'
      end

      cards_out.each(&set.method(:delete))
      cards_in.each(&set.method(:add))
      widow_set.clear
    end
  end
end
