
module DiasporaFederation; module WebFinger

  # This class implements basic handling of XRD documents as far as it is
  # necessary in the context of the protocols used with Diaspora* federation.
  #
  # @note Implementing +XrdDocument#to_json+ and +XrdDocument.json_data+ should
  #   be almost trivial due to the simplicity of the format and the way the data
  #   is stored internally already. See
  #   {http://tools.ietf.org/html/rfc6415#appendix-A RFC 6415, Appendix A}
  #   for a description of the JSON format.
  #
  # @example Creating a XrdDocument
  #   doc = XrdDocument.new
  #   doc.expires = DateTime.new(2020, 1, 15, 0, 0, 1)
  #   doc.subject = 'http://example.tld/articles/11''
  #   doc.aliases << 'http://example.tld/cool_article'
  #   doc.aliases << 'http://example.tld/authors/2/articles/3'
  #   doc.properties['http://x.example.tld/ns/version'] = '1.3'
  #   doc.links << { rel: 'author', type: 'text/html', href: 'http://example.tld/authors/2' }
  #   doc.links << { rel: 'copyright', template: 'http://example.tld/copyright?id={uri}' }
  #
  #   doc.to_xml
  #
  # @example Parsing a XrdDocument
  #   data = XrdDocument.xml_data(xml_string)
  #
  # @see http://docs.oasis-open.org/xri/xrd/v1.0/xrd-1.0.html Extensible Resource Descriptor (XRD) Version 1.0
  class XrdDocument

    # xml namespace url
    XMLNS = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

    # +Link+ element attributes
    LINK_ATTRS = [:rel, :type, :href, :template]

    # format string for datetime (+Expires+ element)
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'

    attr_writer :expires, :subject

    # @return [Array<String>] list of alias URIs
    attr_reader :aliases

    # @return [Hash<String => mixed>] list of properties. Hash key represents the
    #   +type+ attribute, and the value is the element content
    attr_reader :properties

    # @return [Array<Hash<attr => val>>] list of +Link+ element hashes. Each
    #   hash contains the attributesa and their associated values for the +Link+
    #   element.
    attr_reader :links

    def initialize
      @aliases = []
      @links = []
      @properties = {}
    end

    # Generates an XML document from the current instance and returns it as string
    # @return [String] XML document
    def to_xml
      doc = Ox::Document.new(version: '1.0', encoding: 'UTF-8')

      root = Ox::Element.new('XRD')
      root['xmlns'] = XMLNS
      doc << root

      if !@expires.nil? && @expires.instance_of?(DateTime)
        exp = Ox::Element.new('Expires')
        exp << @expires.strftime(DATETIME_FORMAT)
        root << exp
      end

      if !@subject.nil? && !@subject.empty?
        subj = Ox::Element.new('Subject')
        subj << @subject
        root << subj
      end

      @aliases.each do |a|
        next if !a.instance_of?(String) || a.empty?

        elem = Ox::Element.new('Alias')
        elem << a.to_s
        root << elem
      end

      @properties.each do |type, val|
        elem = Ox::Element.new('Property')
        elem['type'] = type
        elem << val.to_s unless val.nil? || val.empty?
        root << elem
      end

      @links.each do |l|
        elem = Ox::Element.new('Link')
        LINK_ATTRS.each do |attr|
          elem[attr.to_s] = l[attr] if l.key?(attr)
        end
        root << elem
      end

      Ox.dump(doc, with_xml: true)
    end

    # Parse the XRD document from the given string and create a hash containing
    # the extracted data.
    #
    # Small bonus: the hash structure that comes out of this method is the same
    # as the one used to produce a JRD (JSON Resource Descriptor) or parsing it.
    #
    # @param [String] xrd_doc XML string
    # @return [Hash] extracted data
    # @raise [InvalidDocument] if the XRD is malformed
    def self.xml_data(xrd_doc)
      raise ArgumentError unless xrd_doc.instance_of?(String)

      doc = Ox.load(DiasporaFederation.ensure_xml_prolog(xrd_doc), mode: :generic, effort: :tolerant)
      raise InvalidDocument if doc.locate('XRD').empty?

      data = {}

      exp_elem = doc.locate('XRD/Expires')
      unless exp_elem.empty?
        data[:expires] = DateTime.strptime(exp_elem.first.text, DATETIME_FORMAT)
      end

      subj_elem = doc.locate('XRD/Subject')
      unless subj_elem.empty?
        data[:subject] = subj_elem.first.text
      end

      aliases = []
      doc.locate('XRD/Alias').each do |node|
        aliases << node.text
      end
      data[:aliases] = aliases unless aliases.empty?

      properties = {}
      doc.locate('XRD/Property').each do |node|
        properties[node[:type]] = node.text
      end
      data[:properties] = properties unless properties.empty?

      links = []
      doc.locate('XRD/Link').each do |node|
        link = {}
        LINK_ATTRS.each do |attr|
          link[attr] = node[attr] if node.attributes.key?(attr)
        end
        links << link
      end
      data[:links] = links unless links.empty?

      data
    end

    # specific errors

    class InvalidDocument < RuntimeError
    end

  end
end; end
