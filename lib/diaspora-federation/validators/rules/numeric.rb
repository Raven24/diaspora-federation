module Validation; module Rule
  class Numeric

    attr_reader :params

    # no parameters
    def initialize
      @params = {}
    end

    def error_key
      :numeric
    end

    def valid_value?(value)
      Float(value) != nil rescue false
    end
  end
end; end
