module DiasporaFederation
  module WebFinger
    # Generates and parses Host Meta documents.
    #
    # This is a minimal implementation of the standard, only to the degree of what
    # is used for the purposes of the Diaspora* protocol. (e.g. WebFinger)
    #
    # @example Creating a Host Meta document
    #   doc = HostMeta.from_base_url('https://pod.example.tld/')
    #   doc.to_xml
    #
    # @example Parsing a Host Meta document
    #   doc = HostMeta.from_xml(xml_string)
    #   webfinger_tpl = doc.webfinger_template_url
    #
    # @see http://tools.ietf.org/html/rfc6415 RFC 6415: "Web Host Metadata"
    # @see XrdDocument
    class HostMeta
      attr_reader :webfinger_template_url

      private_class_method :new

      # URL fragment to append to the base URL
      WEBFINGER_SUFFIX = 'webfinger?q={uri}'

      # Produces the XML string for the Host Meta instance with a +Link+ element
      # containing the +webfinger_url+.
      # @return [String] XML string
      def to_xml
        doc = XrdDocument.new
        doc.links << { rel: 'lrdd',
                       type: 'application/xrd+xml',
                       template: @webfinger_template_url }
        doc.to_xml
      end

      # Builds a new HostMeta instance and constructs the WebFinger URL from the
      # given base URL by appending HostMeta::WEBFINGER_SUFFIX.
      # @return [HostMeta]
      def self.from_base_url(base_url)
        fail ArgumentError unless base_url.instance_of?(String)

        base_url += '/' unless base_url.end_with?('/')
        webfinger_url = base_url + WEBFINGER_SUFFIX
        fail InvalidData unless webfinger_url_valid?(webfinger_url)

        hm = allocate
        hm.instance_variable_set(:@webfinger_template_url, webfinger_url)
        hm
      end

      # Reads the given Host Meta XML document string and populates the
      # +webfinger_url+.
      # @param [String] hostmeta_xml Host Meta XML string
      def self.from_xml(hostmeta_xml)
        data = XrdDocument.xml_data(hostmeta_xml)
        fail InvalidData unless data.key?(:links)

        link = data[:links].detect { |l| (l[:rel] == 'lrdd' && l[:type] == 'application/xrd+xml') }
        fail InvalidData if link.nil? || !webfinger_url_valid?(link[:template])

        hm = allocate
        hm.instance_variable_set(:@webfinger_template_url, link[:template])
        hm
      end

      # Applies some basic sanity-checking to the given URL
      # @param [String] url validation subject
      # @return [Boolean] validation result
      def self.webfinger_url_valid?(url)
        (!url.nil? && url.instance_of?(String) && !url.empty? &&
         url =~ %r{^https?://}i && url.end_with?(WEBFINGER_SUFFIX))
      end
      private_class_method :webfinger_url_valid?

      # Raised, if the +webfinger_url+ is missing or malformed
      class InvalidData < RuntimeError
      end
    end
  end
end
