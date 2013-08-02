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
  #
  # @example Generating an encrypted Salmon Slap
  #   author = 'author@pod.example.tld'
  #   author_privkey = however_you_retrieve_the_authors_private_key(author)
  #   recipient_pubkey = however_you_retrieve_the_recipients_public_key()
  #   entity = YourEntity.new({ attr: 'val' })
  #
  #   slap_xml = EncryptedSlap.generate_xml(author, author_privkey, entity, recipient_pubkey)
  #
  # @example Parsing a Salmon Slap
  #   recipient_privkey = however_you_retrieve_the_recipients_private_key()
  #   slap = EncryptedSlap.from_xml(slap_xml, recipient_privkey)
  #   author_pubkey = however_you_retrieve_the_authors_public_key(slap.author_id)
  #
  #   entity = slap.entity(author_pubkey)
  #
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
      doc = Nokogiri::XML::Document.parse(slap_xml)
      ns = { 'd' => DiasporaFederation::XMLNS, 'me' => Salmon::MagicEnvelope::XMLNS }
      header_xpath = 'd:diaspora/d:encrypted_header'
      magicenv_xpath = 'd:diaspora/me:env'

      if doc.namespaces.empty?
        ns = nil
        header_xpath = 'diaspora/encrypted_header'
        magicenv_xpath = 'diaspora/env'
      end

      slap = Slap.new

      header_elem = doc.at_xpath(header_xpath, ns)
      raise MissingHeader if header_elem.nil?
      header = header_data(header_elem.content, pkey)
      slap.author_id = header[:author_id]
      slap.cipher_params = { key: header[:aes_key], iv: header[:iv] }

      magic_env_elem = doc.at_xpath(magicenv_xpath, ns)
      raise MissingMagicEnvelope if magic_env_elem.nil?
      slap.magic_envelope = magic_env_elem

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

      doc = Nokogiri::XML::Document.new()
      doc.encoding = 'UTF-8'

      root = Nokogiri::XML::Element.new('diaspora', doc)
      root.default_namespace = DiasporaFederation::XMLNS
      root.add_namespace('me', MagicEnvelope::XMLNS)
      doc.root = root

      magic_envelope = MagicEnvelope.new(pkey, entity, root)
      envelope_key = magic_envelope.encrypt!

      encrypted_header(author_id, envelope_key, pubkey, root)
      magic_envelope.envelop

      doc.to_xml
    end

    # decrypts and reads the data from the encrypted XML header
    # @param [String] base64 encoded, encrypted header data
    # @param [OpenSSL::PKey::RSA] private_key for decryption
    # @return [Hash] { iv: '...', aes_key: '...', author_id: '...' }
    def self.header_data(data, pkey)
      header_elem = decrypt_header(data, pkey)
      raise InvalidHeader unless header_elem.name == 'decrypted_header'

      iv = header_elem.at_xpath('iv').content
      key = header_elem.at_xpath('aes_key').content
      author = header_elem.at_xpath('author_id').content

      { iv: iv, aes_key: key, author_id: author }
    end
    private_class_method :header_data

    # decrypts the xml header
    # @param [String] base64 encoded, encrypted header data
    # @param [OpenSSL::PKey::RSA] private_key for decryption
    # @return [Nokogiri::XML::Element] header xml document
    def self.decrypt_header(data, pkey)
      cipher_header = JSON.parse(Base64.decode64(data))
      header_key = JSON.parse(pkey.private_decrypt(Base64.decode64(cipher_header['aes_key'])))

      xml = Salmon.aes_decrypt(cipher_header['ciphertext'],
                               header_key['key'],
                               header_key['iv'])
      Nokogiri::XML::Document.parse(xml).root
    end
    private_class_method :decrypt_header

    # encrypt the header xml with an AES cipher and encrypt the cipher params
    # with the recipients public_key
    # @param [String] diaspora_handle
    # @param [Hash] envelope cipher params
    # @param [OpenSSL::PKey::RSA] recipient public_key
    # @param parent_node [Nokogiri::XML::Element] parent element for insering in XML document
    def self.encrypted_header(author_id, envelope_key, pubkey, parent_node)
      data = header_xml(author_id, envelope_key)
      encryption_data = Salmon.aes_encrypt(data)

      json_key = JSON.generate(key: encryption_data[:key], iv: encryption_data[:iv])
      encrypted_key = Base64.strict_encode64(pubkey.public_encrypt(json_key))

      json_header = JSON.generate(aes_key: encrypted_key, ciphertext: encryption_data[:ciphertext])

      header = Nokogiri::XML::Element.new('encrypted_header', parent_node.document)
      header.content = Base64.strict_encode64(json_header)
      parent_node << header
    end
    private_class_method :encrypted_header

    # generate the header xml string, including the author, aes_key and iv
    # @param [String] diaspora_handle of the author
    # @param [Hash] { key: '...', iv: '...' } (values in base64)
    # @return [String] header XML string
    def self.header_xml(author_id, envelope_key)
      Nokogiri::XML::Builder.new do |xml|
        xml.decrypted_header {
          xml.iv(envelope_key[:iv])
          xml.aes_key(envelope_key[:key])
          xml.author_id(author_id)
        }
      end.to_xml.strip
    end
    private_class_method :header_xml

    # Raised, if the element containing the header is missing from the XML
    class MissingHeader < RuntimeError
    end

    # Raised if the decrypted header has an unexpected XML structure
    class InvalidHeader < RuntimeError
    end

  end
end; end
