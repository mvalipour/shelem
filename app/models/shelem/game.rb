module Shelem
  class Game
    include Minifier
    include Enums

    PROPS = %i(game_suit_i game_scores cards_played round_lead round_suit_i round_set)

    enum game_suit: Playing::Card::SUITS, round_suit: Playing::Card::SUITS

    def initialize(
      game_suit_i: nil,
      game_scores: [0, 0],
      cards_played: 0,
      round_lead: 0,
      round_suit_i: nil,
      round_set: []
    )
      @game_suit_i = game_suit_i
      @game_scores = game_scores
      @cards_played = cards_played
      @round_lead = round_lead
      @round_suit_i = round_suit_i
      @round_set = round_set.map(&Playing::Card.method(:new))
    end

    attr_reader *PROPS

    def data
      {
        game_suit_i: game_suit_i,
        game_scores: game_scores,

        cards_played: cards_played,

        round_lead: round_lead,
        round_suit_i: round_suit_i,
        round_set: round_set.map(&:to_i),
      }
    end

    def next_to_play
      (round_lead + cards_played) % 4
    end

    def rounds_played
      (cards_played / 4.0).ceil
    end

    def play(player_sets, card)
      cards_in_hand = player_sets[next_to_play]

      # does the player have the card in hand?
      unless cards_in_hand.delete(card)
        raise 'INVALID CARD PLAYED'
      end

      if new_round?
        round_suit = card.suit
        game_suit = card.suit unless game_suit
      else
        # can the player has a card for round_suit but not playing it
        if round_suit && card.suit != round_suit && cards_in_hand.map(&:suit).include?(round_suit)
          raise 'MUST PLAY LEAD SUIT'
        end
      end

      @cards_played += 1
      round_set << card
      finish_round if cards_played % 4 == 0
    end

    def new_round?
      round_set.empty?
    end

    def finished?
      cards_played == 52
    end

    def finish_round
      # find winner
      round_winner = find_round_winner
      round_winner_team = round_winner % 2

      # set round_lead
      @round_lead = round_winner

      # count score
      game_scores[round_winner_team] += round_set.sum(&:score) + 5

      # reset round
      round_suit = nil
      round_set.clear
    end

    def find_round_winner
      # re-order round cards to align for team members
      round_set.rotate(round_lead).map do |c|
        # has player cut hand with a game suit?
        if round_suit != game_suit && c.suit == game_suit
          # add 100 to ensure it's gonna be higher than any of the round suit ranks
          c.rank + 100
        else
          c.suit == round_suit ? c.rank : -1
        end
      end.each_with_index.max[1]
    end
  end
end
