
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

    attr_reader :guid, :nickname, :full_name, :profile_url, :pubkey,
                :photo_full_url, :photo_medium_url, :photo_small_url

    # @deprecated We decided to only use one name field, these should be removed
    #   in later iterations (will affect older Diaspora* installations).
    attr_reader :first_name, :last_name

    # @deprecated As this is a simple property, consider move to WebFinger instead
    #   of HCard. vCard has no comparable field for this information, but
    #   Webfinger may declare arbitrary properties (will affect older Diaspora*
    #   installations).
    attr_reader :searchable

    #
    # @return [String] html string
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
        el['href'] = @profile_url.to_s
        el << @profile_url.to_s
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

    private

    def html_doc(doc)
      dt = Ox::DocType.new('html')
      doc << dt

      html = Ox::Element.new('html')
      doc << html

      html
    end

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

    def html_body(html)
      body = Ox::Element.new('body')
      html << body

      body
    end

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

    def add_simple_property(container, name, class_name, value)
      add_property(container, name) do
        el = Ox::Element.new('span')
        el['class'] = class_name
        el << value.to_s
        el
      end
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
        @profile_url      = data[:profile_url]
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

    # @todo write me!
    def self.from_html(html)
    end

    # Checks the given account data Hash for correct type and completeness.
    # @param [Hash] data account data
    # @return [Boolean] validation result
    def self.account_data_complete?(data)
      (!data.nil? && data.instance_of?(Hash) &&
       data.key?(:guid) && data.key?(:diaspora_handle) &&
       data.key?(:full_name) && data.key?(:profile_url) &&
       data.key?(:photo_full_url) && data.key?(:photo_medium_url) &&
       data.key?(:photo_small_url) && data.key?(:pubkey) &&
       data.key?(:searchable) &&
       data.key?(:first_name) && data.key?(:last_name))
    end
    private_class_method :account_data_complete?

    class InvalidData < RuntimeError
    end
  end
end; end
