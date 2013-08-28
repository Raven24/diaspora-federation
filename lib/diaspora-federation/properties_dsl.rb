module DiasporaFederation

  # Provides a simple DSL for specifying {Entity} properties during class
  # definition.
  # @see Entity.define_props
  class PropertiesDSL
    # This is where the DSL block gets evaluated.
    # Call {PropertiesDSL#get_properties} on the created instance after you're
    # done defining the properties to get an array of properties in order they
    # were specified.
    # @param [Proc] block will be evaluated in the created instance
    def initialize(&block)
      @properties = []
      @defaults = {}
      instance_eval(&block)
      @properties.freeze
      @defaults.freeze
    end

    # Define a generic (string-type) property
    # @param [Symbol] name property name
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def property(name, opts={})
      define_property name, String, opts
    end

    # Define a property that should contain another Entity or an array of
    # other Entities
    # @param [Symbol] name property name
    # @param [Entity, Array<Entity>] type Entity subclass or
    #                Array with exactly one Entity subclass constant inside
    # @param [Hash] opts further options
    # @option opts [Object, #call] :default a default value, making the
    #   property optional
    def entity(name, type, opts={})
      raise InvalidType unless type_valid?(type)

      define_property name, type, opts
    end

    # Returns an array of the previously defined properties, each property is
    # represented as a hash consisting of a name and a type
    # @return [Array<Hash>] e.g. [{ name: Symbol, type: Type}, ...]
    def get_properties
      @properties
    end

    # Returns a hash of default values for properties. Each key
    # is a property name and each value either the default value
    # or a callable returning the default value.
    def get_defaults
      @defaults
    end

    protected

    def define_property(name, type, opts={})
      raise InvalidName unless name_valid?(name)

      @properties << { name: name, type: type }
      @defaults[name] = opts[:default] if opts.has_key? :default
    end

    def name_valid?(name)
      (name.instance_of?(Symbol) ||
       name.instance_of?(String))
    end

    def type_valid?(type)
      [type].flatten.all? { |type|
        type.respond_to?(:ancestors) && type.ancestors.include?(Entity)
      }
    end

    # Raised, if the name is of an unexpected type
    class InvalidName < RuntimeError
    end

    # Raised, if the type is of an unexpected type
    class InvalidType < RuntimeError
    end
  end
end
