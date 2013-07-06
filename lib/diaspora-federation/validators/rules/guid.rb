module Validation; module Rule
  class Guid

    # no parameters
    def initialize
    end

    def error_key
      :guid
    end

    def valid_value?(value)
      return false if !value.is_a?(String) || value.empty?
      return true if value.length >= 16 && value.downcase =~ /[0-9a-f]+/
      false
    end

    def params
      {}
    end
  end
end; end
