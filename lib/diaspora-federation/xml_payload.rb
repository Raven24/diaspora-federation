module DiasporaFederation
  class XmlPayload
    # encapsulates an entity inside the wrapping xml structure
    # and returns the xml object
    #
    # the wrapper looks like so:
    # <XML>
    #   <post>
    #     {data}
    #   </post>
    # </XML>
    #
    # @param [Entity]
    # @return [Ox::Element]
    def self.pack(entity)
      raise ArgumentError unless entity.is_a?(Entity)

      wrap = Ox::Element.new('XML')
      wrap_post = Ox::Element.new('post')
      wrap_post << entity.to_xml
      wrap << wrap_post

      wrap
    end

    # extracts the entity xml from the wrapping xml structure and returns the
    # packed entity inside the payload
    # @param [Ox::Element]
    # @return [Entity]
    def self.unpack(xml)
      raise ArgumentError unless xml.instance_of?(Ox::Element)
      raise InvalidStructure unless wrap_valid?(xml)

      data = xml.nodes[0].nodes[0]
      klass_name = entity_class(data.name)
      raise UnknownEntity unless Entities.const_defined?(klass_name)

      Entities.const_get(klass_name).new(attribute_hash(data.nodes))
    end

    private

    # @param [Ox::Element]
    def self.wrap_valid?(element)
      (element.name == 'XML' && element.nodes[0] &&
      element.nodes[0].name == 'post' && element.nodes[0].nodes[0])
    end

    # some of this is from Rails "Inflector.camelize"
    # @param [String] snake_case class name
    # @return [String] CamelCase class name
    def self.entity_class(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }.gsub('/', '::')
    end

    # construct a hash of attributes from the node names and the text inside
    # @param [Ox::Element]
    # @return [Hash]
    def self.attribute_hash(node_arr)
      data = {}
      node_arr.each do |node|
        data[node.name.to_sym] = node.text
      end
      data
    end

    # specific errors

    class InvalidStructure < RuntimeError
    end

    class UnknownEntity < RuntimeError
    end
  end
end
