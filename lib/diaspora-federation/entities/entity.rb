module DiasporaFederation
  class Entity
    class << self
      attr_accessor :class_props
    end

    # initializes the entity with the given attribute hash and freezes the instance
    # (extra attributes that were not defined in the class definition get discarded)
    # @param [Hash]
    # @return [Entitiy]
    def initialize(args)
      raise ArgumentError.new("expected a Hash") unless args.is_a?(Hash)
      args.each do |k,v|
        instance_variable_set("@#{k}", v) if setable?(k, v)
      end
      freeze
    end

    # returns a hash representing this entity (attributes => values)
    # @return [Hash]
    def to_h
      out = {}
      self.class.class_prop_names.map do |prop|
        out[prop] = self.send(prop)
      end
      out
    end

    # returns the xml representation for this entity constructed out of
    # Ox::Elements
    # @return [Ox::Element]
    def to_xml
      entity_xml
    end

    # set the properties for this entity class.
    # only the properties that were specified can be assigned
    # @param [Proc]
    def self.define_props(&block)
      @class_props = PropertiesDSL.new(&block).get_properties
      instance_eval { attr_reader *@class_props.map { |p| p[:name] } }
    end

    private

    def setable?(name, val)
      prop_def = self.class.class_props.detect { |p| p[:name] == name }
      return false if prop_def.nil? # property undefined

      type = prop_def[:type]
      if  type == String && val.respond_to?(:to_s)
        true
      elsif type.respond_to?(:ancestors) && type.ancestors.include?(Entity) && val.is_a?(Entity)
        true
      elsif type.instance_of?(Array) && val.instance_of?(Array)
        val.all? { |v| v.instance_of?(type.first) }
      else
        false
      end
    end

    def entity_xml
      root_element = Ox::Element.new(entity_name)

      self.class.class_props.each do |prop_def|
        name = prop_def[:name]
        type = prop_def[:type]
        if type == String
          # create simple node, fill it and append to root
          node = Ox::Element.new(name.to_s)
          data = self.send(name).to_s
          node << data unless data.empty?
          root_element << node
        elsif type.instance_of?(Array)
          # call #to_xml for each item and append to root
          self.send(name).each do |item|
            root_element << item.to_xml
          end
        elsif type.ancestors.include?(Entity)
          # append the nested entity's xml to the root
          root_element << self.send(name).to_xml
        end
      end

      root_element
    end

    # some of this is from Rails "Inflector.demodulize" and "Inflector.undersore"
    def entity_name
      word = self.class.name.dup
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

    def self.class_prop_names
      return @class_prop_names unless @class_prop_names.nil?

      @class_prop_names = @class_props.map { |p| p[:name] }
      @class_prop_names
    end
  end
end
