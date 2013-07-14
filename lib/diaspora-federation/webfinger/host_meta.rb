
module DiasporaFederation; module WebFinger

  # Generates and parses Host Meta documents.
  #
  # This is a minimal implementation of the standard, to only what is used
  # for the purposes of the Diaspora* protocol.
  #
  # @see http://tools.ietf.org/html/rfc6415 RFC 6415: "Web Host Metadata"
  # @see XrdDocument
  class HostMeta

    attr_writer :data

    # @param [String] value WebFinger base URL, gets appended with
    #   +webfinger?q={uri}+ to construct the template URI
    # @raise [ArgumentError] if the given argument is not a String
    def webfinger_base_url=(value)
      raise ArgumentError unless value.instance_of?(String)

      value += '/' unless value.end_with?('/')
      @webfinger_base_url = value
    end

    # Returns the WebFinger URL that was contained in a previously parsed Host
    # Meta document.
    #
    # @return [String] WebFinger URL
    # @raise [ImproperInvocation] if no Host Meta document was parsed by this
    #   instance.
    # @raise [InsufficientData] if there was no webfinger URL contained in the
    #   parsed document
    def webfinger_url
      raise ImproperInvocation if @data.nil?
      raise InsufficientData unless @data.key?(:links)

      link = @data[:links].detect { |l| (l[:rel] == 'lrdd' && l[:type] == 'application/xrd+xml') }
      raise InsufficientData if link.nil?

      link[:template]
    end

    # Produces the XML string for the Host Meta instance with the
    # +webfinger_base_url+ set.
    #
    # @return [String] XML string
    # @raise [InsufficientData] if the +webfinger_base_url+ is nil or empty
    def to_xml
      raise InsufficientData if @webfinger_base_url.nil? || @webfinger_base_url.empty?

      doc = XrdDocument.new
      doc.links << { rel: 'lrdd',
                     type: 'application/xrd+xml',
                     template: @webfinger_base_url + 'webfinger?q={uri}' }
      doc.to_xml
    end

    # Reads the Host Meta XML document and saves the contained data internally
    # for later use
    # @param [String] hostmeta_xml Host Meta XML string
    def self.from_xml(hostmeta_xml)
      hm = HostMeta.new
      hm.data = XrdDocument.xml_data(hostmeta_xml)

      hm
    end

    # specific errors

    class InsufficientData < RuntimeError
    end

    class ImproperInvocation < RuntimeError
    end
  end
end; end
