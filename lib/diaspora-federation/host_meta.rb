
module DiasporaFederation

  # Generates and parses Host Meta documents.
  #
  # This is a stripped-down implementation of the standard, to only what is used
  # for the purposes of the Diaspora* protocol.
  #
  # @see http://tools.ietf.org/html/rfc6415 RFC 6415: "Web Host Metadata"
  class HostMeta

    # xml namespace url
    XMLNS = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

    LINK_ATTRS = [:rel, :type, :href, :template]

    attr_reader :links

    def initialize
      @links = []
    end

    def to_xml
      doc = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

      root = Ox::Element.new('XRD')
      root['xmlns'] = XMLNS
      doc << root

      @links.each do |l|
        link = Ox::Element.new('Link')
        LINK_ATTRS.each do |attr|
          link[attr.to_s] = l[attr] if l.key?(attr)
        end

        root << link
      end

      Ox.dump(doc, with_xml: true)
    end

    # Parse the given Host Meta document and create a hash containing the data
    def self.xml_data(hostmeta_xml)
      raise ArgumentError unless hostmeta_xml.instance_of?(String)

      doc = Ox.load(DiasporaFederation.ensure_xml_prolog(hostmeta_xml), mode: :generic, effort: :tolerant)
      raise InvalidDocument if doc.locate('XRD').empty?

      data = { links: [] }
      doc.locate('XRD/Link').each do |node|
        link = {}
        LINK_ATTRS.each do |attr|
          link[attr] = node[attr] if node.attributes.key?(attr)
        end

        data[:links] << link
      end

      data
    end

    # specific errors

    class InvalidDocument < RuntimeError
    end
  end
end
