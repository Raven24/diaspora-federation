module Validation; module Rule
  class RsaKey

    attr_reader :params

    # no parameters
    def initialize
      @params = {}
    end

    def error_key
      :rsa_key
    end

    def valid_value?(value)
      (value.strip.start_with?("-----BEGIN RSA PUBLIC KEY-----") &&
       value.strip.end_with?("-----END RSA PUBLIC KEY-----"))
    end
  end
end; end
