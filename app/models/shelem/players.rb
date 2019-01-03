module Shelem
  class Players
    def initialize(hash)
      raise 'MUST PROVIDE 4 PLAYERS' unless hash.size == 4
      @hash = hash.tarnsform_values{ |v| v.slice(0, 8) }
    end

    def to_h
      @hash
    end
  end
end
