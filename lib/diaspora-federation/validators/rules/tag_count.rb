module Validation; module Rule
  class TagCount

    # works with the following params
    #
    # - :maximum - maximum allowed tag count
    #
    def initialize(params)
      unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
        raise "A number has to be specified for :maximum"
      end

      @params = params
    end

    def error_key
      :tag_count
    end

    def valid_value?(value)
      value.count('#') <= params[:maximum]
    end

    def params
      @params
    end
  end
end; end
