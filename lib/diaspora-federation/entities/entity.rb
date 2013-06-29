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

  def initialize(args)
    raise ArgumentError.new("expected a Hash") unless args.is_a?(Hash)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) if self.class.class_props.include?(k)
    end
    freeze
  end

  def to_h
    out = {}
    self.class.class_props.map do |prop|
      out[prop] = self.send(prop)
    end
    out
  end

  def to_xml
    entity_xml
  end

  protected

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

  # some of this is from Rails "Inflector.undersore"
  def entity_name
    word = self.class.name.dup
    word.gsub!('::', '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
