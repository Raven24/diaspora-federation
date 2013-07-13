module DiasporaFederation; module Salmon

  # +EncryptedSlap+ provides class methods for generating and parsing encrypted
  # Slaps. (In principle the same as  {Slap}, but with encryption.)
  #
  # The basic encryption mechanism used here is based on the knowledge that
  # asymmetrical encryption is slow and symmetrical encryption is fast. Keeping in
  # mind that a message we want to de-/encrypt may greatly vary in length,
  # performance considerations must play a part of this scheme.
  #
  # A Diaspora*-flavored encrypted magic-enveloped XML message looks like the following:
  #
  #   <?xml version='1.0' encoding='UTF-8'?>
  #   <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
  #     <encrypted_header>{encrypted_header}</encrypted_header>
  #     {magic_envelope with encrypted data}
  #   </diaspora>
  #
  # The encrypted header is encoded in JSON like this (when in plain text):
  #
  #   {
  #     'aes_key'    => '...',
  #     'ciphertext' => '...'
  #   }
  #
  # +aes_key+ is encrypted using the recipients public key, and contains the AES
  # +key+ and +iv+ used to encrypt the +ciphertext+ also encoded as JSON.
  #
  #   {
  #     'key' => '...',
  #     'iv'  => '...'
  #   }
  #
  # +ciphertext+, once decrypted, contains the +author_id+, +aes_key+ and +iv+
  # relevant to the decryption of the data in the magic_envelope and the
  # verification of its signature.
  #
  # The decrypted cyphertext has this XML structure:
  #
  #   <decrypted_header>
  #     <iv>{iv}</iv>
  #     <aes_key>{aes_key}</aes_key>
  #     <author_id>{author_id}</author_id>
  #   </decrypted_header>
  #
  # Finally, before decrypting the magic envelope payload, the signature should
  # first be verified.
  class EncryptedSlap

    # Creates a Slap instance from the data within the given XML string
    # containing an encrypted payload.
    #
    # @param [String] slap_xml encrypted Salmon xml
    # @param [OpenSSL::PKey::RSA] pkey recipient private_key for decryption
    #
    # @return [Slap] new Slap instance
    #
    # @raise [ArgumentError] if any of the arguments is of the wrong type
    # @raise [MissingHeader] if the +encrypted_header+ element is missing in the XML
    # @raise [MissingMagicEnvelope] if the +me:env+ element is missing in the XML
    def self.from_xml(slap_xml, pkey)
      raise ArgumentError unless slap_xml.instance_of?(String) &&
                                 pkey.instance_of?(OpenSSL::PKey::RSA)
      doc = Ox.load(DiasporaFederation.ensure_xml_prolog(slap_xml), mode: :generic)
      slap = Slap.new

      header_elem = doc.locate('diaspora/encrypted_header')
      raise MissingHeader if header_elem.empty?
      header = header_data(header_elem.first.text, pkey)
      slap.author_id = header[:author_id]
      slap.cipher_params = { key: header[:aes_key], iv: header[:iv] }

      magic_env_elem = doc.locate('diaspora/me:env')
      raise MissingMagicEnvelope if magic_env_elem.empty?
      slap.magic_envelope = magic_env_elem.first

      slap
    end

    # Creates an encrypted Salmon Slap and returns the XML string.
    #
    # @param [String] author_id Diaspora* handle of the author
    # @param [OpenSSL::PKey::RSA] pkey sender private key for signing the magic envelope
    # @param [Entity] entity payload
    # @param [OpenSSL::PKey::RSA] pubkey recipient public key for encrypting the AES key
    # @return [String] Salmon XML string
    # @raise [ArgumentError] if any of the arguments is of the wrong type
    def self.generate_xml(author_id, pkey, entity, pubkey)
      raise ArgumentError unless author_id.instance_of?(String) &&
                                 pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 entity.is_a?(Entity) &&
                                 pubkey.instance_of?(OpenSSL::PKey::RSA)
      doc = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

      root = Ox::Element.new('diaspora')
      root['xmlns'] = DiasporaFederation::XMLNS
      root['xmlns:me'] = MagicEnvelope::XMLNS
      doc << root

      magic_envelope = MagicEnvelope.new(pkey, entity)
      envelope_key = magic_envelope.encrypt!

      header = encrypted_header(author_id, envelope_key, pubkey)
      root << header
      root << magic_envelope.envelop

      Ox.dump(doc, with_xml: true)
    end

    private

    # decrypts and reads the data from the encrypted XML header
    # @param [String] base64 encoded, encrypted header data
    # @param [OpenSSL::PKey::RSA] private_key for decryption
    # @return [Hash] { iv: '...', aes_key: '...', author_id: '...' }
    def self.header_data(data, pkey)
      header_elem = decrypt_header(data, pkey)
      raise InvalidHeader unless header_elem.name == 'decrypted_header'

      iv = header_elem.locate('iv').first.text
      key = header_elem.locate('aes_key').first.text
      author = header_elem.locate('author_id').first.text

      { iv: iv, aes_key: key, author_id: author }
    end

    # decrypts the xml header
    # @param [String] base64 encoded, encrypted header data
    # @param [OpenSSL::PKey::RSA] private_key for decryption
    # @return [Ox::Element] header xml document
    def self.decrypt_header(data, pkey)
      cipher_header = JSON.parse(Base64.decode64(data))
      header_key = JSON.parse(pkey.private_decrypt(Base64.decode64(cipher_header['aes_key'])))

      xml = Salmon.aes_decrypt(cipher_header['ciphertext'],
                               header_key['key'],
                               header_key['iv'])
      Ox.load(xml, mode: :generic)
    end

    # encrypt the header xml with an AES cipher and encrypt the cipher params
    # with the recipients public_key
    # @param [String] diaspora_handle
    # @param [Hash] envelope cipher params
    # @param [OpenSSL::PKey::RSA] recipient public_key
    def self.encrypted_header(author_id, envelope_key, pubkey)
      data = header_xml(author_id, envelope_key)
      encryption_data = Salmon.aes_encrypt(data)

      json_key = JSON.generate(key: encryption_data[:key], iv: encryption_data[:iv])
      encrypted_key = Base64.strict_encode64(pubkey.public_encrypt(json_key))

      json_header = JSON.generate(aes_key: encrypted_key, ciphertext: encryption_data[:ciphertext])

      header = Ox::Element.new('encrypted_header')
      header << Base64.strict_encode64(json_header)
      header
    end

    # generate the header xml string, including the author, aes_key and iv
    # @param [String] diaspora_handle of the author
    # @parma [Hash] { key: '...', iv: '...' } (values in base64)
    def self.header_xml(author_id, envelope_key)
      header = Ox::Element.new('decrypted_header')

      iv = Ox::Element.new('iv')
      iv << envelope_key[:iv]
      header << iv

      key = Ox::Element.new('aes_key')
      key << envelope_key[:key]
      header << key

      author = Ox::Element.new('author_id')
      author << author_id
      header << author

      Ox.dump(header).strip
    end

    private

    # specific errors

    class MissingHeader < RuntimeError
    end

    class InvalidHeader < RuntimeError
    end

  end
end; end
