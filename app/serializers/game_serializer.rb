class GameSerializer < ActiveModel::Serializer
  attributes :uid, :status, :location, :participants,
    :number_of_spies

  def participants
    object.participants.values.map(&:to_h)
  end
end
