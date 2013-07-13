
module DiasporaFederation; module Salmon

  # +Slap+ provides class methods to create unencrypted Slap XML from payload
  # data and parse incoming XML into a Slap instance.
  #
  # A Diaspora*-flavored magic-enveloped XML message looks like the following:
  #
  #   <?xml version="1.0" encoding="UTF-8"?>
  #   <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
  #     <header>
  #       <author_id>{author}</author_id>
  #     </header>
  #     {magic_envelope}
  #   </diaspora>
  #
  class Slap
    attr_accessor :author_id, :magic_envelope, :cipher_params

    # Returns new instance of the Entity that is contained within the XML of
    # this Slap.
    #
    # The first time this is called, a public key has to be specified to verify
    # the Magic Envelope signature. On repeated calls, the key may be omitted.
    #
    # @see MagicEnvelope.unenvelop
    #
    # @param [OpenSSL::PKey::RSA] pubkey public key for validating the signature
    # @return [Entity] entity instance from the XML
    # @raise [ArgumentError] if the public key is of the wrong type
    def entity(pubkey=nil)
      return @entity unless @entity.nil?

      raise ArgumentError unless pubkey.instance_of?(OpenSSL::PKey::RSA)
      @entity = MagicEnvelope.unenvelop(magic_envelope, pubkey, @cipher_params)
      @entity
    end

    # Parses an unencrypted Salmon XML string and returns a new instance of
    # {Slap} populated with the XML data.
    #
    # @param [String] slap_xml Salmon XML
    # @return [Slap] new Slap instance
    # @raise [ArgumentError] if the argument is not a String
    # @raise [MissingAuthor] if the +author_id+ element is missing from the XML
    # @raise [MissingMagicEnvelope] if the +me:env+ element is missing from the XML
    def self.from_xml(slap_xml)
      raise ArgumentError unless slap_xml.instance_of?(String)
      doc = Ox.load(DiasporaFederation.ensure_xml_prolog(slap_xml), mode: :generic)
      slap = Slap.new

      author_elem = doc.locate('diaspora/header/author_id')
      raise MissingAuthor if author_elem.empty?
      slap.author_id = author_elem.first.text

      magic_env_elem = doc.locate('diaspora/me:env')
      raise MissingMagicEnvelope if magic_env_elem.empty?
      slap.magic_envelope = magic_env_elem.first

      slap
    end

    # Creates an unencrypted Salmon Slap and returns the XML string.
    #
    # @param [String] author_id Diaspora* handle of the author
    # @param [OpenSSL::PKey::RSA] pkey sender private_key for signing the magic envelope
    # @param [Entity] entity payload
    # @return [String] Salmon XML string
    # @raise [ArgumentError] if any of the arguments is not the correct type
    def self.generate_xml(author_id, pkey, entity)
      raise ArgumentError unless author_id.instance_of?(String) &&
                                 pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 entity.is_a?(Entity)
      doc = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

      root = Ox::Element.new('diaspora')
      root['xmlns'] = DiasporaFederation::XMLNS
      root['xmlns:me'] = MagicEnvelope::XMLNS
      doc << root

      header = Ox::Element.new('header')
      root << header

      author = Ox::Element.new('author_id')
      author << author_id
      header << author

      magic_envelope = MagicEnvelope.new(pkey, entity)
      root << magic_envelope.envelop

      Ox.dump(doc, with_xml: true)
    end

    private

    # specific errors

    class MissingAuthor < RuntimeError
    end
  end
end; end
