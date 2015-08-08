
module DiasporaFederation
  module WebFinger
    # This class provides the means of generating an parsing account data to and
    # from the hCard format.
    # hCard is based on +RFC 2426+ (vCard) which got superseded by +RFC 6350+.
    # There is a draft for a new h-card format specification, that makes use of
    # the new vCard standard.
    #
    # @todo This needs some radical restructuring. The generated HTML is not
    #   correctly nested according to the hCard standard and class names are
    #   partially wrong. Also, apart from that, it's just ugly.
    #
    # @example Creating a hCard document from account data
    #   hc = HCard.from_account({
    #     guid:             '0123456789abcdef',
    #     diaspora_handle:  'user@server.example',
    #     full_name:        'User Name',
    #     url:              'https://server.example/',
    #     photo_full_url:   'https://server.example/uploads/f.jpg',
    #     photo_medium_url: 'https://server.example/uploads/m.jpg',
    #     photo_small_url:  'https://server.example/uploads/s.jpg',
    #     pubkey:           'ABCDEF==',
    #     searchable:       true,
    #     first_name:       'User',
    #     last_name:        'Name'
    #   })
    #   html_string = hc.to_html
    #
    # @example Create a HCard instance from an hCard document
    #   hc = HCard.from_html(html_string)
    #   ...
    #   full_name = hc.full_name
    #   ...
    #
    # @see http://microformats.org/wiki/hCard "hCard 1.0"
    # @see http://microformats.org/wiki/h-card "h-card" (draft)
    # @see http://www.ietf.org/rfc/rfc2426.txt "vCard MIME Directory Profile" (obsolete)
    # @see http://www.ietf.org/rfc/rfc6350.txt "vCard Format Specification"
    class HCard
      private_class_method :new

      attr_reader :guid, :nickname, :full_name, :url, :pubkey,
                  :photo_full_url, :photo_medium_url, :photo_small_url

      # @deprecated We decided to only use one name field, these should be removed
      #   in later iterations (will affect older Diaspora* installations).
      attr_reader :first_name, :last_name

      # @deprecated As this is a simple property, consider move to WebFinger instead
      #   of HCard. vCard has no comparable field for this information, but
      #   Webfinger may declare arbitrary properties (will affect older Diaspora*
      #   installations).
      attr_reader :searchable

      # CSS selectors for finding all the hCard fields
      SELECTORS = {
        uid:          '.uid',
        nickname:     '.nickname',
        fn:           '.fn',
        given_name:   '.given_name',
        family_name:  '.family_name',
        url:          '#pod_location',
        photo:        '.entity_photo .photo[src]',
        photo_medium: '.entity_photo_medium .photo[src]',
        photo_small:  '.entity_photo_small .photo[src]',
        key:          '.key',
        searchable:   '.searchable'
      }

      # Create the HTML string from the current HCard instance
      # @return [String] HTML string
      def to_html
        builder = Nokogiri::HTML::Builder.new do |html|
          # html.doc.create_internal_subset('html', nil, nil) # doctype

          html.html do
            html.head do
              html.meta(charset: 'UTF-8')
              html.title(@full_name)
            end

            html.body do
              html.div(id: 'content') do
                html.h1(@full_name)
                html.div(id: 'content_inner', class: 'entity_profile vcard author') do
                  html.h2('User profile')
                end
              end
            end
          end
        end

        c = builder.doc.at_css('#content_inner')

        add_simple_property(c, :uid, 'uid', @guid)
        add_simple_property(c, :nickname, 'nickname', @nickname)
        add_simple_property(c, :full_name, 'fn', @full_name)
        add_simple_property(c, :searchable, 'searchable', @searchable)
        add_simple_property(c, :key, 'key', @pubkey)

        # TODO: change me!  ####################
        add_simple_property(c, :first_name, 'given_name', @first_name)
        add_simple_property(c, :family_name, 'family_name', @last_name)
        #######################################

        add_property(c, :url) do |html|
          html.a(@url.to_s, id: 'pod_location', class: 'url', rel: 'me', href: @url.to_s)
        end

        # TODO: refactor me!  ##################
        add_property(c, :photo) do |html|
          # 'px' is wrong here!
          html.img(class: 'photo avatar', width: '300px', height: '300px', src: @photo_full_url.to_s)
        end

        add_property(c, :photo_medium) do |html|
          # 'px' is wrong here!
          html.img(class: 'photo avatar', width: '100px', height: '100px', src: @photo_medium_url.to_s)
        end

        add_property(c, :photo_small) do |html|
          # 'px' is wrong here!
          html.img(class: 'photo avatar', width: '50px', height: '50px', src: @photo_small_url.to_s)
        end
        #######################################

        builder.doc.to_xhtml(indent: 2, indent_text: ' ')
      end

      # Creates a new HCard instance from the given Hash containing account data
      # @param [Hash] data account data
      # @return [HCard] HCard instance
      # @raise [InvalidData] if the account data Hash is invalid or incomplete
      def self.from_account(data)
        fail InvalidData unless account_data_complete?(data)

        hc = allocate
        hc.instance_eval do
          @guid             = data[:guid]
          @nickname         = data[:diaspora_handle].split('@').first
          @full_name        = data[:full_name]
          @url              = data[:url]
          @photo_full_url   = data[:photo_full_url]
          @photo_medium_url = data[:photo_medium_url]
          @photo_small_url  = data[:photo_small_url]
          @pubkey           = data[:pubkey]
          @searchable       = data[:searchable]

          # TODO: change me!  ####################
          @first_name       = data[:first_name]
          @last_name        = data[:last_name]
          #######################################
        end
        hc
      end

      # Creates a new HCard instance from the given HTML string.
      # @param html_string [String] HTML string
      # @return [HCard] HCard instance
      # @raise [InvalidData] if the HTML string is invalid or incomplete
      def self.from_html(html_string)
        fail ArgumentError unless html_string.instance_of?(String)

        doc = Nokogiri::HTML::Document.parse(html_string)
        fail InvalidData unless html_document_complete?(doc)

        hc = allocate
        hc.instance_eval do
          @guid             = doc.at_css(SELECTORS[:uid]).content
          @nickname         = doc.at_css(SELECTORS[:nickname]).content
          @full_name        = doc.at_css(SELECTORS[:fn]).content
          @url              = doc.at_css(SELECTORS[:url])['href']
          @photo_full_url   = doc.at_css(SELECTORS[:photo])['src']
          @photo_medium_url = doc.at_css(SELECTORS[:photo_medium])['src']
          @photo_small_url  = doc.at_css(SELECTORS[:photo_small])['src']
          @pubkey           = doc.at_css(SELECTORS[:key]).content unless doc.at_css(SELECTORS[:key]).nil?
          @searchable       = doc.at_css(SELECTORS[:searchable]).content

          # TODO: change me!  ####################
          @first_name       = doc.at_css(SELECTORS[:given_name]).content
          @last_name        = doc.at_css(SELECTORS[:family_name]).content
          #######################################
        end
        hc
      end

      private

      # Add a property to the hCard document. The element will be added to the given
      # container element and a "definition list" structure will be created around
      # it. A Nokogiri::HTML::Builder instance will be passed to the given block,
      # which should be used to add the element(s) containing the property data.
      #
      # @param container [Nokogiri::XML::Element] parent element for added property HTML
      # @param name [Symbol] property name
      # @param block [Proc] block returning an element
      def add_property(container, name, &block)
        Nokogiri::HTML::Builder.with(container) do |html|
          html.dl(class: "entity_#{name}") do
            html.dt(name.to_s.capitalize)
            html.dd do
              block.call(html)
            end
          end
        end
      end

      # Calls {HCard#add_property} for a simple text property.
      # @param container [Nokogiri::XML::Element] parent element
      # @param name [Symbol] property name
      # @param class_name [String] HTML class name
      # @param value [#to_s] property value
      # @see HCard#add_property
      def add_simple_property(container, name, class_name, value)
        add_property(container, name) do |html|
          html.span(value.to_s, class: class_name)
        end
      end

      # Checks the given account data Hash for correct type and completeness.
      # @param [Hash] data account data
      # @return [Boolean] validation result
      def self.account_data_complete?(data)
        (!data.nil? && data.instance_of?(Hash) &&
         data.key?(:guid) && data.key?(:diaspora_handle) &&
         data.key?(:full_name) && data.key?(:url) &&
         data.key?(:photo_full_url) && data.key?(:photo_medium_url) &&
         data.key?(:photo_small_url) && data.key?(:pubkey) &&
         data.key?(:searchable) &&
         data.key?(:first_name) && data.key?(:last_name))
      end
      private_class_method :account_data_complete?

      # Make sure some of the most important elements are present in the parsed
      # HTML document.
      # @param [LibXML::XML::Document] doc HTML document
      # @return [Boolean] validation result
      def self.html_document_complete?(doc)
        (! (doc.at_css(SELECTORS[:fn]).nil? || doc.at_css(SELECTORS[:nickname]).nil? ||
            doc.at_css(SELECTORS[:url]).nil? || doc.at_css(SELECTORS[:photo]).nil?))
      end
      private_class_method :html_document_complete?

      # Raised, if the params passed to {HCard.from_account} or {HCard.from_html}
      # are in some way malformed, invalid or incomplete.
      class InvalidData < RuntimeError
      end
    end
  end
end
