class ShelemGameSerializer < ActiveModel::Serializer
  def initialize(object, game_uid, player_uid)
    @object = object
    @game_uid = game_uid
    @player_uid = player_uid
  end

  attr_reader :object, :game_uid, :player_uid
  delegate :game, :bidding, :players, :dealing, to: :object

  def to_h
    {
      player: (player_data || { joined: false }),
      game: game_data
    }
  end

  private

  def game_data
    {
      uid: game_uid,
      players: (players ? players.to_h.map { |uid, name| { uid: uid, name: name }} : []),
      status: object.status,
      total_scores: object.total_scores,
      total_games: object.total_games,

      widow_set: (dealing.widow_set.to_h if dealing),

      current_bidder: (bidding.current_bidder if bidding),
      highest_bidder: (bidding.highest_bidder if bidding),
      highest_bid: (bidding.highest_bid if bidding),

      scores: (game.game_scores if game),
      suit: (game.game_suit if game),
      round_lead: (game.round_lead if game),
      round_suit_i: (game.round_suit_i if game),
      next_to_play: (game.next_to_play if game),
      played_set: (game.round_set.map(&:to_i) + ([nil] * (4 - game.round_set.size)) if game)
    }.compact
  end

  def player_data
    return unless player_uid && players
    return unless (index = players.uids.find_index(player_uid))

    {
      uid: player_uid,
      index: index,
      joined: true,
      admin: object.admin_uid == player_uid,
      cards: (dealing.player_sets[index]&.to_h if dealing),
      bid: (bidding.bids[index] if bidding)
    }.compact
  end
end
