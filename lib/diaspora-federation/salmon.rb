
module DiasporaFederation
  module Salmon
    # aes cipher definition
    AES_CIPHER = 'AES-256-CBC'

    # encrypts the given data with a new AES cipher and returns the resulting
    # ciphertext, the key and iv (base64 strict_encoded) in a hash
    # @param [String] input
    # @return [Hash] { :key => '...', :iv => '...', :ciphertext => '...' }
    def self.aes_encrypt(data)
      cipher = OpenSSL::Cipher.new(AES_CIPHER)
      cipher.encrypt
      key = cipher.random_key
      iv = cipher.random_iv
      ciphertext = cipher.update(data) + cipher.final

      enc = [ key, iv, ciphertext ].map { |i| Base64.strict_encode64(i) }

      { key: enc[0],
        iv:  enc[1],
        ciphertext: enc[2] }
    end

    # decrypts the given ciphertext with an AES cipher defined by the given key
    # and iv. parameters are expected to be base64 encoded
    # @param [String] ciphertext
    # @param [String] AES key
    # @param [String] AES initialization vector
    # @return [String] decrypted plain message
    def self.aes_decrypt(ciphertext, key, iv)
      dec = [ciphertext, key, iv].map { |i| Base64.decode64(i) }

      decipher = OpenSSL::Cipher.new(AES_CIPHER)
      decipher.decrypt
      decipher.key = dec[1]
      decipher.iv = dec[2]

      plain = decipher.update(dec[0]) + decipher.final
      plain
    end

    # ensure the given string has got an xml prolog (primitively)
    # @param [String] Salmon XML
    # @return [String] Salmon XML, guaranteed with xml prolog
    def self.ensure_xml_prolog(xml_str)
      if xml_str.index('<?xml').nil?
        return '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + xml_str
      end

      xml_str
    end

    private

    # specific errors

    class MissingMagicEnvelope < RuntimeError
    end
  end
end

require_relative 'salmon/magic_envelope'
require_relative 'salmon/slap'
require_relative 'salmon/encrypted_slap'
