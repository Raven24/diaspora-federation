module Validation; module Rule
  class HandleCount

    # works with the following params
    #
    # - :maximum - maximum allowed handle count
    #
    def initialize(params)
      unless params.include?(:maximum) && params[:maximum].is_a?(Fixnum)
        raise "A number has to be specified for :maximum"
      end

      @params = params
    end

    def error_key
      :handle_count
    end

    def valid_value?(value)
      value.split(';').count <= params[:maximum]
    end

    def params
      @params
    end
  end
end; end
