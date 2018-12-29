class Participant
  PROPS = %i(name role admin present)

  include ActiveModel::Model

  attr_accessor *PROPS

  def to_h
    PROPS.each_with_object({}) { |prop, hash| hash[prop] = send(prop) }
      .compact
  end
end
