module Shelem
  class Players
    def initialize(hash = {})
      @hash = hash
    end

    delegate :include?, :size, to: :@hash

    def add(uid, name)
      raise 'MAXIMUM PLAYER COUNT REACHED' if size == 4
      @hash[uid] = name.slice(0, 8)
    end

    def data
      @hash
    end

    def to_h
      @hash
    end

    def uids
      @hash.keys
    end
  end
end
