module Validation
  module Rule
    class Numeric

      # no parameters
      def initialize
      end

      def error_key
        :numeric
      end

      def valid_value?(value)
        Float(value) != nil rescue false
      end

      def params
        {}
      end
    end
  end
end
