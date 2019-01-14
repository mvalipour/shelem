module Shelem
  class Game
    include Minifier
    include Enums

    PROPS = %i(
      game_suit_i game_scores cards_played
      current_round last_round
    )

    enum game_suit: Playing::Card::SUITS

    def initialize(
      game_suit_i: nil,
      game_scores: [0, 0],
      cards_played: 0,
      current_round: nil,
      last_round: nil
    )
      @game_suit_i = game_suit_i
      @game_scores = game_scores
      @cards_played = cards_played
      @current_round = current_round.present? ? Shelem::Round.parse(current_round) : Shelem::Round.new
      @last_round = Shelem::Round.parse(last_round) if last_round.present?
    end

    attr_reader *PROPS

    def data
      {
        game_suit_i: game_suit_i,
        game_scores: game_scores,

        cards_played: cards_played,

        current_round: current_round&.to_h,
        last_round: last_round&.to_h,
      }
    end

    def next_to_play
      (current_round.lead + cards_played) % 4
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

      if current_round.new?
        current_round.suit_i = card.suit_i
        @game_suit_i = card.suit_i unless @game_suit_i
      else
        # can the player has a card for current_round.suit but not playing it
        if current_round.suit && card.suit != current_round.suit && cards_in_hand.include_suit?(current_round.suit)
          raise 'MUST PLAY LEAD SUIT'
        end
      end

      @cards_played += 1
      current_round.cards << card
      finish_round if current_round.finished?
    end

    def finished?
      cards_played == 48
    end

    def finish_round
      # find winner
      round_winner = find_round_winner
      round_winner_team = round_winner % 2

      # count score
      game_scores[round_winner_team] += current_round.score

      # reset round
      @last_round = current_round
      @current_round = Shelem::Round.new(lead: round_winner)
    end

    def find_round_winner
      current_round.flat_cards.map do |card|
        # has player cut hand with a game suit?
        if current_round.suit != game_suit && card.suit == game_suit
          # add 100 to ensure it's gonna be higher than any of the round suit ranks
          card.rank + 100
        else
          card.suit == current_round.suit ? card.rank : -1
        end
      end.each_with_index.max[1]
    end
  end
end
