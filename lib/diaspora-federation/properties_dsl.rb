module DiasporaFederation
  class PropertiesDSL
    # this is where the DSL block gets evaluated.
    # call 'get_properties' on the instance after you're done defining the
    # properties to get an array of properties in order they were specified
    # @param [Proc]
    def initialize(&block)
      @properties = []
      instance_eval(&block)
      @properties.freeze
    end

    # define a generic property
    # @param [Symbol] property name
    def property(name)
      raise InvalidName unless name_valid?(name)
      @properties << { name: name, type: String }
    end

    # define a property that should contain another Entity or an array of
    # other Entities
    # @param [Symbol] property name
    # @param [mixed] Entity subclass or
    #                Array with exactly one Entity subclass constant inside
    def entity(name, type)
      raise InvalidName unless name_valid?(name)
      raise InvalidType unless type_valid?(type)
      @properties << { name: name, type: type }
    end

    # returns an array of the previously defined properties, each property is
    # represented as a hash consisting of a name and a type
    # @return [Array<Hash>] e.g. [{ name: Symbol, type: Type}, {...}, ...]
    def get_properties
      @properties
    end

    protected

    def name_valid?(name)
      (name.instance_of?(Symbol) ||
       name.instance_of?(String))
    end

    def type_valid?(type)
      ((type.instance_of?(Array) &&
        type.first.respond_to?(:ancestors) &&
        type.first.ancestors.include?(Entity)) ||
       (type.respond_to?(:ancestors) &&
        type.ancestors.include?(Entity)))
    end

    # specific errors

    class InvalidName < RuntimeError
    end

    class InvalidType < RuntimeError
    end
  end
end
