module Validation; module Rule
  class Guid

    attr_reader :params

    # no parameters
    def initialize
      @params = {}
    end

    def error_key
      :guid
    end

    def valid_value?(value)
      return false unless value.is_a?(String) && !value.empty?

      value.length >= 16 && value.downcase =~ /[0-9a-f]+/
    end
  end
end; end
