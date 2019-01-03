module Minifier
  PROPS = []

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def parse(values = [])
      new(self::PROPS.zip(values).to_h.compact)
    end
  end

  def to_h
    data.values
  end
end
