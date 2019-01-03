module Shelem
  class Players
    def initialize(hash = {})
      @hash = hash
    end

    delegate :size, to: :@hash

    def add(uid, name)
      raise 'MAXIMUM PLAYER COUNT REACHED' if size == 4
      @hash[uid] == name
    end

    def to_h
      @hash
    end
  end
end
