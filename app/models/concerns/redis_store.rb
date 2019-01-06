module RedisStore
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def find(uid)
      json = REDIS_CLIENT.get(redis_key(uid))
      parse(JSON.parse(json)) unless json.nil?
    end

    def find!(uid)
      find(uid).tap { |i| raise ActiveRecord::RecordNotFound.new("ITEM NOT FOUND: #{uid}") unless i }
    end

    def redis_key(uid)
      "_#{self.name.underscore}_#{uid}"
    end
  end

  def save!(uid = SecureRandom.hex.slice(0, 8))
    self.class.redis_key(uid).tap do |key|
      REDIS_CLIENT.set(key, to_h.to_json)
      REDIS_CLIENT.expire(key, 1.day.to_i)
    end
    uid
  end
end
