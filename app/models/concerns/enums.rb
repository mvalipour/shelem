module Enums
  def self.included(base)
     base.extend(ClassMethods)
  end

  module ClassMethods
    def enum(maps)
      maps.each do |key, options|
        attr_reader "#{key}_i"
        define_method("#{key}=") do |value|
          unless (index = options.find_index(value))
            raise "Invalid value '#{value}' for #{key}"
          end
          instance_variable_set("@#{key}_i", index)
        end

        define_method(key) do
          return unless (index = send("#{key}_i"))
          options[index]
        end
      end
    end
  end
end
