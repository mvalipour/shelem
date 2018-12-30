module Playing
  class Shelem
    attr_reader :player_hands, :spare_cards, :round_lead, :round_suit, :round_cards,
      :scores

    def deal_cards
      Deck.new.tap do |deck|
        deck.shuffle!
        @player_hands = 4.times.map { deck.draw(12) }
        @spare_cards = deck.draw(4)
      end

      # todo: there has to be a round of negotiation for this
      @round_lead = [0, 1, 2, 3].sample
      @round_suit = nil
      @round_cards = []
      @scores = [0, 0]
    end

    def next_to_play
      (round_lead + round_cards.size) % 4
    end

    def round_suit
      round_cards.first&.suit
    end

    def play(card)
      cards_in_hand = player_hands[next_to_play]

      # does the player have the card in hand?
      unless cards_in_hand.delete(card)
        raise 'INVALID CARD PLAYED'
      end

      if new_round?
        @round_suit = card.suit
      else
        # can the player has a card for round_suit but not playing it
        if round_suit && card.suit != round_suit && cards_in_hand.map(&:suit).include?(round_suit)
          raise 'MUST PLAY LEAD SUIT'
        end
      end

      round_cards << card
      finish_round if round_cards.size == 4
    end

    def new_round?
      round_cards.empty?
    end

    def finish_round
      # find winner
      hands = 4.times.map{ |i| round_cards[(round_lead + i) % 4] }
      winner_index = hands.map{ |c| c.suit == round_suit ? c.rank : -1 }.each_with_index.max[1]
      winner_team = winner_index % 2

      # set round_lead
      @round_lead = winner_index

      # count score
      scores[winner_team] += round_cards.sum(&:score) + 5

      # reset round
      @round_cards = []
    end
  end
end
