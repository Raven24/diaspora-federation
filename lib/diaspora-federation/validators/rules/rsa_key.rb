module Validation; module Rule
  class RsaKey
    # no parameters
    def initialize
    end

    def error_key
      :rsa_key
    end

    def valid_value?(value)
      (value.strip.start_with?("-----BEGIN RSA PUBLIC KEY-----") &&
       value.strip.end_with?("-----END RSA PUBLIC KEY-----"))
    end

    def params
      {}
    end
  end
end; end
