module DiasporaFederation

  # +Entity+ is the base class for all other objects used to encapsulate data
  # for federation messages in the Diaspora* network.
  # Entity fields are specified using a simple {PropertiesDSL DSL} as part of
  # the class definition.
  #
  # Any entity also provides the means to serialize itself and all nested
  # entities to XML (for deserialization from XML to +Entity+ instances, see
  # {XmlPayload}).
  #
  # @abstract Subclass and specify properties to implement various entities.
  #
  # @example Entity subclass definition
  #   class MyEntity < Entity
  #     define_props do
  #       property :prop
  #       property :optional, default: false
  #       property :dynamic_default, default: -> { Time.now }
  #       entity :nested, NestedEntity
  #       entity :multiple, [OtherEntity]
  #     end
  #   end
  #
  # @example Entity instantiation
  #   nentity = NestedEntity.new
  #   oe1 = OtherEntity.new
  #   oe2 = OtherEntity.new
  #
  #   entity = MyEntity.new({ prop: 'some property',
  #                           nested: nentity,
  #                           multiple: [oe1, oe2] })
  #
  # @note Entity properties can only be set during initialization, after that the
  #   entity instance becomes frozen and must not be modified anymore. Instances
  #   are intended to be immutable data containers, only.
  class Entity
    class << self
      # @return [Hash] the hash used to declare the entity properties as returned
      #   by the DSL
      attr_reader :class_props
    end

    # Initializes the Entity with the given attribute hash and freezes the created
    # instance it returns.
    #
    # @note Attributes not defined as part of the class definition ({Entity.define_props})
    #       get discarded silently.
    #
    # @param [Hash] data
    # @return [Entitiy] new instance
    def initialize(args)
      raise ArgumentError, "expected a Hash" unless args.is_a?(Hash)
      missing_props = self.class.missing_props(args)
      unless missing_props.empty?
        raise ArgumentError, "missing required properties: #{missing_props.join(', ')}"
      end

      self.class.default_props.merge(args).each do |k,v|
        instance_variable_set("@#{k}", v) if setable?(k, v)
      end
      freeze
    end

    # Returns a Hash representing this Entity (attributes => values)
    # @return [Hash] entity data (mostly equal to the hash used for initialization).
    def to_h
      out = {}
      self.class.class_prop_names.map do |prop|
        out[prop] = self.send(prop)
      end
      out
    end

    # Returns the XML representation for this entity constructed out of
    # {Nokogiri::XML::Element}s
    #
    # @see Nokogiri::XML::Node.to_xml
    # @see XmlPayload.pack
    #
    # @return [Nokogiri::XML::Element] root element containing properties as child elements
    def to_xml
      entity_xml
    end

    # Set the properties for this Entity class using a simple DSL.
    #
    # @note Only the properties that were specified as part of the class definition
    #   can later be assigned during initialization.
    #
    # @see PropertiesDSL
    #
    # @param [Proc] block
    # @return [void]
    def self.define_props(&block)
      dsl = PropertiesDSL.new(&block)
      @class_props = dsl.get_properties
      @default_props = dsl.get_defaults
      instance_eval { attr_reader *@class_props.map { |p| p[:name] } }
    end

    private

    def setable?(name, val)
      prop_def = self.class.class_props.detect { |p| p[:name] == name }
      return false if prop_def.nil? # property undefined

      return true if setable_string?(prop_def, val) ||
                     setable_nested?(prop_def, val) ||
                     setable_multi?(prop_def, val)

      false
    end

    def setable_string?(definition, val)
      (definition[:type] == String && val.respond_to?(:to_s))
    end

    def setable_nested?(definition, val)
      t = definition[:type]
      (t.is_a?(Class) && t.ancestors.include?(Entity) && val.is_a?(Entity))
    end

    def setable_multi?(definition, val)
      t = definition[:type]
      (t.instance_of?(Array) &&
       val.instance_of?(Array) &&
       val.all? { |v| v.instance_of?(t.first) })
    end

    # Serialize the Entity into XML elements
    # @return [Nokogiri::XML::Element] root node
    def entity_xml
      doc = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
      root_element = Nokogiri::XML::Element.new(self.class.entity_name, doc)

      self.class.class_props.each do |prop_def|
        name = prop_def[:name]
        type = prop_def[:type]
        if type == String
          # create simple node, fill it with text and append to root
          node = Nokogiri::XML::Element.new(name.to_s, doc)
          data = send(name).to_s
          node.content = data unless data.empty?
          root_element << node
        else
          # call #to_xml for each item and append to root
          [*send(name)].each do |item|
            root_element << item.to_xml unless item.nil?
          end
        end
      end

      root_element
    end

    # Return array of missing required property names
    def self.missing_props(args)
      class_prop_names - @default_props.keys - args.keys
    end

    # Return a new hash of default values, with dynamic values
    # resolved on each call
    def self.default_props
      @default_props.each_with_object({}) { |(name, prop), hsh|
        hsh[name] = prop.respond_to?(:call) ? prop.call : prop
      }
    end

    # some of this is from Rails "Inflector.demodulize" and "Inflector.undersore"
    def self.entity_name
      word = self.name.dup
      if (i = word.rindex('::'))
        word = word[(i+2)..-1]
      end
      word.gsub!('::', '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def self.nested_class_props
      @nested_class_props ||= @class_props.select { |p| p[:type] != String }
      @nested_class_props
    end

    def self.class_prop_names
      @class_prop_names ||= @class_props.map { |p| p[:name] }
    end
  end
end
