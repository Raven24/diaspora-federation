
# a diaspora-flavored salmon-enveloped xml message looks like the following:
#
# <?xml version="1.0" encoding="UTF-8"?>
# <diaspora xmlns="https://joindiaspora.com/protocol" xmlns:me="http://salmon-protocol.org/ns/magic-env">
#   <header>
#     <author_id>{author}</author_id>
#   </header>
#   {magic_envelope}
# </diaspora>
#

module DiasporaFederation; module Salmon
  class Slap
    attr_accessor :author_id, :magic_envelope


    # @param [OpenSSL::PKey::RSA] public_key for validating the signature
    # @return [Entity]
    def entity(pubkey=nil)
      return @entity unless @entity.nil?

      raise ArgumentError unless pubkey.instance_of?(OpenSSL::PKey::RSA)
      @entity = MagicEnvelope.unenvelop(magic_envelope, pubkey)
      @entity
    end

    # parses a signed salmon xml and returns an instance of Salmon::Slap
    # @param [String] Salmon XML
    # @return [Slap]
    def self.from_xml(slap_xml)
      raise ArgumentError unless slap_xml.instance_of?(String)
      doc = Ox.load(ensure_xml_prolog(slap_xml), mode: :generic)
      slap = Slap.new

      author_elem = doc.locate('diaspora/header/author_id')
      raise MissingAuthor if author_elem.empty?
      slap.author_id = author_elem.first.text

      magic_env_elem = doc.locate('diaspora/me:env')
      raise MissingMagicEnvelope if magic_env_elem.empty?
      slap.magic_envelope = magic_env_elem.first

      slap
    end

    # creates a signed salmon slap and returns the xml string
    # @param [String] diaspora_handle of the author
    # @param [OpenSSL::PKey::RSA] private_key for signing the payload
    # @param [Entity]
    # @return [String] Salmon XML
    def self.to_xml(author_id, pkey, entity)
      raise ArgumentError unless author_id.instance_of?(String) &&
                                 pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 entity.is_a?(Entity)
      doc = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

      root = Ox::Element.new('diaspora')
      root['xmlns'] = 'https://joindiaspora.com/protocol'
      root['xmlns:me'] = 'http://salmon-protocol.org/ns/magic-env'
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

    def self.ensure_xml_prolog(xml_str)
      if xml_str.index('<?xml').nil?
        return '<?xml version="1.0" encoding="UTF-8"?>' + "\n" + xml_str
      end

      xml_str
    end

    # specific errors

    class MissingAuthor < RuntimeError
    end

    class MissingMagicEnvelope < RuntimeError
    end
  end
end; end
