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
      players: (players&.names || []),
      status: object.status,
      highest_bid: (bidding.highest_bid if bidding)
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
