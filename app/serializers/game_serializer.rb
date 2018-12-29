class GameSerializer < ActiveModel::Serializer
  attributes :uid, :status, :location, :participants,
    :number_of_spies

  def participants
    object.participants.values.map(&:to_h)
  end

  def location
    I18n.t("locations.#{object.location}")
  end
end
