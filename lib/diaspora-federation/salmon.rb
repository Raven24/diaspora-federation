
module DiasporaFederation

  # This module contains a Diaspora*-specific implementation of parts of the
  # {http://www.salmon-protocol.org/ Salmon Protocol}.
  module Salmon
    # OpenSSL aes cipher definition
    AES_CIPHER = 'AES-256-CBC'

    # encrypts the given data with a new, random AES cipher and returns the
    # resulting ciphertext, the key and iv in a hash (each of the entries
    # base64 strict_encoded).
    # @param [String] data plain input
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
    # @param [String] ciphertext input data
    # @param [String] key AES key
    # @param [String] iv AES initialization vector
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

    private

    # specific errors

    class MissingMagicEnvelope < RuntimeError
    end
  end
end

require 'diaspora-federation/salmon/magic_envelope'
require 'diaspora-federation/salmon/slap'
require 'diaspora-federation/salmon/encrypted_slap'
