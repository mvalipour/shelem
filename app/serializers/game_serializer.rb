class GameSerializer < ActiveModel::Serializer
  attributes :uid, :status, :location, :location_t, :participants,
    :number_of_spies

  def participants
    object.participants.values.map(&:to_h)
  end

  def location_t
    I18n.t("locations.#{object.location}")
  end
end
