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
          .transform_values { |v| Participant.new(**v.symbolize_keys) }
          .to_h :
        {}
    end
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
      admin: admin
    )
  end

  def started!
    location, roles = ALL_LOCATIONS.to_a.sample
    roles.shuffle!
    participants.each_with_index do |(_, p), ix|
      p.role = roles[ix]
    end

    super
  end

  private

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
