
module DiasporaFederation; module WebFinger

  # This class provides the means of generating an parsing account data to and
  # from the hCard format.
  # hCard is based on +RFC 2426+ (vCard) which got superseded by +RFC 6350+.
  # There is a draft for a new h-card format specification, that makes use of
  # the new vCard standard.
  #
  # @note The current implementation contains a huge amount of legacy elements
  #   and classes, that should be removed and cleaned up in later iterations.
  #
  # @todo This needs some radical restructuring. The generated HTML is not
  #   correctly nested according to the hCard standard and class names are
  #   partially wrong. Apart from that, it's just ugly.
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

    # @note Concatenating spaces here to make sure the class strings actually are there,
    #   and not just part of a longer, different string.
    XPATHS = {
      uid: '//*[contains(concat(" ", @class, " "), " uid ")]',
      nickname: '//*[contains(concat(" ", @class, " "), " nickname ")]',
      fn: '//*[contains(concat(" ", @class, " "), " fn ")]',
      given_name: '//*[contains(concat(" ", @class, " "), " given_name ")]',
      family_name: '//*[contains(concat(" ", @class, " "), " family_name ")]',
      url: '//*[contains(concat(" ", @id, " "), " pod_location ")]',
      photo: '//*[contains(concat(" ", @class, " "), " entity_photo ")]//*[contains(concat(" ", @class, " "), " photo ")]',
      photo_medium: '//*[contains(concat(" ", @class, " "), " entity_photo_medium ")]//*[contains(concat(" ", @class, " "), " photo ")]',
      photo_small: '//*[contains(concat(" ", @class, " "), " entity_photo_small ")]//*[contains(concat(" ", @class, " "), " photo ")]',
      key: '//*[contains(concat(" ", @class, " "), " key ")]',
      searchable: '//*[contains(concat(" ", @class, " "), " searchable ")]',
    }

    # Create the HTML string from the current HCard instance
    # @return [String] HTML string
    def to_html
      doc = Ox::Document.new(encoding: 'UTF-8')

      html = html_doc(doc)

      head = html_head(html)
      body = html_body(html)

      cnt =  Ox::Element.new('div')
      cnt['id'] = 'content'
      body << cnt

      h = Ox::Element.new('h1')
      h << @full_name
      cnt << h

      c = Ox::Element.new('div')
      c['id'] = 'content_inner'
      c['class'] = 'entity_profile vcard author'
      cnt << c

      h2 = Ox::Element.new('h2')
      h2 << 'User profile'

      add_simple_property(c, :uid, 'uid', @guid)
      add_simple_property(c, :nickname, 'nickname', @nickname)
      add_simple_property(c, :full_name, 'fn', @full_name)
      add_simple_property(c, :searchable, 'searchable', @searchable)
      add_simple_property(c, :key, 'key', @pubkey)

      # TODO change me!  ####################
      add_simple_property(c, :first_name, 'given_name', @first_name)
      add_simple_property(c, :family_name, 'family_name', @last_name)
      #######################################

      add_property(c, :url) do
        el = Ox::Element.new('a')
        el['id'] = 'pod_location'
        el['class'] = 'url'
        el['rel'] = 'me'
        el['href'] = @url.to_s
        el << @url.to_s
        el
      end

      # TODO refactor me!  ##################
      add_property(c, :photo) do
        el = Ox::Element.new('img')
        el['class'] = 'photo avatar'
        el['width'] = '300px'   # 'px' is wrong here!
        el['height'] = '300px'  # 'px' is wrong here!
        el['src'] = @photo_full_url.to_s
        el
      end

      add_property(c, :photo_medium) do
        el = Ox::Element.new('img')
        el['class'] = 'photo avatar'
        el['width'] = '100px'   # 'px' is wrong here!
        el['height'] = '100px'  # 'px' is wrong here!
        el['src'] = @photo_medium_url.to_s
        el
      end

      add_property(c, :photo_small) do
        el = Ox::Element.new('img')
        el['class'] = 'photo avatar'
        el['width'] = '50px'   # 'px' is wrong here!
        el['height'] = '50px'  # 'px' is wrong here!
        el['src'] = @photo_small_url.to_s
        el
      end
      #######################################

      Ox.dump(doc)
    end

    # Creates a new HCard instance from the given Hash containing account data
    # @param [Hash] data account data
    # @return [HCard] HCard instance
    # @raise [InvalidData] if the account data Hash is invalid or incomplete
    def self.from_account(data)
      raise InvalidData unless account_data_complete?(data)

      hc = self.allocate
      hc.instance_eval {
        @guid             = data[:guid]
        @nickname         = data[:diaspora_handle].split('@').first
        @full_name        = data[:full_name]
        @url              = data[:url]
        @photo_full_url   = data[:photo_full_url]
        @photo_medium_url = data[:photo_medium_url]
        @photo_small_url  = data[:photo_small_url]
        @pubkey           = data[:pubkey]
        @searchable       = data[:searchable]

        # TODO change me!  ####################
        @first_name       = data[:first_name]
        @last_name        = data[:last_name]
        #######################################
      }
      hc
    end

    # Creates a new HCard instance from the given HTML string.
    # @param html_string [String] HTML string
    # @return [HCard] HCard instance
    # @raise [InvalidData] if the HTML string is invalid or incomplete
    def self.from_html(html_string)
      raise ArgumentError unless html_string.instance_of?(String)

      doc = LibXML::XML::HTMLParser.string(html_string).parse
      raise InvalidData unless html_document_complete?(doc)

      hc = self.allocate
      hc.instance_eval {
        @guid             = doc.find(XPATHS[:uid]).first.content
        @nickname         = doc.find(XPATHS[:nickname]).first.content
        @full_name        = doc.find(XPATHS[:fn]).first.content
        @url              = doc.find(XPATHS[:url]).first['href']
        @photo_full_url   = doc.find(XPATHS[:photo]).first['src']
        @photo_medium_url = doc.find(XPATHS[:photo_medium]).first['src']
        @photo_small_url  = doc.find(XPATHS[:photo_small]).first['src']
        @pubkey           = doc.find(XPATHS[:key]).first.content unless doc.find(XPATHS[:key]).empty?
        @searchable       = doc.find(XPATHS[:searchable]).first.content

        # TODO change me!  ####################
        @first_name       = doc.find(XPATHS[:given_name]).first.content
        @last_name        = doc.find(XPATHS[:family_name]).first.content
        #######################################
      }
      hc
    end

    private

    # Create a +HTML+ element inside the given document.
    # @params [Ox::Document] doc document
    # @return [Ox::Element] HTML element
    def html_doc(doc)
      dt = Ox::DocType.new('html')
      doc << dt

      html = Ox::Element.new('html')
      doc << html

      html
    end

    # Create a +HEAD+ element inside the given html element
    # @param [Ox::Element] html HTML element
    # @return [Ox::Element] HEAD element
    def html_head(html)
      head = Ox::Element.new('head')
      html << head

      meta = Ox::Element.new('meta')
      meta['charset'] = 'UTF-8'
      head << meta

      title = Ox::Element.new('title')
      title << @full_name
      head << title

      head
    end

    # Create a +BODY+ element inside the given html element
    # @param [Ox::Element] html HTML element
    # @return [Ox::Element] BODY element
    def html_body(html)
      body = Ox::Element.new('body')
      html << body

      body
    end

    # Add a property to the hCard document. The element will be added to the given
    # container element and a "definition list" structure will be created around
    # it. Expects a block returning an Ox::Element with the property specified in
    # the HTML element.
    # @param container [Ox::Element] parent element for added property HTML
    # @param name [Symbol] property name
    # @param block [Proc] block returning an element
    def add_property(container, name, &block)
      wrap = Ox::Element.new('dl')
      wrap['class'] = "entity_#{name.to_s}"
      container << wrap

      title = Ox::Element.new('dt')
      title << name.to_s.capitalize
      wrap << title

      data = Ox::Element.new('dd')
      data << block.call
      wrap << data
    end

    # Calls {HCard#add_property} for a simple text property.
    # @param container [Ox::Element] parent element
    # @param name [Symbol] property name
    # @param class_name [String] HTML class name
    # @param value [#to_s] property value
    # @see HCard#add_property
    def add_simple_property(container, name, class_name, value)
      add_property(container, name) do
        el = Ox::Element.new('span')
        el['class'] = class_name
        el << value.to_s
        el
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
      (! (doc.find(XPATHS[:fn]).empty? || doc.find(XPATHS[:nickname]).empty? ||
          doc.find(XPATHS[:url]).empty? || doc.find(XPATHS[:photo]).empty? ))
    end
    private_class_method :html_document_complete?

    # Raised, if the params passed to {HCard.from_account} or {HCard.from_html}
    # are in some way malformed, invalid or incomplete.
    class InvalidData < RuntimeError
    end
  end
end; end
