module DiasporaFederation
  class XmlPayload
    module ClassMethods
      def wrap_valid?(element)
        (element.name == 'XML' && element.nodes[0] &&
        element.nodes[0].name == 'post' && element.nodes[0].nodes[0])
      end

      # some of this is from Rails "Inflector.camelize"
      def entity_class(term)
        string = term.to_s
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }.gsub('/', '::')
      end

      def attribute_hash(node_arr)
        data = {}
        node_arr.each do |node|
          data[node.name.to_sym] = node.text
        end
        data
      end
    end

    self.extend XmlPayload::ClassMethods

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

    # specific errors

    class InvalidStructure < RuntimeError
    end

    class UnknownEntity < RuntimeError
    end
  end
end
