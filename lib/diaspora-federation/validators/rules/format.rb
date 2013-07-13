module Validation; module Rule

  # Rormat rule for validation using regular expressions
  class Format

    # initialize rule
    #
    # @param [Hash] params rule options
    # @option params [Regexp] :with regular expression used for matching - OR -
    # @option params [Regexp] :without regexp that should not match
    # @option params [Boolean] :allow_blank allow empty strings
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
end; end
