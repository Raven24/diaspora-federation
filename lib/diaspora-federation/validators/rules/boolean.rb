module Validation; module Rule
  class Boolean

    # no parameters
    def initialize
    end

    def error_key
      :numeric
    end

    def valid_value?(value)
      return false if value.nil?
      result = false
      if value.is_a?(String)
        result = true if value =~ /^(true|false|t|f|yes|no|y|n|1|0)$/i
      elsif value.is_a?(Fixnum)
        result = true if value == 1 || value == 0
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        result = true
      end
      result
    end

    def params
      {}
    end
  end
end; end
