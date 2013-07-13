module DiasporaFederation

  # +Entity+ is the base class for all other objects used to encapsulate data
  # for federation messages in the Diaspora* network.
  # Entity fields are specified using a simple {PropertiesDSL DSL} as part of
  # the class definition.
  #
  # @example Entity subclass definition
  #   class MyEntity < Entity
  #     define_props do
  #       property :prop
  #       entity :nested, NestedEntity
  #       entity :multiple, [OtherEntity]
  #     end
  #   end
  #
  # Any entity also provides the means to serialize itself and all nested
  # entities to XML (for deserialization from XML to +Entity+ instances, see
  # {XmlPayload}).
  #
  # @abstract Subclass and specify properties to implement various entities.
  class Entity
    class << self
      # @return [Hash] the hash used to declare the entity properties as returned
      #   by the DSL
      attr_accessor :class_props
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
      raise ArgumentError.new("expected a Hash") unless args.is_a?(Hash)
      args.each do |k,v|
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
    # {Ox::Element}s
    #
    # @see Ox::dump
    # @see XmlPayload::pack
    #
    # @return [Ox::Element] root element containing properties as child elements
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
      @class_props = PropertiesDSL.new(&block).get_properties
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

    def entity_xml
      root_element = Ox::Element.new(self.class.entity_name)

      self.class.class_props.each do |prop_def|
        name = prop_def[:name]
        type = prop_def[:type]
        if type == String
          # create simple node, fill it with text and append to root
          node = Ox::Element.new(name.to_s)
          data = send(name).to_s
          node << data unless data.empty?
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
      @class_prop_names
    end
  end
end
