module DiasporaFederation
  class Entity
    module ClassMethods
      attr_accessor :class_props

      def self.included(base)
        base.extend self
      end

      def set_allowed_props(*props)
        @class_props = props
        instance_eval { attr_reader *props }
      end
    end

    include Entity::ClassMethods

    # initializes the entity with the given attribute hash and freezes the instance
    # (extra attributes that were not defined in the class definition get discarded)
    # @param [Hash]
    # @return [Entitiy]
    def initialize(args)
      raise ArgumentError.new("expected a Hash") unless args.is_a?(Hash)
      args.each do |k,v|
        instance_variable_set("@#{k}", v) if self.class.class_props.include?(k)
      end
      freeze
    end

    # returns a hash representing this entity (attributes => values)
    # @return [Hash]
    def to_h
      out = {}
      self.class.class_props.map do |prop|
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

    private

    def entity_xml
      root_element = Ox::Element.new(entity_name)

      self.class.class_props.each do |prop|
        node = Ox::Element.new(prop.to_s)
        data = self.send(prop).to_s
        node << data unless data.empty?
        root_element << node
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
  end
end
