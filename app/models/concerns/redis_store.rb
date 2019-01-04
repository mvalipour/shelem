module RedisStore
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find!(uid)
      json = REDIS_CLIENT.get(redis_key(uid))
      raise "ITEM NOT FOUND: #{uid}" if json.nil?
      parse(JSON.parse(json))
    end

    def redis_key(uid)
      "_#{self.name.underscore}_#{uid}"
    end
  end

  def create!
    SecureRandom.hex.slice(0, 8).tap do |uid|
      save!(uid)
    end
  end

  def save!(uid)
    self.class.redis_key(uid).tap do |key|
      REDIS_CLIENT.set(key, to_h.to_json)
      REDIS_CLIENT.expire(key, 1.hour.to_i)
    end
  end
end
