module Shelem
  class Game
    attr_reader :player_hands, :spare_cards,
      :game_suit, :game_lead, :game_bet, :game_scores,
      :round_lead, :round_suit, :round_cards,

    def initialize(game_lead, bet)
      @round_lead = @game_lead = lead
      @game_bet = game_bet
      @round_cards = []
      @game_scores = [0, 0]

      # deal_cards
      Deck.new.tap do |deck|
        deck.shuffle!
        @player_hands = 4.times.map { deck.draw(12) }
        @spare_cards = deck.draw(4)
      end
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
        @game_suit = card.suit unless game_suit
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

    def game_finished?
      player_hands.all(&:empty?)
    end

    def finish_round
      # find winner
      round_winner_team = round_winner_index % 2

      # set round_lead
      @round_lead = round_winner_index

      # count score
      game_scores[round_winner_team] += round_cards.sum(&:score) + 5

      # reset round
      @round_suit = nil
      @round_cards = []
    end

    def round_winner_index
      # re-order round cards to align for team members
      hands = 4.times.map{ |i| round_cards[(round_lead + i) % 4] }
      hands.map do |c|
        # has player cut hand?
        if round_suit != game_suit && c.suit == game_suit
          # add 100 to ensure it's gonna be higher than any of the round suit ranks
          c.rank + 100
        else
          c.suit == round_suit ? c.rank : -1
        end
      end.each_with_index.max[1]
    end

    def game_winner_index
      game_scores.each_with_index.max[1]
    end

    def game_scores
      # todo
      winner = game_winner_index
      if winner == game_lead
        game_scores[game_lead] > game_bet ? game_bet : -game_bet
      else

      end
    end
  end
end
