class Game < ApplicationRecord
  MAX_PARTICIPANTS = 10

  before_create :assign_defaults
  before_save :serialize_participants
  after_commit :clear_cache

  enum status: [:not_started, :started, :finished]

  def participants
    @_participants ||= begin
      participants_blob ?
        JSON.parse(participants_blob)
          .map { |uid, v| [uid, Participant.new(**v.symbolize_keys.merge(uid: uid))] }
          .to_h :
        {}
    end
  end

  def number_of_spies
    [(participants.size/4.0).floor + 1, 3].min
  end

  def add_participant!(user_uid, user_name, admin: false)
    add_participant(user_uid, user_name, admin: admin)
    save!
  end

  def add_participant(user_uid, user_name, admin: false)
    return if participants.key?(user_uid)
    # todo raise if max capacity

    participants[user_uid] = Participant.new(
      name: user_name,
      admin: admin,
      present: true
    )
  end

  def started!
    location, roles = ALL_LOCATIONS.to_a.sample

    number_of_citizens = participants.size - number_of_spies
    rolls = (number_of_citizens / roles.size.to_f).ceil
    roles = ((roles * rolls).shuffle.slice(0, number_of_citizens) + ([:spy] * number_of_spies)).shuffle

    participants.values.each { |p| p.role = roles.shift }
    assign_attributes(location: location)

    super
  end

  private

  def method_name

  end

  def serialize_participants
    assign_attributes(participants_blob: participants.transform_values(&:to_h).to_json)
  end

  def clear_cache
    @_participants = nil
  end

  def assign_defaults
    self.uid = SecureRandom.hex.slice(-8, 8)
  end
end
