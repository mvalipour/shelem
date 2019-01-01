module Shelem
  class Game
    def initialize(
      game_suit: nil,
      game_lead: 0,
      game_scores: [0, 0],
      cards_played: 0,
      round_lead: 0,
      round_suit: nil,
      round_set: 0
    )
      @game_suit = game_suit
      @game_lead = game_lead
      @game_scores = game_scores
      @cards_played = cards_played
      @round_lead = round_lead
      @round_suit = round_suit
      @round_set = Playing::CardSet.new(round_set)
    end

    def to_h
      {
        game_suit: game_suit,
        game_lead: game_lead,
        game_scores: game_scores,

        cards_played: cards_played,

        round_lead: round_lead,
        round_suit: round_suit,
        round_set: round_set.to_i,
      }
    end

    attr_reader :player_sets, :window_set,
      :game_suit, :game_lead, :game_bet, :game_scores,
      :cards_played,
      :round_lead, :round_suit, :round_set,

    def next_to_play
      (round_lead + cards_played) % 4
    end

    def rounds_played
      (cards_played / 4.0).ceil
    end

    def play(card)
      cards_in_hand = player_sets[next_to_play]

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

      @cards_played += 1
      round_set << card
      finish_round if round_set.size == 4
    end

    def new_round?
      round_set.empty?
    end

    def game_finished?
      player_sets.all(&:empty?)
    end

    def finish_round
      # find winner
      round_winner_team = round_winner_index % 2

      # set round_lead
      @round_lead = round_winner_index

      # count score
      game_scores[round_winner_team] += round_set.sum(&:score) + 5

      # reset round
      @round_suit = nil
      @round_set = []
    end

    def round_winner_index
      # re-order round cards to align for team members
      hands = 4.times.map{ |i| round_set[(round_lead + i) % 4] }
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
  end
end
