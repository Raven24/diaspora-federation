
module DiasporaFederation; module WebFinger

  # The WebFinger document used for Diaspora* user discovery is based on an older
  # draft of the specification you can find in the wiki of the "webfinger" project
  # on {http://code.google.com/p/webfinger/wiki/WebFingerProtocol Google Code}
  # (from around 2010).
  #
  # In the meantime an actual RFC draft has been in development, which should
  # serve as a base for all future changes of this implementation.
  #
  # @see http://tools.ietf.org/html/draft-jones-appsawg-webfinger "WebFinger" -
  #   current draft
  # @see http://code.google.com/p/webfinger/wiki/CommonLinkRelations
  # @see http://www.iana.org/assignments/link-relations/link-relations.xhtml
  #   official list of IANA link relations
  class WebFinger

    private_class_method :new

    attr_reader :acct_uri, :alias_url, :hcard_url, :seed_url, :profile_url, :updates_url

    # @deprecated
    attr_reader :guid, :pubkey

    # +hcard+ link relation
    REL_HCARD = 'http://microformats.org/profile/hcard'

    # +seed_location+ link relation
    REL_SEED = 'http://joindiaspora.com/seed_location'

    # @deprecated This should be a +Property+ or moved to the +hcard+, but +Link+
    #   is inappropriate according to the specification.
    # +guid+ link relation
    REL_GUID = 'http://joindiaspora.com/guid'

    # +profile-page+ link relation.
    # @note This might just as well be an +Alias+ instead of a +Link+.
    REL_PROFILE = 'http://webfinger.net/rel/profile-page'

    # Atom feed link relation
    REL_UPDATES = 'http://schemas.google.com/g/2010#updates-from'

    # @deprecated This should be a +Property+ or moved to the +hcard+, but +Link+
    #   is inappropriate according to the specification.
    # +diaspora-public-key+ link relation
    REL_PUBKEY = 'diaspora-public-key'

    def to_xml
      doc = XrdDocument.new
      doc.subject = @acct_uri
      doc.aliases << @alias_url

      doc.links << { rel: REL_HCARD,
                     type: 'text/html',
                     href: @hcard_url }
      doc.links << { rel: REL_SEED,
                     type: 'text/html',
                     href: @seed_url }

      # TODO change me!  ###############
      doc.links << { rel: REL_GUID,
                     type: 'text/html',
                     href: @guid }
      ##################################

      doc.links << { rel: REL_PROFILE,
                     type: 'text/html',
                     href: @profile_url }
      doc.links << { rel: REL_UPDATES,
                     type: 'application/atom+xml',
                     href: @updates_url }

      # TODO change me!  ###############
      doc.links << { rel: REL_PUBKEY,
                     type: 'RSA',
                     href: @pubkey }
      ##################################

      doc.to_xml
    end

    # Create a WebFinger instance from the given account data Hash.
    # @param [Hash] data account data
    # @return [WebFinger] WebFinger instance
    # @raise [InvalidData] if the given data Hash is invalid or incomplete
    def self.from_account(data)
      raise InvalidData unless account_data_complete?(data)

      wf = self.allocate
      wf.instance_eval {
        @acct_uri    = data[:acct_uri]
        @alias_url   = data[:alias_url]
        @hcard_url   = data[:hcard_url]
        @seed_url    = data[:seed_url]
        @profile_url = data[:profile_url]
        @updates_url = data[:updates_url]

        # TODO change me!  ###########
        @guid        = data[:guid]
        @pubkey      = data[:pubkey]
        #############################
      }
      wf
    end

    # @param [String] webfinger_xml WebFinger XML string
    # @return [WebFinger] WebFinger instance
    def self.from_xml(webfinger_xml)
      data = XrdDocument.xml_data(webfinger_xml)
      raise InvalidData unless xml_data_valid?(data)

      links = data[:links]
      hcard   = links.detect { |l| l[:rel] == REL_HCARD }
      seed    = links.detect { |l| l[:rel] == REL_SEED }
      guid    = links.detect { |l| l[:rel] == REL_GUID }
      profile = links.detect { |l| l[:rel] == REL_PROFILE }
      updates = links.detect { |l| l[:rel] == REL_UPDATES }
      pubkey  = links.detect { |l| l[:rel] == REL_PUBKEY }
      raise InvalidData unless [hcard, seed, guid, profile, updates, pubkey].all?

      wf = self.allocate
      wf.instance_eval {
        @acct_uri    = data[:subject]
        @alias_url   = data[:aliases].first
        @hcard_url   = hcard[:href]
        @seed_url    = seed[:href]
        @profile_url = profile[:href]
        @updates_url = updates[:href]

        # TODO change me!  ###########
        @guid        = guid[:href]
        @pubkey      = pubkey[:href]
        ##############################
      }
      wf
    end

    # Checks the given account data Hash for correct type and completeness.
    # @param [Hash] data account data
    # @return [Boolean] validation result
    def self.account_data_complete?(data)
      (!data.nil? && data.instance_of?(Hash) &&
       data.key?(:acct_uri) && data.key?(:alias_url) &&
       data.key?(:hcard_url) && data.key?(:seed_url) &&
       data.key?(:guid) && data.key?(:profile_url) &&
       data.key?(:updates_url) && data.key?(:pubkey))
    end
    private_class_method :account_data_complete?

    # Does some rudimentary checking on the data Hash produced from parsing the
    # XML string
    # @param [Hash] data XML data
    # @return [Boolean] validation result
    def self.xml_data_valid?(data)
      (data.key?(:subject) && data.key?(:aliases) &&
       data.key?(:links))
    end

    # Raised, if the +data+ given to {WebFinger.from_account} is an invalid type
    # or doesn't contain all required entries. Also used if the parsed XML from
    # {WebFinger.from_xml} is incomplete.
    class InvalidData < RuntimeError
    end
  end
end; end
