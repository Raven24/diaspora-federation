module Validation
  module Rule
    class Format

      # works with the following params
      #
      # - :with - regular expression used for matching - OR -
      # - :without - regexp that should not match
      # - :allow_blank - boolean for allowing empty strings
      #
      def initialize(params)
        unless params.include?(:with) ^ params.include?(:without)
          raise "Either :with or :without must be specified"
        end

        if (params[:with] && !params[:with].is_a?(Regexp)) ||
           (params[:without] && !params[:without].is_a?(Regexp))
          raise "A regular expression must be supplied"
        end

        @params = params
      end

      def error_key
        :format
      end

      def valid_value?(value)
        return true if value.empty? && params[:allow_blank]
        result = false
        if params[:with]
          result = true if value.to_s =~ params[:with]
        elsif params[:without]
          result = true if value.to_s !~ params[:without]
        end
        result
      end

      def params
        @params
      end
    end
  end
end
